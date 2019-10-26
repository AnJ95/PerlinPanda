extends "Landscape.gd"

const PROB_TO_INCREASE_VAR = 100#%

var landscape_before = "grass"

func get_class(): return "LandscapeBurnt"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	
	if map.landscapes.has(cell_pos):
		# Pretty hacky stuff
		landscape_before = map.landscapes[cell_pos].get_class()
		landscape_before = landscape_before.split("Landscape")[1]
		landscape_before = landscape_before.to_lower()
		if !map.lex.landscape_scripts.has(landscape_before):
			printerr("Invalid class name of Landscape before LandscapeBurnt: " + map.landscapes[cell_pos].get_class()) 
			landscape_before = "grass"
		if landscape_before == "grass":
			landscape_before += "_durability_" + str(randi()%2 + 4)

	return self
	
func get_tile_id():
	return 4*12
	
func get_max_var():
	return 4
	
func got_welled():
	.got_welled()
	map.set_landscape_by_descriptor(cell_pos, landscape_before)
	
func tick():
	.tick()
	# Increase variant until reached last
	if randi()%100 <= PROB_TO_INCREASE_VAR:
		args.var += 1
		if args.var > get_max_var():
			map.set_landscape_by_descriptor(cell_pos, landscape_before)
		else:
			update_tile()

func get_speed_factor():
	return 1.1
	
################################################
### FERTILITY
func get_fertility_bonus(): return 0.25