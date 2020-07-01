tool
extends Node2D

signal generate_next

export var preprocess_tile_sets_in_editor = true
export var show_case_map_in_editor = true
export var show_case_size:int = 30
export var is_preset = false

# What to print and what not
export var debug_mode = false

export var print_ticking = false
export var print_path_maker = false
export var print_panda_pathing = false
export var print_weather = true

# Consts
export var tile_cols:int = 12
export var tile_rows:int = 8
var layer_offset:int = 100

export var region_width:int = 116
export var region_height:int = 200

export var avg_tick_time_of_one_tile:float = 40.0

export(Array, Texture) var landscapeBlocksOverlayTextures

var layers = 6
var layer_px_dst = 15

var time = 0

# Vision
const vision_per_rd_time = 0.8
var visions = []

# State
var level = 1
var blocks = {}
var landscapes = {}
var cell_infos = {}
var tick_time_left = 0

# Nodes
onready var map_landscape:TileMap = $Navigation2D/MapLandscape
onready var map_blocks:TileMap = $Navigation2D/MapBlocks
onready var map_overlay:TileMap = $Navigation2D/MapOverlay
onready var all_maps = [map_landscape, map_blocks, map_overlay]
onready var weather = get_parent().get_node("WeatherManager")

var weatherManager

onready var lex = preload("res://scripts/Lex.gd").new()

onready var nth = {
	"Panda":preload("res://scenes/Panda.tscn"),
	"Bug":preload("res://scenes/Bug.tscn"),
	"ParticlesSmoke":preload("res://scenes/particles/Particles_smoke.tscn"),
	"ParticlesArtefact":preload("res://scenes/particles/Particles_artefact.tscn"),
	"ParticlesDrops":preload("res://scenes/particles/Particles_drops.tscn"),
	"ParticlesWelled":preload("res://scenes/particles/Particles_welled.tscn"),
	"ParticlesSpray":preload("res://scenes/particles/Particles_spray.tscn"),
	"ParticlesVision":preload("res://scenes/particles/Particles_vision.tscn"),
	"ParticlesFertility":preload("res://scenes/particles/Particles_fertility.tscn"),
	"ParticlesBugStomped":preload("res://scenes/particles/Particles_bug_stomped.tscn"),
	"ParticlesBugHillStomped":preload("res://scenes/particles/Particles_bug_hill_stomped.tscn"),
	"ParticlesFireExtinguished":preload("res://scenes/particles/Particles_fire_extinguished.tscn"),
	"ParticlesFireBurned":preload("res://scenes/particles/Particles_fire_burned.tscn"),
	"ParticlesWaterFalls":preload("res://scenes/particles/Particles_water_falls.tscn"),
	"Fire":preload("res://scenes/Fire.tscn"),
	"OrangeLight":preload("res://scenes/OrangeLight.tscn"),
	"ArtefactScreen":preload("res://scenes/ui/ArtefactScreen.tscn"),
	"RepeatIcon":preload("res://scenes/ui/RepeatIcon.tscn"),
	"Inventory":preload("res://scenes/Inventory.tscn"),
	"WalkBoostEffect":preload("res://scenes/WalkBoostEffect.tscn"),
	"PathMaker":preload("res://scenes/PathMaker.tscn"),
	"River":preload("res://scenes/River.tscn"),
	}

# OpenSimplex
var map_gens_lex = {
	"height" : {"octaves": 3, "period": 10.0, "persistence": 0.8, "seed": randi()+2},
	"fertility" : {"octaves": 5, "period": 0.2, "persistence": 0.8, "seed": randi()},
	"humidity" : {"octaves": 4, "period": 4.0, "persistence": 0.8, "seed": randi()}
}
var map_gens = {}


