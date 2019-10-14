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
	return randi()%5+0

func tick():
	pass

var time = 0.0
func _process(delta:float):
	time += delta
	pass
	

func conv():
	map.landscapes[Vector2(cell_pos3.x, cell_pos3.y)] = LandscapeWater.new().initOverload(map, cell_pos3, LandscapeWater, LandscapeSand, humidity) # dirt

func can_spread_grass():
	return true # TODO
	
func get_speed_factor():
	return 0.9