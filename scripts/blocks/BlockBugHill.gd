extends "Block.gd"


var spawn_num = 0

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func spawn():
	if spawn_num <= args.var:
		var bug = nth.Bug.instance().prep(map, cell_pos, self)
		map.get_parent().call_deferred("add_child", bug)
		spawn_num += 1
	
func bug_has_died():
	spawn_num -= 1
	
func get_tile_id():
	return  30
	
func get_max_var():
	return 0
	
func get_speed_factor():
	return 0.8

func prevents_landscape_tick():
	return true
	
func tick():
	if randi()%100 < 100:
		spawn()

func upgrade():
	args.var = min(args.var + 1, 2)
	update_tile()
	
func downgrade():
	args.var -= 1
	if args.var < 0:
		remove()
	else:
		update_tile()
	
func panda_in_center(panda):
	.panda_in_center(panda)
	downgrade()
	