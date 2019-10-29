extends "Block.gd"

func get_class(): return "BlockMine"

func init(map, cell_pos, cell_info, args, nth):
	args.stock = 0
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 7
func get_speed_factor():
	return 1.2
func shields_landscape_durability():
	return true
	
	
func get_build_time():
	return 10.0
func can_be_build_on(map, cell_pos):
	if !.can_be_build_on(map, cell_pos): return false
	
	for adj in map.get_adjacent_tiles(cell_pos):
		if map.blocks.has(adj) and map.blocks[adj].get_class() == "BlockMountain" and map.blocks[adj].args.var != 3:
			return true
	return false
	
	
func ressource_name_or_null():
	return "stone"
func ressource_work_time():
	return 20
func get_max_stock():
	return 0
func get_ressource_amount_after_work_done():
	return .get_ressource_amount_after_work_done()
func is_infinite_ressource():
	return true


