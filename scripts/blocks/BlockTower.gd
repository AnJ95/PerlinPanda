extends "Block.gd"

func get_class(): return "BlockTower"

const max_dst = 3.5
const dst_speed = 0.8
var start_time = -1.0
func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	
	return self

func time_update(time:float):
	if start_time < 0:
		start_time = time
	map.generate_next(cell_pos,min((time - start_time) * dst_speed, max_dst))
	pass
	
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

