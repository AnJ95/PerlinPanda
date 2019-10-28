extends "Block.gd"

func get_class(): return "BlockBamboo"

func init(map, cell_pos, cell_info, args, nth):
	if !args.has("stock"):
		if cell_info.fertility > 0.30 and cell_info.humidity > 0.30:
			stock = 3
		elif cell_info.fertility > 0.21 and cell_info.humidity > 0.21:
			stock = 2
		elif cell_info.fertility > 0.05 and cell_info.humidity > 0.05:
			stock = 1
		else:
			stock = 0
				
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 0
	

	
func ressource_name_or_null():
	return "bamboo"
func ressource_work_time():
	return 3

func get_max_var():
	return 1
func get_max_stock():
	return 3
	
func got_welled():
	.got_welled()
	increase_stock()

func get_regrow_prob(): 				return 25
func get_regrow_prob_fertility_bonus(): return 60
func get_regrow_prob_rain_bonus(): 		return 25
func get_regrow_prob_day_bonus():		return 25

func get_stack_increase_prob():
	return get_regrow_prob()
	+ get_landscape().fertility * get_regrow_prob_fertility_bonus()
	+ get_weather().rain.now() * get_regrow_prob_rain_bonus()
	+ get_weather().day.now() * get_regrow_prob_rain_bonus()

################################################
### FERTILITY
func get_fertility_bonus(): return 0.1

################################################
### FIRE
func get_prob_lightning_strike():
	return 60
func get_fire_increase_time():
	return 11