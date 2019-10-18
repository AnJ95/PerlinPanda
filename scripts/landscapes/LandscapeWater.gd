extends "Landscape.gd"

# SAME CONSTS IN SAND!
const WATER_MIN_LEVEL = 5.5
const WATER_MAX_LEVEL = 4.5
const TIDE_TIME = 60

const ANIM_TIME = 0.5
var anim_time_left = 0.0
var last_time = 0.0

var is_originally_deep = false

func get_class(): return "LandscapeWater"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	is_originally_deep = (cell_info.height == map.layers - 1)
	return self
	
func get_tile_id():
	return 3 * 6 # TODO  6 = map.tile_cols
func get_max_var():
	return 4
	
func tick():
	pass

func time_update(time:float):
	
	anim_time_left -= (time - last_time)
	if anim_time_left <= 0:
		anim_time_left = ANIM_TIME
		args.var += 1
		if args.var >= get_max_var():
			args.var = 0
	last_time = time
	
	var s = sin(time * 2.0*PI / TIDE_TIME)
	var water_height = WATER_MAX_LEVEL + (WATER_MIN_LEVEL-WATER_MAX_LEVEL) * ((s + 1) / 2.0)
	
	var deep = (cell_info.height == map.layers - 1)
	if is_originally_deep:
		if deep and water_height < cell_info.precise_height - 1:
			cell_info.height = map.layers - 2
		if !deep and water_height > cell_info.precise_height - 1:
			cell_info.height = map.layers - 1
			
	if water_height > cell_info.precise_height:
		conv()
		return
		
		
	update_tile()
	

func conv():
	map.set_landscape_by_descriptor(cell_pos, "sand")

func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.25
	
func can_build_on(_map, _cell_pos):
	return false