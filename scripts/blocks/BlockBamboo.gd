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
	increase_stock()

func get_regrow_prob():
	return 65
	
func get_regrow_prob_rain_bonus():
	return 20
	
func get_regrow_prob_day_bonus():
	return 20

func get_stack_increase_prob():
	var num_spreading = 0
	var num_non_spreading = 0
	for adjacent in map.get_adjacent_tiles(cell_pos):
		if map.landscapes.has(adjacent) and map.landscapes[adjacent] != null:
			if map.landscapes[adjacent].can_spread_grass():
				num_spreading += 1
			else:
				num_non_spreading += 1
	if num_spreading > 0:
		var prob_to_spread = (num_spreading / float(num_spreading + num_non_spreading))
		prob_to_spread *= get_regrow_prob() + map.weather.get_rain_level() * get_regrow_prob_rain_bonus() + map.weather.get_day_bonus() * get_regrow_prob_day_bonus()
		return prob_to_spread
	return 0
	
################################################
### FIRE
func get_prob_fire_catch():
	return 60
func get_fire_increase_time():
	return 9