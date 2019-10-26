extends "Block.gd"

var is_smoking = false
var smoking_start_time = 0.0
const SMOKE_TIME = 60.0

func get_class(): return "BlockSmoker"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 5 + 6*12

func get_speed_factor():
	return 1.3
	
func get_build_time():
	return 8.0
	
func ressource_name_or_null():
	return null
	
func time_update(time:float):
	# start smoking if not before and leaves left
	if !is_smoking:
		if inventory.has("leaves", 1):
			is_smoking = true
			set_particle_emitting(true)
			smoking_start_time = map.time

	if is_smoking:
		if time - smoking_start_time > SMOKE_TIME:
			is_smoking = false
			set_particle_emitting(false)
			inventory.add("leaves", - 1)
		else:
			var pos = map.calc_px_pos_on_tile(cell_pos)
			for bug in map.get_tree().get_nodes_in_group("bug"):
				if pos.distance_squared_to(bug.position) <= (2*105)*(2*105) and pos.distance_to(bug.position) <= (2*105):
					var pandas = map.get_tree().get_nodes_in_group("panda")
					if pandas.size() > 0:
						bug.stepped_on(null)
						inventory.add("bamboo", bug.inventory.get("bamboo"))

func panda_in_center(panda):
	.panda_in_center(panda)
	if panda.home_pos != cell_pos and panda.perform_next_action():
		var resUpdater = panda.get_next_ressource_updater()
		
		var resUpdaterLeaves = 99; if resUpdater != null and resUpdater.ressources.has("leaves"): resUpdaterLeaves = resUpdater.ressources["leaves"]
		var can_get = inventory.get_free("leaves")
		var taken = panda.inventory.try_take("leaves", min(resUpdaterLeaves, can_get))
		inventory.add("leaves", taken)
		
		panda.inventory.add("bamboo", inventory.try_take("bamboo", 99))

################################################
### PARTICLES
func get_particle_instance_or_null():
	var inst = nth.ParticlesSmoke.instance()
	return inst

func set_particle_emitting(emit:bool):
	.set_particle_emitting(emit)
	if particle_inst != null:
		particle_inst.get_node("Fire").visible = emit
	
################################################
### FIRE
func get_prob_lightning_strike():
	return 0
func get_fire_increase_time():
	return 4
	
################################################
### INVENTORY
func has_inventory():
	return true
func adjust_inventory(inventory):
	inventory.show_if_0 = true
	inventory.show_max = true
	return inventory
func inventory_max_values():
	return {"bamboo":3,"stone":0,"leaves":5}