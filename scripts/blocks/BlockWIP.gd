extends "Block.gd"

var actual_block;


func init(map, cell_pos, cell_info, args, nth):
	is_wip = true
	
	.init(map, cell_pos, cell_info, args, nth)


func inst_actual_block():
	map.blocks[cell_pos] = nth.actual_class.init(map, cell_pos, cell_info, args, nth) # TODO actual class
	
func get_tile_id():
	return 4 + 4 * 6
	
func get_speed_factor():
	return 1.2
	
func ressource_name_or_null():
	return null
	
func panda_in_center(panda):
	panda.start_building(self)