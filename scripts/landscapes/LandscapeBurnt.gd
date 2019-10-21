extends "Landscape.gd"

const PROB_TO_INCREASE_VAR = 100#%

func get_class(): return "LandscapeBurnt"

func get_tile_id():
	return 4*6 # TODO  6 = map.tile_cols
	
func get_max_var():
	return 4
	
func got_welled():
	map.set_landscape_by_descriptor(cell_pos, "grass")
	
func tick():
	.tick()
	# Increase variant until reached last
	if randi()%100 <= PROB_TO_INCREASE_VAR:
		args.var += 1
		if args.var > get_max_var():
			map.set_landscape_by_descriptor(cell_pos, "grass")
		else:
			update_tile()

func get_speed_factor():
	return 1.1