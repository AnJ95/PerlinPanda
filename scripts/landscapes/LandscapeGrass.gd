extends "Landscape.gd"

var LandscapeGrass
var LandscapeDirt

var durability = 0
var fertility

func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt, fertility):
	durability = min(4, int(((fertility+1.0)/2.0) * 5))
	self.fertility = fertility
	.init(map, cell_pos3)
	self.LandscapeGrass = LandscapeGrass
	self.LandscapeDirt = LandscapeDirt
	return self
	
func get_tile_id():
	return durability

func panda_in_center(_panda):
	durability -= 1
	if durability <= 0:
		remove()
		var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
		map.landscapes[cell_pos] = LandscapeDirt.new().initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt, fertility) # dirt
	else:
		durability_changed()

func tick():
	var percent = get_adjacent_spreadable_percent()
	if percent / 4.0 > randi()%100:
		print("... grass durability hit (" + str(percent) + "%)")
	else:
		print("... grass durability miss (" + str(percent) + "%)")
		
	durability = min(4, durability + 1)
	durability_changed()
	
func durability_changed():
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	map.map_landscape.set_cellv(cell_pos, get_tile_id() + map.tile_height_id_dst * cell_pos3.z);
	pass

func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.75