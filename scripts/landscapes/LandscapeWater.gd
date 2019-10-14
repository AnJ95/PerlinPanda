extends "Landscape.gd"

var LandscapeWater
var LandscapeSand


func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func initOverload(map, cell_pos3, LandscapeWater, LandscapeSand, humidity):
	.init(map, cell_pos3)
	self.LandscapeWater = LandscapeWater
	self.LandscapeSand = LandscapeSand
	return self
	
func get_tile_id():
	return 15

func tick():
	pass
	
var time = 0.0
func _process(delta:float):
	time += delta
	pass
	

func conv():
	map.landscapes[Vector2(cell_pos3.x, cell_pos3.y)] = LandscapeSand.new().initOverload(map, cell_pos3, LandscapeWater, LandscapeSand) # dirt

func can_spread_grass():
	return true # TODO
	
func get_speed_factor():
	return 0.25
	
func can_build_on(_map, _cell_pos):
	return false