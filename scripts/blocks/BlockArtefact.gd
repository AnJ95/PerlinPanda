extends "Block.gd"

var is_activated = false

func get_class(): return "BlockArtefact"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 42

func get_speed_factor():
	return 1.3

func panda_in_center(panda):
	.panda_in_center(panda)
	if !is_activated:
		is_activated = true
		#start particles
		set_particle_emitting(true)
		
		# change tile
		args.var = 1
		update_tile()
		
		# update inventory
		var ressourceManager = map.get_tree().get_nodes_in_group("ressource_manager")
		if ressourceManager.size() > 0:
			ressourceManager[0].add_ressource("artefacts", 1)
			if ressourceManager[0].ressources.artefacts >= ressourceManager[0].ressources.artefacts_max:
				ressourceManager[0].emit_signal("island_restored")
		
			
func get_particle_instance_or_null():
	return nth.ParticlesArtefact.instance()
	
func set_particle_emitting(emit):
	.set_particle_emitting(emit)
	particle_inst.get_node("Particles_oneshot").emitting = emit