extends "Block.gd"

func get_class(): return "BlockStone"

func init(map, cell_pos, cell_info, args, nth):
	if !args.has("stock"):
		if cell_info.fertility < -0.35: stock = 4
		elif cell_info.fertility < -0.22: stock = 3
		elif cell_info.fertility < -0.11: stock = 2
		else: stock = 1
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 2
	
func ressource_name_or_null():
	return "stone"
func ressource_work_time():
	return 7
func get_max_var():
	return 1
func get_max_stock():
	return 4


func get_ressource_amount_after_work_done():
	var amount = .get_ressource_amount_after_work_done()
	if stock == 0:
		remove()
	return amount
	
	