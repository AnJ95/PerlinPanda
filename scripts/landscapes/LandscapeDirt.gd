extends "Landscape.gd"

var LandscapeGrass
var LandscapeDirt

func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt):
	.init(map, cell_pos3)
	
	self.LandscapeGrass = LandscapeGrass
	self.LandscapeDirt = LandscapeDirt
	return self

func get_tile_id():
	return randi()%5+5
	
func tick():
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	var num_spreading = 0
	var num_non_spreading = 0
	for y in range(-cell_pos3.y-4, cell_pos3.y+4):
		for x in range(-cell_pos3.x-4, cell_pos3.x+4):
			var pos = Vector2(x, y)
			if pos == cell_pos:
				continue

			var a = map.map_landscape.map_to_world(cell_pos, false)
			var b = map.map_landscape.map_to_world(pos, false)
			if map.landscapes.has(pos) and map.landscapes[pos] != null:
				if a.distance_to(b) <= 105:
					if map.landscapes[pos].can_spread_grass():
						num_spreading += 1
					else:
						num_non_spreading += 1
	
	if num_spreading > 0:
		var prob_to_spread = 100 * (num_spreading / float(num_spreading + num_non_spreading))
		if randi()%100 < prob_to_spread:
			print("... spreading hit (" + str(num_spreading) + "/" + str(num_spreading + num_non_spreading) + " neighbours spreading)")
			remove()
			map.landscapes[cell_pos] = LandscapeGrass.new().initOverload(map, cell_pos3, LandscapeGrass, LandscapeDirt) # grass
		else:
			print("... spreading miss (" + str(num_spreading) + "/" + str(num_spreading + num_non_spreading) + " neighbours spreading)")
				
	#print("... increased stock of ressource " + ressource_name_or_null()

func get_speed_factor():
	return 1