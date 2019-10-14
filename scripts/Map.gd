tool
extends Node2D

signal generate_next

# Classes
onready var BlockBamboo = preload("blocks/BlockBamboo.gd")
onready var BlockStone = preload("blocks/BlockStone.gd")
onready var BlockHouse = preload("blocks/BlockHouse.gd")

onready var LandscapeGrass = preload("landscapes/LandscapeGrass.gd")
onready var LandscapeDirt = preload("landscapes/LandscapeDirt.gd")
onready var LandscapeWater = preload("landscapes/LandscapeWater.gd")
onready var LandscapeSand = preload("landscapes/LandscapeSand.gd")

onready var Panda = preload("res://scenes/Panda.tscn")

# Consts
export var tile_cols:int = 5
export var tile_rows:int = 5
export var tile_height_id_dst:int = 100

export var region_width:int = 116
export var region_height:int = 140

export var avg_tick_time_of_one_tile:float = 50

export(Array, Texture) var landscapeBlocksOverlayTextures

var layer_px_dst = 8


# State
var cur_gen = 0
var blocks = {}
var landscapes = {}
var height_layer = {}
var tick_time_left = 1000

# Nodes
onready var map_landscape:TileMap = $Navigation2D/MapLandscape
onready var map_blocks:TileMap = $Navigation2D/MapBlocks
onready var map_overlay:TileMap = $Navigation2D/MapOverlay
onready var all_maps = [map_landscape, map_blocks, map_overlay]


# OpenSimplex
var map_gens_lex = {
	"height" : {"octaves": 4, "period": 7.0, "persistence": 0.8, "seed": 11},
	"fertility" : {"octaves": 4, "period": 1.0, "persistence": 0.8, "seed": 12},
	"humidity" : {"octaves": 4, "period": 4.0, "persistence": 0.8, "seed": 13}
}
var map_gens = {}

func _ready():
	init_map_gens()
	
	connect("generate_next", self, "generate_next")
	#emit_signal("generate_next")
	
	if Engine.editor_hint:
		update_tileset_regions()
	else:
		for map in all_maps:
			var tile_set = map.tile_set
			var tile_ids = tile_set.get_tiles_ids()
			
			for z in range(0, 3):
				var next_tile_id = (z+1) * tile_height_id_dst
				var extra_offset = Vector2(0, (z+1) * layer_px_dst)
				var c = 1.0 - 0.05 * (z+1)
				var extra_col = Color(c,c,c,1)
				for tile_id in tile_ids:
					tile_set.create_tile(next_tile_id)
					tile_set.tile_set_texture(next_tile_id, tile_set.tile_get_texture(tile_id))
					tile_set.tile_set_texture_offset(next_tile_id, tile_set.tile_get_texture_offset(tile_id) + extra_offset)
					tile_set.tile_set_region(next_tile_id, tile_set.tile_get_region(tile_id))
					
					if map != map_overlay:
						tile_set.tile_set_modulate(next_tile_id, extra_col)
					next_tile_id += 1
			
			
	
	# Clear everything
	map_landscape.clear()
	map_blocks.clear()
	map_overlay.clear()
	for panda in get_tree().get_nodes_in_group("panda"):
		panda.queue_free()
	
	generate_tile(Vector2())
	if Engine.editor_hint:
		generate_next(Vector2(), 5)
	#generate_next()
	
func _process(delta:float):
	tick_time_left -= delta
	if tick_time_left <= 0:
		reset_tick_time_left()
		var cells = map_landscape.get_used_cells()
		var cell_id = randi()%cells.size()
		var cell = cells[cell_id]
		
		print("ticking " + str(cell) + "...")
		landscapes[cell].tick()
		if blocks.has(cell) and blocks[cell] != null:
			blocks[cell].tick()
		

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

func reset_tick_time_left():
	var num_tiles = map_landscape.get_used_cells().size()
	tick_time_left = avg_tick_time_of_one_tile / float(num_tiles)
	
	
func generate_tile(var cell_pos:Vector2):
	if landscapes.has(cell_pos):
		return
	var noiseFertility = map_gens.fertility.get_noise_2dv(cell_pos)
	var noiseHumidity = map_gens.humidity.get_noise_2dv(cell_pos)
	var noiseHeight = map_gens.height.get_noise_2dv(cell_pos)
	
	var start_bonus = 0.1 * max(0, 2 - cell_pos.distance_to(Vector2()))
	noiseFertility += start_bonus
	noiseHumidity += start_bonus
	
	
	var landscape = ""
	var block = ""
	
	var height = 0
	if noiseHeight < -0.1:
		height = 1
	if noiseHeight < -0.2:
		height = 2
	if noiseHeight < -0.3:
		height = 3
		
	if cell_pos == Vector2():
		height = 0
	
	var cell_pos3 = Vector3(cell_pos.x, cell_pos.y, height)
	height_layer[cell_pos] = height
	
	# landscape
	if height <= 1:
		if noiseFertility < -0.2: 
			landscapes[cell_pos] = LandscapeDirt.new().initOverload(self, cell_pos3, LandscapeGrass, LandscapeDirt)
			landscape = "dirt"
		else:  
			landscapes[cell_pos] = LandscapeGrass.new().initOverload(self, cell_pos3, LandscapeGrass, LandscapeDirt)
			landscape = "grass"
	else: # sand
		if height == 3:
			landscapes[cell_pos] = LandscapeWater.new().initOverload(self, cell_pos3, LandscapeWater, LandscapeSand, noiseHumidity)
			landscape = "water"
		if height == 2:
			landscapes[cell_pos] = LandscapeSand.new().initOverload(self, cell_pos3, LandscapeWater, LandscapeSand, noiseHumidity)
			landscape = "sand"
		
	
	if cell_pos == Vector2():
		block = "house"
		blocks[cell_pos] = BlockHouse.new().initOverload(self, cell_pos3, Panda)
	
	# ressources
	var prob_bamboo = 0
	var bamboo_fertility = 0
	if landscape == "grass" and block == "" and cell_pos != Vector2():
		if noiseFertility > 0.24 and noiseHumidity > 0.24:
			prob_bamboo = 90
			bamboo_fertility = 3
		elif noiseFertility > 0.18 and noiseHumidity > 0.18:
			prob_bamboo = 80
			bamboo_fertility = 2
		elif noiseFertility > 0.04 and noiseHumidity > 0.04:
			prob_bamboo = 70
			bamboo_fertility = 1
		
		if randi()%100 < prob_bamboo:
			blocks[cell_pos] = BlockBamboo.new().initOverload(self, cell_pos3, bamboo_fertility)
			block = "bamboo"
	
	if block == "" and landscape != "water" and cell_pos != Vector2():
		var prob_stone = 0
		var stone_stock = 0
		if noiseFertility < -0.1 and noiseHumidity < -0.1:
			prob_stone = 40
			stone_stock = 3
		elif noiseFertility < 0.0 and noiseHumidity < 0.0:
			prob_stone = 35
			stone_stock = 2
		elif noiseFertility < 0.2 and noiseHumidity < 0.2:
			prob_stone = 30
			stone_stock = 1
		if landscape == "dirt":
			prob_stone += 20
			
		if stone_stock > 0 and randi()%100 < prob_stone:
			blocks[cell_pos] = BlockStone.new().initOverload(self, cell_pos3, stone_stock)
			block = "stone"
	
	
func update_tileset_regions():
	
	var i = 0
	for map in $Navigation2D.get_children():
		if map is TileMap:
			map.tile_set.clear()
			for id in range(0, tile_cols * tile_rows):
				map.tile_set.create_tile(id)
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
	