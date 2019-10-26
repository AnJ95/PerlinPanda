extends "Block.gd"

const PROB_TO_SPAWN = 100.0

var spawn_num = 0

func get_class(): return "BlockBugHill"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func spawn():
	if spawn_num <= args.var:
		var bug = nth.Bug.instance().prep(map, cell_pos, self, nth)
		if get_weather().get_day_bonus() < 0.3: # only spawn at night
			get_bug_holder().call_deferred("add_child", bug)
			spawn_num += 1
	
func bug_has_died():
	spawn_num -= 1
	
func get_tile_id():
	return  5*12
	
func get_max_var():
	return 0
	
func get_speed_factor():
	return 0.8

func prevents_landscape_tick():
	return true
	
func tick():
	.tick()
	if randi()%100 <= PROB_TO_SPAWN:
		spawn()

func upgrade():
	args.var = min(args.var + 1, 2)
	update_tile()
	
func downgrade():
	args.var -= 1
	
	var particle = nth.ParticlesBugHillStomped.instance()
	particle.position = map.calc_px_pos_on_tile(cell_pos)
	get_bug_holder().add_child(particle)
	particle.emitting = true
	
	if args.var < 0:
		stomped()
	else:
		update_tile()

func stomped():
	remove()
	
func panda_in_center(panda):
	.panda_in_center(panda)
	downgrade()
	
################################################
### FERTILITY
func get_fertility_bonus(): return -0.15
	