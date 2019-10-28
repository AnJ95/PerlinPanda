extends "Landscape.gd"

const ANIM_TIME = 0.5
var anim_time_left = 0.0
var last_time = 0.0

var original_height = false

func get_class(): return "LandscapeWater"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	original_height = cell_info.height
	return self
	
func get_tile_id():
	return 3 * 12
func get_max_var():
	return 4

func time_update(time:float):
	
	anim_time_left -= (time - last_time)
	if anim_time_left <= 0:
		anim_time_left = ANIM_TIME
		args.var += 1
		if args.var >= get_max_var():
			args.var = 0
	last_time = time
	
	var water_height = get_weather().tide.now()
	
	cell_info.height = floor(water_height)
	
			
	if water_height > cell_info.precise_height:
		conv()
		return
	update_tile()

func conv():
	cell_info.height = original_height
	map.set_landscape_by_descriptor(cell_pos, "sand")

func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.25
	
func can_build_on(_map, _cell_pos):
	return false