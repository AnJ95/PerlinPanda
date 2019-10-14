extends "Landscape.gd"

var LandscapeGrass
var LandscapeDirt

var fertility

func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt, fertility):
	self.fertility = fertility
	.init(map, cell_pos3)
	
	self.LandscapeGrass = LandscapeGrass
	self.LandscapeDirt = LandscapeDirt
	return self

func get_tile_id():
	return randi()%5+6 # TODO  6 = map.tile_cols
	
func tick():
	var percent = get_adjacent_spreadable_percent()
	if randi()%100 / 4.0 < percent:
		print("... spreading hit (" + str(percent) + "%)")
		remove()
		var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
		map.landscapes[cell_pos] = LandscapeGrass.new().initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt, fertility) # grass
	else:
		print("... spreading miss (" + str(percent) + "%)")
				
	#print("... increased stock of ressource " + ressource_name_or_null()

func get_speed_factor():
	return 1