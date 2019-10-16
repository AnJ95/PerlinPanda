extends "Block.gd"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 16

func get_speed_factor():
	return 2.6
	
func get_build_time():
	return 5.0
	
func ressource_name_or_null():
	return null

