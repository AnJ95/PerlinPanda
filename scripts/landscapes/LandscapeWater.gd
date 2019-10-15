extends "Landscape.gd"

const TIDE_TIME = 40
const ANIM_TIME = 0.5
var anim_time_left = 0.0
var last_time = 0.0

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
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
	var deep = (cell_info.height == map.layers - 1)
	
	var humidity_bonus = 1 * (cell_info.humidity + 1) / 2.0 # norm to [0, 1] and then to [0, 1]
	
	if deep: 
		if s > -1.0 + humidity_bonus:
			cell_info.height = 3
		if s > 0.4 + humidity_bonus:
			cell_info.height = 3
	
	update_tile()
	

		
	if deep and s < -1.0 + humidity_bonus:
		conv()
		return
	if !deep and s < 0.4 + humidity_bonus:
		conv()
		return
	

func conv():
	map.set_landscape_by_descriptor(cell_pos, "sand")

func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.25
	
func can_build_on(_map, _cell_pos):
	return false