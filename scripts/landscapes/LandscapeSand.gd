extends "Landscape.gd"

func get_class(): return "LandscapeSand"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)	

func get_tile_id():
	return 2 * 6 # TODO  6 = map.tile_cols
	
func get_max_var():
	return 4

func time_update(time:float):
	var water_height = map.weather.get_sea_level()
	if water_height < cell_info.precise_height:
		conv()

func conv():
	if fire_or_null != null:
		fire_or_null.extinguish()
	map.set_landscape_by_descriptor(cell_pos, "water")

func can_spread_grass():
	return false
	
func get_speed_factor():
	return 0.9
	
func can_build_on(_map, _cell_pos):
	return false