extends "Block.gd"


var spawns_left = 2

	
func spawn():
	if spawns_left > 0:
		var bug = nth.Bug.instance().prep(map, cell_pos, self)
		map.get_parent().call_deferred("add_child", bug)
		spawns_left -= 1
	
func bug_has_died():
	spawns_left += 1
	
func get_tile_id():
	return  30
	
func get_max_var():
	return 1
	
func get_speed_factor():
	return 0.8

func prevents_landscape_tick():
	return true
	
func tick():
	if randi()%100 < 80:
		spawn()
		
func panda_in_center(panda):
	.panda_in_center(panda)
	map.blocks.erase(cell_pos)
	map.map_blocks.set_cellv(cell_pos, -1)