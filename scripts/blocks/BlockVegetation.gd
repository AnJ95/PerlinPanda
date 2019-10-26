extends "Block.gd"

func get_class(): return "BlockVegetation"

func init(map, cell_pos, cell_info, args, nth):
	stock = 1
	.init(map, cell_pos, cell_info, args, nth)
	return self
	
func get_tile_id():
	return 0 + 6*12
	
func ressource_name_or_null():
	return "leaves"
func ressource_work_time():
	return 2.2
func get_max_var():
	return 3
func get_max_stock():
	return 1
func shields_landscape_durability():
	return true

func get_ressource_amount_after_work_done():
	var amount = .get_ressource_amount_after_work_done()
	if stock == 0:
		remove()
	return amount
################################################
### FERTILITY
func get_fertility_bonus(): return 0.1
################################################
### FIRE
func get_prob_lightning_strike():
	return 80
func get_fire_increase_time():
	return 6
	