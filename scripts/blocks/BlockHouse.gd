extends "Block.gd"

var panda

func get_class(): return "BlockHouse"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	
	# DEBUG STUFF
	if map.debug_mode:
		map.grant_vision(cell_pos, 3)
		for inv in [inventory, scheduled_inventory]:
			for res in ["bamboo", "stone", "leaves"]:
				inv.add(res, 20)
	else:
		map.grant_vision(cell_pos, 3)
	
	if !Engine.editor_hint:
		panda = nth.Panda.instance().prep(map, cell_pos, cell_info)
		map.get_node("Navigation2D/PandaHolder").call_deferred("add_child", panda)
		map.show_homes()
		
		var light = nth.OrangeLight.instance()
		light.position = map.calc_px_pos_on_tile(cell_pos)
		map.get_node("Navigation2D/PandaHolder").call_deferred("add_child", light)
	
	
	return self
	
func panda_in_center(panda):
	.panda_in_center(panda)
	# Foreign House
	if panda.home_pos != cell_pos and panda.perform_next_action():
		var resUpdater = panda.get_next_ressource_updater()
		for ressource in resUpdater.ressources:
			var taken = panda.inventory.try_take(ressource, resUpdater.ressources[ressource])
			inventory.add(ressource, taken)
			scheduled_inventory.add(ressource, taken)
			inventory.update_view()

func get_tile_id():
	return  4
	
func get_speed_factor():
	return 1.5
	
func remove():
	panda.remove()
	.remove()
	
################################################
### FIRE
func get_prob_fire_catch():
	return 40
func get_fire_increase_time():
	return 12

################################################
### INVENTORY
func has_inventory():
	return true
func inventory_max_values():
	return {}
func notify_inventory_increase(_ressource, _amount):
	pass
