extends "Landscape.gd"

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
	return 10

func tick():
	pass

func time_update(time:float):
	var s = sin(time * 2.0*PI / LandscapeWater.TIDE_TIME)
	var deep = cell_pos3.z == 3
	
	var humidity_bonus = 1 * (humidity + 1) / 2.0 # norm to [0, 1] and then to [0, 0.5]
	if deep and s > -0.4 + humidity_bonus:
		conv()
		return
	if !deep and s > 0.4 + humidity_bonus:
		conv()
		return
	

func conv():
	map.landscapes[Vector2(cell_pos3.x, cell_pos3.y)] = LandscapeWater.new().initOverload(map, cell_pos3, LandscapeWater, LandscapeSand, humidity) # dirt

func can_spread_grass():
	return true # TODO
	
func get_speed_factor():
	return 0.9
	
func can_build_on(_map, _cell_pos):
	return false