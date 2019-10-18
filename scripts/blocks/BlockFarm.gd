extends "BlockBamboo.gd"

func get_class(): return "BlockFarm"

func init(map, cell_pos, cell_info, args, nth):
	args["stock"] = 0
	args["var"] = 0
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 5

func ressource_work_time():
	return 2
func get_speed_factor():
	return 2.5
	
func get_max_stock():
	return 4
	
func get_regrow_prob():
	return 80
	
func shields_landscape_durability():
	return true
	
func can_be_build_on(map, cell_pos):
	return map.blocks.has(cell_pos) and map.blocks[cell_pos].get_class() == "BlockBamboo"