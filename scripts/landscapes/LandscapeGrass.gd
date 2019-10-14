extends "Landscape.gd"

var LandscapeGrass
var LandscapeDirt

var durability = 0

func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt):
	.init(map, cell_pos3)
	durability = randi()%1+4 # [4,8]
	self.LandscapeGrass = LandscapeGrass
	self.LandscapeDirt = LandscapeDirt
	return self
	
func get_tile_id():
	return randi()%5+0

func panda_in_center(_panda):
	durability -= 1
	if durability <= 0:
		remove()
		var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
		map.landscapes[cell_pos] = LandscapeDirt.new().initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt) # dirt
	pass

func tick():
	pass

func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.75