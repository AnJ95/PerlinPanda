extends "Landscape.gd"


var durability = 0

const PROB_TO_GROW_VEGETATION_WHEN_MAX_DURABILITY = 10#%
const PROB_TO_INCREASE_DURABILITY_WHEN_SPREADING = 35#%

const PROB_TO_GROW_VEGETATION_WHEN_MAX_DURABILITY_RAIN_BONUS = 10#%
const PROB_TO_INCREASE_DURABILITY_WHEN_SPREADING_RAIN_BONUS = 30#%


func get_class(): return "LandscapeGrass"

func init(map, cell_pos, cell_info, args, nth):
	if args.has("durability"):
		durability = args["durability"]
	else:
		durability = min(4, int(((cell_info.fertility+1.0)/2.0) * 5))
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return durability - 1

func panda_in_center(_panda):
	.panda_in_center(_panda)
	decrease_durability()

func tick():
	.tick()
	if randi()%100 <= get_adjacent_spreadable_percent():
		if randi()%100 <= PROB_TO_INCREASE_DURABILITY_WHEN_SPREADING + get_weather().get_rain_level() * PROB_TO_INCREASE_DURABILITY_WHEN_SPREADING_RAIN_BONUS:
			increase_durability()
		
	if durability >= max_durability() and !has_block():
		if randi()%100 <= PROB_TO_GROW_VEGETATION_WHEN_MAX_DURABILITY + get_weather().get_rain_level() * PROB_TO_GROW_VEGETATION_WHEN_MAX_DURABILITY_RAIN_BONUS:
			map.set_block_by_descriptor(cell_pos, "vegetation")

func increase_durability():
	durability = min(max_durability(), durability + 1)
	update_tile()
func decrease_durability():
	if has_block() and get_block().shields_landscape_durability():
		return
	durability = max(0, durability - 1)
	if durability <= 0:
		durability_has_reached_zero()
	else:
		update_tile()



func max_durability():
	return 4
	
func durability_has_reached_zero():
	map.set_landscape_by_descriptor(cell_pos, "dirt")

func got_welled():
	.got_welled()
	increase_durability()
	if !has_block() and randi()%100 <= 30:
		map.set_block_by_descriptor(cell_pos, "vegetation")
	
	
func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.75
	
################################################
### FIRE
func get_prob_lightning_strike():
	return 20
func get_fire_increase_time():
	return 10