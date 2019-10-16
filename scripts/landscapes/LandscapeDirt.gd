extends "Landscape.gd"


func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 6 # TODO  6 = map.tile_cols
	
func get_max_var():
	return 4
	
func tick():
	# Spawn bug hill
	if !map.blocks.has(cell_pos) and 30 > randi()%100: 
		map.set_block_by_descriptor(cell_pos, "bughill")
	
	# Transform to grass
	var percent = get_adjacent_spreadable_percent()
	if randi()%100 < percent / 2.0:
		print("... spreading hit (" + str(percent) + "%)")
		remove()
		map.set_landscape_by_descriptor(cell_pos, "grass")
	else:
		print("... spreading miss (" + str(percent) + "%)")
				
	#print("... increased stock of ressource " + ressource_name_or_null()

func get_speed_factor():
	return 1