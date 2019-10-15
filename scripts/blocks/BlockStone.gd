extends "Block.gd"

func init(map, cell_pos, cell_info, args, nth):
	if !args.has("stock"):
		if cell_info.fertility < -0.12 and cell_info.humidity < -0.12:
			stock = 3
		elif cell_info.fertility < 0.04 and cell_info.humidity < 0.04:
			stock = 2
		else:
			stock = 1	

	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 2
	
func ressource_name_or_null():
	return "stone"
func ressource_work_time():
	return 6
func get_ressource_amount():
	return 1
func get_sprite_num():
	return 4


func get_ressource_amount_after_work_done():
	var amount = .get_ressource_amount_after_work_done()
	if stock == 0:
		remove()
	return amount
	
	