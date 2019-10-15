extends "Block.gd"


func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 4*6
	
func is_passable():
	return false