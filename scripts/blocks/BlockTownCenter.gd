extends "Block.gd"


func get_class(): return "BlockTownCenter"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 6 + 1*12 + map.y(active, -12, 0)

func get_speed_factor(_panda):
	return 2.0
	
func multiple_in_one_path_allowed():
	return true
	
func get_build_time():
	return 10.0

func shields_landscape_durability():
	return true


func panda_in_center(panda):
	.panda_in_center(panda)
	if panda.perform_next_action():
		var resUpdater = panda.get_next_ressource_updater()
		
		var resUpdaterBamboo = 99; if resUpdater != null and resUpdater.ressources.has("bamboo"): resUpdaterBamboo = resUpdater.ressources["bamboo"]
		var can_get = inventory.get_free("bamboo")
		var taken = panda.inventory.try_take("bamboo", min(resUpdaterBamboo, can_get))
		inventory.add("bamboo", taken)
		
################################################
### EFFECT
var active = false 
var effect_start_time
const EFFECT_TIME = 60
var effect_nodes = []

func time_update(time:float):
	
	if !active:
		if inventory.has("bamboo", 1):
			active = true
			update_tile()
			set_particle_emitting(true)
			effect_start_time = map.time
			
			for tile in get_affected_tiles():
				var inst = nth.WalkBoostEffect.instance().init(map, tile, self)
				effect_nodes.append(inst)
				get_middle_holder().add_child(inst)
				

	if active:
		if time - effect_start_time > EFFECT_TIME:
			active = false
			update_tile()
			set_particle_emitting(false)
			for node in effect_nodes:
				node.queue_free()
			effect_nodes = []
			inventory.add("bamboo", -1)

func get_affected_tiles():
	var affected_tiles = [cell_pos]
	var to_check = [cell_pos]
	while to_check.size() > 0:
		var next_to_check = []
		for check_pos in to_check:
			for adj in map.get_adjacent_tiles(check_pos):
				if affected_tiles.find(adj) == -1:
					if map.blocks.has(adj) and map.blocks[adj].get_class() == "BlockStreet":
						affected_tiles.append(adj)
						next_to_check.append(adj)
		to_check = next_to_check
	return affected_tiles

################################################
func remove():
	.remove()
	for node in effect_nodes:
		node.queue_free()
		
################################################
### INVENTORY
func has_inventory():
	return true
func adjust_inventory(inventory):
	inventory.show_if_0 = true
	inventory.show_max = true
	return inventory
func inventory_max_values():
	return {"bamboo":1,"stone":0,"leaves":0}

