extends "Block.gd"

func get_class(): return "BlockTower"


func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	map.grant_vision(cell_pos, 4)
	return self
	
func get_tile_id():
	return 4 + 4*12

func get_speed_factor():
	return 2.0
	
func multiple_in_one_path_allowed():
	return true
	
func get_build_time():
	return 10.0
	
func ressource_name_or_null():
	return null

