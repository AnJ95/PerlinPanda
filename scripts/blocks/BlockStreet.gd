extends "Block.gd"

func get_class(): return "BlockStreet"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 4 + 2*12

func get_speed_factor():
	return 2.6
	
func multiple_in_one_path_allowed():
	return true
	
func get_build_time():
	return 5.0

func shields_landscape_durability():
	return true

