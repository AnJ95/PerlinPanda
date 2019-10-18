extends "Landscape.gd"

# SAME CONSTS IN WATER!
const WATER_MIN_LEVEL = 5.5
const WATER_MAX_LEVEL = 4.5
const TIDE_TIME = 6

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
	var water_height = WATER_MAX_LEVEL + (WATER_MIN_LEVEL-WATER_MAX_LEVEL) * ((s + 1) / 2.0)
	if water_height < cell_info.precise_height:
		conv()
	
	

func conv():
	map.set_landscape_by_descriptor(cell_pos, "water")

func can_spread_grass():
	return false
	
func get_speed_factor():
	return 0.9
	
func can_build_on(_map, _cell_pos):
	return false