var level_defs = [
	{
		"circle_radii": [5],
		"artefact_difficulties": ["easy"],
		"weather": {"day":0.1, "rain":0.0, "storm":-0.26, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [5, 5],
		"artefact_difficulties": ["easy", "medium"],
		"weather": {"day":0.0, "rain":0.0, "storm":-0.18, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [6, 6],
		"artefact_difficulties": ["medium", "medium"],
		"weather": {"day":-0.1, "rain":0.0, "storm":-0.1, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [6, 7, 7],
		"artefact_difficulties": ["medium", "medium", "hard"],
		"weather": {"day":-0.15, "rain":0.0, "storm":0.0, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [6, 7, 8],
		"artefact_difficulties": ["medium", "hard", "hard"],
		"weather": {"day":-0.15, "rain":0.0, "storm":0.1, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [7, 8, 9],
		"artefact_difficulties": ["hard", "hard", "hard"],
		"weather": {"day":-0.2, "rain":0.0, "storm":0.18, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [8, 9, 10],
		"artefact_difficulties": ["hard", "hard", "hard"],
		"weather": {"day":-0.2, "rain":0.0, "storm":0.26, "tide": 0, "fog":0 }
	},
	{
		"circle_radii": [9, 10, 11],
		"artefact_difficulties": ["hard", "hard", "hard"],
		"weather": {"day":-0.25, "rain":0.0, "storm":0.34, "tide": 0, "fog":0 }
	}
]
var level_def
# [pos, rad]
var map_generation_circles = []
var start_pos = Vector2()

func _ready():
	init_map_gens()
	
	if Engine.editor_hint and preprocess_tile_sets_in_editor:
		update_tileset_regions()
	
	var g = load("res://scripts/NonToolFix.gd").new().g()
	if level_defs.size() < g.level:
		printerr("Could not find level_def for level " + str(g.level))
		level_def = level_defs[level_defs.size() - 1]
	else:
		level_def = level_defs[g.level - 1]
	
	if !is_preset:
		# Clear everything
		map_landscape.clear()
		map_blocks.clear()
		map_overlay.clear()
		for panda in get_tree().get_nodes_in_group("panda"):
			panda.queue_free()

		# First set location of first 
		var first_circle = [Vector2(0, 0), level_def.circle_radii[0]]
		
		# Then calc start pos
		# set start pos around edge of first circle
		start_pos = first_circle[0] + Vector2(first_circle[1]-1, 0).rotated(fmod(randf(), 2*PI))
		start_pos = Vector2(int(round(start_pos.x)), int(round(start_pos.y)))
		
		# then create rest of circles for island gen:
		#var grow_direction = (first_circle[0] - start_pos).normalized()

		var next_pos
		var next_rad

		map_generation_circles = [first_circle]
		for i in range(1, level_def.circle_radii.size()):
			var too_close = true
			var iterations = 0
			while too_close and iterations < 10000:
				var rand_circle = map_generation_circles[randi()%map_generation_circles.size()]
				var last_rad = rand_circle[1]
				var last_pos = rand_circle[0]
				next_rad = level_def.circle_radii[i]
				next_pos = last_pos + Vector2(last_rad + next_rad - 2, 0).rotated(fmod(randf(), 2*PI))
				next_pos = Vector2(int(round(next_pos.x)), int(round(next_pos.y)))
				next_pos = Vector2(next_pos.x-int(next_pos.x)%2, next_pos.y-int(next_pos.y)%2)
				
				too_close = false
				for prev_circle in map_generation_circles:
					if prev_circle[0].distance_to(next_pos) <= prev_circle[1] + next_rad - 4:
						too_close = true
				if start_pos.distance_to(next_pos) <= next_rad:
					too_close = true
				iterations += 1
			if (iterations >= 10000):
				printerr("## Map ## Too many iterations in map gen!")
			# if loop done: result in next_pos & next_rad
			map_generation_circles.append([next_pos, next_rad])
		
		
		prepare_presets(start_pos)
		prepare_rivers()
		generate_tile(start_pos)
		show_homes()
	
		if !Engine.editor_hint:
			get_parent().get_node("Camera2D").offset = map_overlay.map_to_world(start_pos)
			# set number of artefacts to find 
			var ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
			if ressourceManager.size() > 0:
				ressourceManager[0].add_ressource("artefacts_max", map_generation_circles.size())

			var weatherManager = get_tree().get_nodes_in_group("weatherManager")
			if weatherManager.size() > 0: self.weatherManager = weatherManager[0]

			
	if Engine.editor_hint and show_case_map_in_editor:
		grant_vision(Vector2(), show_case_size)

	

var preset_cache = {}
var preset_poss = {}

func prepare_presets(start_pos):
	preset_cache = {}
	preset_poss = {}
	var taken_presets = []
	for i in range(map_generation_circles.size()):
		var circle = map_generation_circles[i]
		var difficulty = level_def.artefact_difficulties[i]
		
		var angle_center_start = calc_px_pos_on_tile(start_pos).angle_to(calc_px_pos_on_tile(circle[0]))
		var angle_center_preset = fmod(angle_center_start + PI, 2*PI)
		
		var center_to_start = (calc_px_pos_on_tile(start_pos) - calc_px_pos_on_tile(circle[0])).normalized()
		var center_to_present = -center_to_start * circle[1] * 0.75
		
		var pos = circle[0] + center_to_present
		var cell_pos = Vector2(int(round(pos.x)), int(round(pos.y))) # will be [0,0] of the preset
		cell_pos = Vector2(cell_pos.x-int(cell_pos.x)%2, cell_pos.y-int(cell_pos.y)%2)

		
		var preset = ensure_cache_singleton(difficulty)
		var iterations = 0
		while taken_presets.find(preset) != -1 and iterations < 100: # dont take duplicates
			preset = ensure_cache_singleton(difficulty)
			iterations += 1
		if iterations >= 100:
			printerr("Could not select unique artefact presets")
		taken_presets.append(preset)
		
		if preset.has_node("Map"):
			preset = preset.get_node("Map")
		var preset_landscape = preset.get_node("Navigation2D/MapLandscape")
		var preset_blocks = preset.get_node("Navigation2D/MapBlocks")
		# take a Dictionary an fill it with all blocks that are part of any preset
		
		for preset_pos in preset_landscape.get_used_cells():
			var landscape_id = preset_landscape.get_cellv(preset_pos)
			var block_id = preset_blocks.get_cellv(preset_pos)
			preset_poss[cell_pos+preset_pos] = [landscape_id, block_id]
			
		if false and Engine.editor_hint:
			var c = load("res://scenes/DebugCircle.tscn").instance()
			c.position = calc_px_pos_on_tile(circle[0])
			c.scale = Vector2(2 + 3.5 * circle[1], 2 + 3.5 * circle[1])
			get_parent().call_deferred("add_child", c)


var rivers = []
func prepare_rivers():
	# valid = no building
	# goal = water
	
	for circle in map_generation_circles:
		var river = []
		var start_candidates = get_adjacent_tiles(circle[0], circle[1]*0.2)
		
		var start = null
		var highest = 100
		for candidate in start_candidates:
			if candidate == start_pos or is_part_of_preset(candidate):
				continue
			var height = create_cell_info(candidate).precise_height
			if start == null or highest > height:
				start = candidate
				highest = height
		
		print("## River ## making river from " + str(start))
		if start == null:
			printerr("## River ## could find valid start")
			continue
			
		var current = start
		river.append(current)
		while current != null and create_cell_info(current).height < layers - 1 and !create_cell_info(current).isOcean:
			var adjs = get_adjacent_tiles(current, 1)
			
			var next = null
			var lowest = -100
		
			for adj in adjs:
				var height = create_cell_info(adj).precise_height
				# (is currently deepest adj) and (is valid pos)
				if (adj == null or lowest < height) and (adj != start_pos and !is_part_of_preset(adj) and !river.has(adj) and abs(create_cell_info(adj).height - create_cell_info(current).height) <= 1):
					next = adj
					lowest = height
					
			if next == null:
				printerr("## River ## could find valid next tile from " + str(current))
				current = null
				continue
			
			current = next
			river.append(current)
		
		print("## River ## Path is " + str(river))
		rivers.append(river)
			
		
func is_part_of_preset(pos):
	return preset_poss.has(pos)

func ensure_cache_singleton(difficulty):
	
	if !preset_cache.has(difficulty):
		preset_cache[difficulty] = {}
	
	var preset_paths = []
	var path = "res://scenes/presets/" + difficulty + "/"
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if !dir.current_is_dir() and [".DS_Store", ".", "..", "Thumbs.db"].find(file_name) == -1:
				preset_paths.append(path + file_name)
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access " + path)
		
	var id = randi() % preset_paths.size()
	preset_cache[difficulty][id] = load(preset_paths[id]).instance()
	return preset_cache[difficulty][id]
	

	
func _process(delta:float):
	# VISION
	var remove_idx = []
	for i in range(visions.size()):
		var from = visions[i][0]
		var rd = visions[i][1]
		
		visions[i][2] -= delta
		var time = visions[i][2]
		
		generate_tile(from)
		
		for dst in range(0, rd+1):
			if time <= vision_per_rd_time * (dst):
				for pos in get_adjacent_tiles(from, rd-dst):
					generate_tile(pos)
		
		if visions[i][2] <= 0:
			remove_idx.append(i)
			
	remove_idx.invert()
	for idx in remove_idx:
		visions.remove(idx)
		
	# too much lag
	if Engine.editor_hint:
		return
		
	# TICK
	tick_time_left -= delta
	time += delta
	while tick_time_left <= 0:
		reset_tick_time_left()
		var cells = map_landscape.get_used_cells()
		var cell_id = randi()%cells.size()
		var cell = cells[cell_id]

		var landscape = landscapes[cell]
		var has_block = blocks.has(cell) and blocks[cell] != null
		var block = null
		if has_block:
			block = blocks[cell]
		
		if print_ticking:
			var print_txt = "ticking after " + str(avg_tick_time_of_one_tile / float(map_landscape.get_used_cells().size())) + "secs "
			print_txt += str(landscape.get_class()) + " "
			if has_block:
				print_txt += block.get_class()+ " "
			print_txt += " @ " + str(cell) + " time " + str(time) + ""
			p(print_txt)
		
		if !has_block or !blocks[cell].prevents_landscape_tick():
			landscape.tick()
		if has_block:
			blocks[cell].tick()
			
	for landscape in landscapes:
		landscapes[landscape].time_update(time)
	for block in blocks:
		blocks[block].time_update(time)
		

func init_map_gens():
	randomize()
	for name in map_gens_lex:
		var gen = OpenSimplexNoise.new()
		map_gens_lex[name].seed = randi()
		for property_name in map_gens_lex[name]:
			gen[property_name] = map_gens_lex[name][property_name]
		map_gens[name] = gen


func grant_vision(from:Vector2, rd:int):
	visions.append([from, rd, rd*vision_per_rd_time])
	if rd > 1:
		var particle = nth.ParticlesVision.instance().init(rd, calc_px_pos_on_tile(from))
		$Navigation2D/UIHolder.call_deferred("add_child", particle)
	
	
func generate_preset_tile(map_pos, landscape_id, block_id):
	print("## Map ## loading preset " + str(map_pos) + " " + str(landscape_id) + "/" + str(block_id))
	
	cell_infos[map_pos].height = landscape_id / layer_offset
	cell_infos[map_pos].precise_height = cell_infos[map_pos].height + 0.75
	landscape_id %= layer_offset
	block_id %= layer_offset
	
	var info = lex.get_info_on_landscape_tile_id(landscape_id)
	landscapes[map_pos] = info.class.new().init(self, map_pos, cell_infos[map_pos], info.args, nth)
	
	if block_id >= 0:
		info = lex.get_info_on_block_tile_id(block_id)
		blocks[map_pos] = info.class.new().init(self, map_pos, cell_infos[map_pos], info.args, nth)

func create_cell_info(cell_pos:Vector2):
	
	# calc height
	var maxHeight = 0.23
	var rawHeight = map_gens.height.get_noise_2dv(cell_pos)
	# cap [-1, 1] to [-0.21, 0.21]
	var preciseHeight = min(maxHeight, max(-maxHeight, rawHeight))
	# linearly scale [-0.21, 0.21] to [-1, 1] and then to [0, 1]
	preciseHeight = ((preciseHeight / maxHeight) + 1) / 2.0
	# linearly scale [0, 1] to [1, 0] and then to [6, 0]
	preciseHeight = (1 - preciseHeight) * layers
	
	var isOcean = true
	var oceanMalus = 6
	# Shape island for base of circles
	for circle in map_generation_circles:
		var dst = cell_pos.distance_to(circle[0])
		if dst <= circle[1]:
			oceanMalus = 0
			isOcean = false
		else:
			oceanMalus = min(oceanMalus, 1.8*(dst - circle[1]))
	
	preciseHeight = min(preciseHeight + oceanMalus, 6)
	
	# calc start bonus
	var dst2start = cell_pos.distance_to(start_pos)
	var start_bonus = max(0, 3 - dst2start) / 3.0
	
	# save values in obj
	var cell_info = {}
	cell_info.fertility = map_gens.fertility.get_noise_2dv(cell_pos) + 0.08 * start_bonus
	cell_info.humidity = map_gens.humidity.get_noise_2dv(cell_pos) + 0.08 * start_bonus
	cell_info.precise_height = preciseHeight + (2 - preciseHeight) * start_bonus
	cell_info.height = min(max(floor(cell_info.precise_height), 0), layers-1)
	cell_info.isOcean = isOcean and cell_info.precise_height >= layers-1
	cell_info.river_prev = []
	cell_info.river_next = []

	return cell_info

func set_landscape_by_descriptor(cell_pos:Vector2, descriptor:String):
	# Clear first
	if landscapes.has(cell_pos):
		landscapes[cell_pos].remove()
		
	var info = lex.get_info_on_landscape_descriptor(descriptor)
	landscapes[cell_pos] = info.class.new().init(self, cell_pos, cell_infos[cell_pos], info.args, nth)
	pass
	
func set_block_by_tile_id(cell_pos:Vector2, tile_id:int):
	# Clear first
	if blocks.has(cell_pos):
		blocks[cell_pos].remove()
		
	var info = lex.get_info_on_block_tile_id(tile_id)
	blocks[cell_pos] = info.class.new().init(self, cell_pos, cell_infos[cell_pos], info.args, nth)
	
func set_block_by_descriptor(cell_pos:Vector2, descriptor:String):
	# Clear first
	if blocks.has(cell_pos):
		blocks[cell_pos].remove()
		
	var info = lex.get_info_on_block_descriptor(descriptor)
	blocks[cell_pos] = info.class.new().init(self, cell_pos, cell_infos[cell_pos], info.args, nth)
	pass
	
func generate_tile(var cell_pos:Vector2):
	if landscapes.has(cell_pos):
		return
		
	if Engine.editor_hint:
		
		for c in map_generation_circles:
			if cell_pos == c[0]:
				cell_infos[cell_pos] = create_cell_info(cell_pos)
				set_landscape_by_descriptor(cell_pos, "burnt")
				return
	
	var cell_info = create_cell_info(cell_pos)
	cell_infos[cell_pos] = cell_info
		
	# Preset Structures
	if is_part_of_preset(cell_pos):
		var preset_info = preset_poss[cell_pos]
		#preset_poss[pos+preset_pos] = [preset_id, preset_pos]
		#load_preset_tile(map_pos, preset_id, preset_pos)
		generate_preset_tile(cell_pos, preset_info[0], preset_info[1])
		return
		
	var landscape = ""
	var block = ""

	########################################
	#### LANDSCAPE
	if cell_info.height < layers - 2: # lowest two for sand and water
		if cell_info.fertility < -0.2: 
			landscape = "dirt"
		else:  
			landscape = "grass"
	else:
		if cell_info.height == layers-1:
			landscape = "water"
		if cell_info.height == layers-2:
			landscape = "sand"
	
	if landscape != "":
		set_landscape_by_descriptor(cell_pos, landscape)
	########################################
	
	
	########################################
	#### BLOCKS
	if cell_pos == start_pos:
		block = "house"
		
	if block == "":
		for river in rivers:
			if river.has(cell_pos):
				for i in range(river.size()):
					if river[i] == cell_pos:
						if i > 0:
							cell_info.river_prev.append(river[i-1])
						if i + 1 < river.size():
							cell_info.river_next.append(river[i+1])
							
				block = "river"
		
	if block == "" and landscape == "dirt":
		if int(cell_info.humidity * 100) % 3 == 0:
			block = "bughill"
	
	var mountain_a = (cell_info.height == 0 and cell_info.humidity < -0.15)
	var mountain_b = (cell_info.height == 1 and cell_info.humidity < -0.35)
	if block == "" and (mountain_a or mountain_b):
		block = "mountain"
	
	if (landscape == "grass" or landscape == "sand") and block == "":
		var bamboo_a = landscape == "grass" and cell_info.fertility > 0.16 and cell_info.humidity > 0.16
		var bamboo_b = landscape == "sand" and cell_info.fertility > -0.02 and cell_info.humidity > 0.00
		if bamboo_a or bamboo_b:
			block = "bamboo"
	
	if block == "" and landscape != "water":
		if cell_info.fertility < 0:
			var stone_a = (cell_info.height == 0 or block == "dirt") 	and cell_info.humidity < 0.22
			var stone_b = cell_info.height == 1 						and cell_info.humidity < -0.12
			var stone_c = cell_info.height == 2 						and cell_info.humidity < -0.03
			var stone_d = cell_info.height == 3 						and cell_info.humidity < -0.12
			var stone_e = cell_info.height == 4 						and cell_info.humidity < -0.18
			
			if stone_a or stone_b or stone_c or stone_d or stone_e:
				block = "stone"
	
	if block == "" and landscape == "grass":
		var r = randi()%100
		var vegetation_a = cell_info.fertility > 0.3 and r < 80
		var vegetation_b = cell_info.fertility > 0.1 and r < 60
		var vegetation_c = cell_info.fertility > -0.1 and r < 30
		if vegetation_a or vegetation_b or vegetation_c:
			block = "vegetation"
		
	if block != "":
		set_block_by_descriptor(cell_pos, block)
	
	
func update_tileset_regions():

	# create original tile_cols * tile_rows (for every map)
	var i = 0
	for map in $Navigation2D.get_children():
		if map is TileMap:
			map.tile_set.clear()
			for id in range(0, tile_cols * tile_rows):
				map.tile_set.create_tile(id)
				map.tile_set.tile_set_name(id, "%03d" % id)
				map.tile_set.tile_set_texture(id, landscapeBlocksOverlayTextures[i])
			i += 1	
				#map.tile_set.tile_set_region(id, Rect2(0,0,0,0))
			
			
			for id in map.tile_set.get_tiles_ids():
				# calc region
				var x = region_width * (id % tile_cols)
				var y = region_height * (id / tile_cols)
				var region:Rect2 = Rect2(x, y, region_width, region_height)
				# set this cells region
				map.tile_set.tile_set_region(id, region)
				map.tile_set.tile_set_texture_offset(id, Vector2(-57, -69))
	
	# create extra tiles for height
	for map in all_maps:
		var tile_set = map.tile_set
		var tile_ids = tile_set.get_tiles_ids()
		
		# clear first
		for tile_id in tile_ids:
			if tile_id >= layer_offset:
				tile_set.remove_tile(tile_id)
		
		# then create all layers
		for z in range(0, layers):
			var next_tile_id = (z+1) * layer_offset
			var extra_offset = Vector2(0, (z+1) * layer_px_dst)
			var c = 1.0 - 0.025 * (z+1)
			var extra_col = Color(c,c,c,1)
			for tile_id in tile_ids:
				tile_set.create_tile(next_tile_id)
				tile_set.tile_set_name(next_tile_id, str(next_tile_id))
				tile_set.tile_set_texture(next_tile_id, tile_set.tile_get_texture(tile_id))
				tile_set.tile_set_texture_offset(next_tile_id, tile_set.tile_get_texture_offset(tile_id) + extra_offset)
				tile_set.tile_set_region(next_tile_id, tile_set.tile_get_region(tile_id))
				
				if map != map_overlay:
					tile_set.tile_set_modulate(next_tile_id, extra_col)
				next_tile_id += 1

func calc_px_pos_on_tile(tile_pos):
	var px_pos = map_landscape.map_to_world(tile_pos)
	if cell_infos.has(tile_pos):
		px_pos.y += cell_infos[tile_pos].height * layer_px_dst 
	return px_pos
	
func calc_closest_tile_from(tile_pos):
	var center_pos = map_overlay.world_to_map(tile_pos + map_overlay.cell_size / 2.0)
	var best_pos = null
	var best_dst = 10000
	
	# select best fitting
	for x in range(center_pos.x - 2, center_pos.x + 3):
		for y in range(center_pos.y - 2, center_pos.y + 3):
			var pos = Vector2(x, y)
			
			if landscapes.has(pos):
				var px_pos = calc_px_pos_on_tile(pos)
				var dst = tile_pos.distance_to(px_pos)
				if dst < best_dst:
					best_dst = dst
					best_pos = pos
	return best_pos
	
func are_tiles_adjacent(a:Vector2, b:Vector2):
	var c1 = a.x == b.x and abs(a.y - b.y) == 1
	var c2 = abs(a.x - b.x) == 1 and a.y == b.y
	var c3 = int(round(abs(a.x))) % 2 == 0 and abs(a.x - b.x) == 1 and a.y-1 == b.y
	var c4 = int(round(abs(a.x))) % 2 == 1 and abs(a.x - b.x) == 1 and a.y+1 == b.y
	return c1 or c2 or c3 or c4
	
func get_adjacent_tiles(a:Vector2,rd:int=1):
	var tiles_dic = {a:true}
	
	for dst in range(rd):
		var add_to_tiles_dic = {}
		for tile in tiles_dic:
			for y in range(tile.y - 1, tile.y + 2):
				for x in range(tile.x - 1, tile.x + 2):
					var b = Vector2(x, y)
					if are_tiles_adjacent(tile, b):
						add_to_tiles_dic[b] = true
		for tile in add_to_tiles_dic:
			tiles_dic[tile] = true
	
	# convert to array
	var tiles = []; for tile in tiles_dic: if tile != a: tiles.append(tile)
	return tiles
	
func reset_tick_time_left():
	tick_time_left += avg_tick_time_of_one_tile / float(map_landscape.get_used_cells().size())
	
func show_homes():
	pass
	#for panda in get_tree().get_nodes_in_group("panda"):
	#	map_overlay.set_cellv(panda.home_pos, 0 + layer_offset * cell_infos[panda.home_pos].height)

func p(obj):
	if print_ticking:
		print("## Ticking ## " + str(obj))
		
static func y(c, a, b):
	if c:
		return a
	else:
		return b
