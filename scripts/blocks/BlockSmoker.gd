extends "Block.gd"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 41

func get_speed_factor():
	return 1.3
	
func get_build_time():
	return 8.0
	
func ressource_name_or_null():
	return null

