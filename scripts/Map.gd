tool
extends Node2D

signal generate_next

export var preprocess_tile_sets_in_editor = true
export var show_case_map_in_editor = true
export var show_case_size:int = 4
export var is_preset = false

# Consts
export var tile_cols:int = 5
export var tile_rows:int = 6
var layer_offset:int = 100

export var region_width:int = 116
export var region_height:int = 200

export var avg_tick_time_of_one_tile:float = 50

export(Array, Texture) var landscapeBlocksOverlayTextures

var layers = 6
var layer_px_dst = 17

var time = 0

# State
var cur_gen = 0
var blocks = {}
var landscapes = {}
var cell_infos = {}
var tick_time_left = 1000

# Nodes
onready var map_landscape:TileMap = $Navigation2D/MapLandscape
onready var map_blocks:TileMap = $Navigation2D/MapBlocks
onready var map_overlay:TileMap = $Navigation2D/MapOverlay
onready var all_maps = [map_landscape, map_blocks, map_overlay]

onready var lex = preload("res://scripts/Lex.gd").new()

onready var nth = {"Panda":preload("res://scenes/Panda.tscn"),"Bug":preload("res://scenes/Bug.tscn")}

# OpenSimplex
var map_gens_lex = {
	"height" : {"octaves": 4, "period": 9.0, "persistence": 0.8, "seed": 31},
	"fertility" : {"octaves": 4, "period": 0.2, "persistence": 0.8, "seed": 32},
	"humidity" : {"octaves": 4, "period": 4.0, "persistence": 0.8, "seed": 33}
}
var map_gens = {}

func _ready():
	init_map_gens()
	
	connect("generate_next", self, "generate_next")
	
	if Engine.editor_hint and preprocess_tile_sets_in_editor:
		update_tileset_regions()
	
	if !is_preset:
		# Clear everything
		map_landscape.clear()
		map_blocks.clear()
		map_overlay.clear()
		for panda in get_tree().get_nodes_in_group("panda"):
			panda.queue_free()
		
		prepare_presets()
		generate_tile(Vector2())
		show_homes()
	
		
			
	if Engine.editor_hint and show_case_map_in_editor:
		generate_next(Vector2(), show_case_size)

	

var preset_cache = {}
var preset_poss = {}

func prepare_presets():
	preset_cache = {}
	preset_poss = {}
	for i in range(0, 10):
		var r = 9 + i * 4
		var a = i * 360 * 0.618
		var pos = Vector2(r, 0).rotated(a)
		var cell_pos = Vector2(int(round(pos.x)), int(round(pos.y))) # will be [0,0] of the preset
		cell_pos = Vector2(cell_pos.x-int(cell_pos.x)%2, cell_pos.y-int(cell_pos.y)%2)

		var preset_id = randi()%6 + 1 #[1,6]
		var preset = ensure_cache_singleton(preset_id)
		if preset.has_node("Map"):
			preset = preset.get_node("Map")
		var preset_landscape = preset.get_node("Navigation2D/MapLandscape")
		var preset_blocks = preset.get_node("Navigation2D/MapBlocks")
		# take a Dictionary an fill it with all blocks that are part of any preset
		
		for preset_pos in preset_landscape.get_used_cells():
			var landscape_id = preset_landscape.get_cellv(preset_pos)
			var block_id = preset_blocks.get_cellv(preset_pos)
			preset_poss[cell_pos+preset_pos] = [landscape_id, block_id]
		
func is_part_of_preset(pos):
	return preset_poss.has(pos)

func ensure_cache_singleton(preset_id):
	if !preset_cache.has(preset_id):
		preset_cache[preset_id] = load("res://scenes/presets/%02d.tscn" % preset_id).instance()
	return preset_cache[preset_id]
	

	
func _process(delta:float):
	# too much lag
	if Engine.editor_hint:
		return
		
	tick_time_left -= delta
	time += delta
	if tick_time_left <= 0:
		reset_tick_time_left()
		var cells = map_landscape.get_used_cells()
		var cell_id = randi()%cells.size()
		var cell = cells[cell_id]
		
		#print("ticking " + str(cell) + "...")
		if !blocks.has(cell) or !blocks[cell].prevents_landscape_tick():
			landscapes[cell].tick()
		if blocks.has(cell) and blocks[cell] != null:
			blocks[cell].tick()
			
	for landscape in landscapes:
		landscapes[landscape].time_update(time)
		

func init_map_gens():
	for name in map_gens_lex:
		var gen = OpenSimplexNoise.new()
		for property_name in map_gens_lex[name]:
			gen[property_name] = map_gens_lex[name][property_name]
		map_gens[name] = gen
	
