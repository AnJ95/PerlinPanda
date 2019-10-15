extends "Landscape.gd"


func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	

func get_tile_id():
	return 6 # TODO  6 = map.tile_cols
	
func get_max_var():
	return 4
	
func tick():
	var percent = get_adjacent_spreadable_percent()
	if randi()%100 / 4.0 < percent:
		print("... spreading hit (" + str(percent) + "%)")
		remove()
		map.set_landscape_by_descriptor(cell_pos, "grass")
	else:
		print("... spreading miss (" + str(percent) + "%)")
				
	#print("... increased stock of ressource " + ressource_name_or_null()

func get_speed_factor():
	return 1