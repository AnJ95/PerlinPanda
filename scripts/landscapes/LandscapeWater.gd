extends "Landscape.gd"

const TIDE_TIME = 40

var LandscapeWater
var LandscapeSand
var humidity

func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func initOverload(map, cell_pos3, LandscapeWater, LandscapeSand, humidity):
	.init(map, cell_pos3)
	self.LandscapeWater = LandscapeWater
	self.LandscapeSand = LandscapeSand
	self.humidity = humidity
	
	return self
	
func get_tile_id():
	return 15

func tick():
	pass

var anim_time = 0.5
var anim_time_left = 0.0
var last_time = 0.0

var cur_anim_tile_id = get_tile_id()
var cur_water_level = 2
func time_update(time:float):
	
	anim_time_left -= (time - last_time)
	if anim_time_left <= 0:
		anim_time_left = anim_time
		
		cur_anim_tile_id += 1
		if cur_anim_tile_id > 19:
			cur_anim_tile_id = get_tile_id()
		
	last_time = time
	
	var s = sin(time * 2.0*PI / TIDE_TIME)
	var deep = (cell_pos3.z == 3)
	
	var humidity_bonus = 1 * (humidity + 1) / 2.0 # norm to [0, 1] and then to [0, 0.5]
	
	if deep: 
		if s > -0.4 + humidity_bonus:
			cur_water_level = 3
		if s > 0.4 + humidity_bonus:
			cur_water_level = 2
	
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	map.map_landscape.set_cellv(cell_pos, cur_anim_tile_id + cur_water_level * map.tile_height_id_dst)
		
	if deep and s < -0.4 + humidity_bonus:
		conv()
		return
	if !deep and s < 0.4 + humidity_bonus:
		conv()
		return
	

func conv():
	map.landscapes[Vector2(cell_pos3.x, cell_pos3.y)] = LandscapeSand.new().initOverload(map, cell_pos3, LandscapeWater, LandscapeSand, humidity) # dirt

func can_spread_grass():
	return true # TODO
	
func get_speed_factor():
	return 0.25
	
func can_build_on(_map, _cell_pos):
	return false