func generate_next(from:Vector2, rd:int):
	cur_gen += 1
		
	for y in range(-rd-1, rd+2):
		for x in range(-rd-1, rd+2):
			var pos = from + Vector2(x, y)
			if landscapes.has(pos):
				continue
			
			var a = map_landscape.map_to_world(from)
			var b = map_landscape.map_to_world(pos)
			
			if a.distance_to(b) <=  rd * 105:
				generate_tile(pos)
				
	reset_tick_time_left()
	
func generate_preset_tile(map_pos, landscape_id, block_id):
	print("loading preset " + str(map_pos) + " " + str(landscape_id) + "/" + str(block_id))
	
	cell_infos[map_pos].height = landscape_id / layer_offset
	landscape_id %= layer_offset
	block_id %= layer_offset
	
	var info = lex.get_info_on_landscape_tile_id(landscape_id)
	landscapes[map_pos] = info.class.new().init(self, map_pos, cell_infos[map_pos], info.args, nth)
	
	if block_id >= 0:
		info = lex.get_info_on_block_tile_id(block_id)
		blocks[map_pos] = info.class.new().init(self, map_pos, cell_infos[map_pos], info.args, nth)

func create_cell_info(cell_pos:Vector2):
	# Create this tiles info object
	var cell_info = {}
	
	var rawHeight = map_gens.height.get_noise_2dv(cell_pos)
	var height = 0
	if rawHeight < 0.21:
		height = 1
	if rawHeight < 0.11:
		height = 2
	if rawHeight < -0.00:
		height = 3
	if rawHeight < -0.11:
		height = 4
	if rawHeight < -0.21:
		height = 5
	if cell_pos.distance_to(Vector2()) <= 1.25:
		height = 2
		
	var start_bonus = 0.1 * max(0, 2 - cell_pos.distance_to(Vector2()))
	
	cell_info.fertility = map_gens.fertility.get_noise_2dv(cell_pos) + start_bonus
	cell_info.humidity = map_gens.humidity.get_noise_2dv(cell_pos) + start_bonus
	cell_info.height = height
	
	return cell_info

func set_landscape_by_descriptor(cell_pos:Vector2, descriptor:String):
	var info = lex.get_info_on_landscape_descriptor(descriptor)
	landscapes[cell_pos] = info.class.new().init(self, cell_pos, cell_infos[cell_pos], info.args, nth)
	pass
	
func set_block_by_tile_id(cell_pos:Vector2, tile_id:int):
	var info = lex.get_info_on_block_tile_id(tile_id)
	blocks[cell_pos] = info.class.new().init(self, cell_pos, cell_infos[cell_pos], info.args, nth)
func set_block_by_descriptor(cell_pos:Vector2, descriptor:String):
	var info = lex.get_info_on_block_descriptor(descriptor)
	blocks[cell_pos] = info.class.new().init(self, cell_pos, cell_infos[cell_pos], info.args, nth)
	pass
	
func generate_tile(var cell_pos:Vector2):
	if landscapes.has(cell_pos):
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
	if cell_pos == Vector2():
		block = "house"
		
	if landscape == "dirt":
		if int(cell_info.humidity * 100) % 3 == 0:
			block = "bughill"
	
	var mountain_a = (cell_info.height == 0 and cell_info.humidity < -0.15)
	var mountain_b = (cell_info.height == 1 and cell_info.humidity < -0.35)
	if block == "" and (mountain_a or mountain_b):
		block = "mountain"
	
	if (landscape == "grass" or landscape == "sand") and block == "":
		var bamboo_a = landscape == "grass" and cell_info.fertility > 0.21 and cell_info.humidity > 0.21
		var bamboo_b = landscape == "sand" and cell_info.fertility > 0.02 and cell_info.humidity > 0.02
		if bamboo_a or bamboo_b:
			block = "bamboo"
	
	if block == "" and landscape != "water":
		if cell_info.fertility < 0:
			var stone_a = (cell_info.height == 0 or block == "dirt") 	and cell_info.humidity < 0.22
			var stone_b = cell_info.height == 1 						and cell_info.humidity < -0.12
			var stone_c = cell_info.height == 2 						and cell_info.humidity < -0.06
			var stone_d = cell_info.height == 3 						and cell_info.humidity < -0.14
			var stone_e = cell_info.height == 4 						and cell_info.humidity < -0.20
			
			if stone_a or stone_b or stone_c or stone_d or stone_e:
				block = "stone"
			
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
	
func get_adjacent_tiles(a:Vector2):
	var tiles = []
	for y in range(a.y - 1, a.y + 2):
		for x in range(a.x - 1, a.x + 2):
			var b = Vector2(x, y)
			if are_tiles_adjacent(a, b):
				tiles.append(b)
	return tiles
	
func reset_tick_time_left():
	var num_tiles = map_landscape.get_used_cells().size()
	tick_time_left = avg_tick_time_of_one_tile / float(num_tiles)
	
func show_homes():
	for panda in get_tree().get_nodes_in_group("panda"):
		map_overlay.set_cellv(panda.home_pos, 0 + layer_offset * cell_infos[panda.home_pos].height)