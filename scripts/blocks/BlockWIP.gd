extends "Block.gd"


func get_class(): return "BlockWIP"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	return self

func get_build_time():
	var proto = map.lex.get_proto_block_by_tile_id(args.of)
	return proto.get_build_time()
	
func inst_actual_block():
	map.set_block_by_tile_id(cell_pos, args.of)
	
func get_tile_id():
	return args.of + 12
	
func get_speed_factor():
	return 1.2
	
func ressource_name_or_null():
	return null
	
func panda_in_center(panda):
	.panda_in_center(panda)
	
	if panda.perform_next_action():
		var updater = panda.get_next_ressource_updater()

		if updater != null:
			for ressource in updater.ressources:
				var still_needed = inventory.get_max(ressource) - inventory.get(ressource)
				var wanted = updater.ressources[ressource]
				inventory.add(ressource, panda.inventory.try_take(ressource, min(still_needed, wanted)))
		#else: TODO decision: build if BlockWIP was not present at path making?
		#	panda.inventory.move_to_other(inventory)
		
		var all_ressources = true
		for ressource in inventory.maximums:
			if inventory.get(ressource) != inventory.get_max(ressource):
				all_ressources = false
		
		if all_ressources:
			panda.start_building(self)
	
################################################
### FIRE
func get_prob_fire_catch():
	return 50
func get_fire_increase_time():
	return 8
	
################################################
### INVENTORY
func adjust_inventory(inventory):
	inventory.show_max = true
	inventory.show_if_0 = true
	return inventory
func has_inventory():
	return true
func inventory_max_values():
	var buildManager = map.get_tree().get_nodes_in_group("build_manager")
	if buildManager.size() > 0:
		return buildManager[0].get_price_by_block_id(args.of)
	else:
		return {}