extends "Block.gd"

var is_smoking = false
var smoking_start_time = 0.0
const SMOKE_TIME = 60.0

var particle_inst

func get_class(): return "BlockSmoker"

func init(map, cell_pos, cell_info, args, nth):
	particle_inst = nth.ParticlesSmoke.instance()
	particle_inst.position = map.calc_px_pos_on_tile(cell_pos)
	set_particle_emitting(false)
	map.add_child(particle_inst)
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 41

func get_speed_factor():
	return 1.3
	
func get_build_time():
	return 8.0
	
func ressource_name_or_null():
	return null
	
func time_update(time:float):
	if is_smoking:
		if time - smoking_start_time > SMOKE_TIME:
			is_smoking = false
			set_particle_emitting(false)
		else:
			var pos = map.calc_px_pos_on_tile(cell_pos)
			for bug in map.get_tree().get_nodes_in_group("bug"):
				if pos.distance_squared_to(bug.position) <= (2*105)*(2*105) and pos.distance_to(bug.position) <= (2*105):
					bug.stepped_on(map.get_tree().get_nodes_in_group("panda")[0])

func panda_in_center(panda):
	if !is_smoking:
		if panda.inventory.has("leaves") and panda.inventory.leaves >= 1:
			panda.add_to_inventory("leaves", -1)
			is_smoking = true
			set_particle_emitting(true)
			smoking_start_time = map.time
			
func set_particle_emitting(emit):
	particle_inst.emitting = emit
	particle_inst.get_node("Particles_inner").emitting = emit