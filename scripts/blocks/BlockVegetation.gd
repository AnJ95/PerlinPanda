extends "Block.gd"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	stock = 1
	
	return self
	
	
func prevents_landscape_tick():
	return true
	
func get_tile_id():
	return 30
	
func ressource_name_or_null():
	return "leaves"
func ressource_work_time():
	return 3
func get_ressource_amount():
	return 1
func get_max_var():
	return 3
func get_max_stock():
	return 1


func get_ressource_amount_after_work_done():
	var amount = .get_ressource_amount_after_work_done()
	if stock == 0:
		remove()
	return amount
	
	