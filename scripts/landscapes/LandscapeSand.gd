extends "Landscape.gd"


const TIDE_TIME = 30

func get_class(): return "LandscapeSand"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)	

func get_tile_id():
	return 2 * 6 # TODO  6 = map.tile_cols
	
func get_max_var():
	return 4

func tick():
	pass

func time_update(time:float):
	var s = sin(time * 2.0*PI / TIDE_TIME)
	var deep = cell_info.height == map.layers - 1

	var humidity_bonus = cell_info.humidity / 2.4
	if deep and s < 0.75 + humidity_bonus:
		conv()
		return
	if !deep and s < -0.75 - humidity_bonus:
		conv()
		return
	

func conv():
	map.set_landscape_by_descriptor(cell_pos, "water")

func can_spread_grass():
	return false
	
func get_speed_factor():
	return 0.9
	
func can_build_on(_map, _cell_pos):
	return false