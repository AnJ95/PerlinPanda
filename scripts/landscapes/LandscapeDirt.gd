extends "Landscape.gd"

const PROB_TO_GRASS_CONVERSION_WHEN_SPREADING = 55#%
const PROB_TO_GRASS_CONVERSION_WHEN_SPREADING_RAIN_BONUS = 55#%

const PROB_TO_SPAWN_BUG_HILL = 2#%
const PROB_TO_SPAWN_BUG_HILL_DROUGHT_BONUS = 12#%
const PROB_TO_SPAWN_BUG_HILL_NIGHT_BONUS = 12#%



func get_class(): return "LandscapeDirt"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 12
	
func get_max_var():
	return 4
	
func got_welled():
	.got_welled()
	map.set_landscape_by_descriptor(cell_pos, "grass")
	
func tick():
	.tick()
	# Spawn bug hill
	if !has_block():
		var prob = PROB_TO_SPAWN_BUG_HILL + (1 - get_weather().rain.now()) * PROB_TO_SPAWN_BUG_HILL_DROUGHT_BONUS + (1 - get_weather().day.now()) * PROB_TO_SPAWN_BUG_HILL_NIGHT_BONUS
		
		if randi()%100 <= prob:
			map.set_block_by_descriptor(cell_pos, "bughill")
			return
	
	# Transform to grass
	if randi()%100 <= 100*fertility:
		var prob = PROB_TO_GRASS_CONVERSION_WHEN_SPREADING + get_weather().rain.now() * PROB_TO_GRASS_CONVERSION_WHEN_SPREADING_RAIN_BONUS
		
		if randi()%100 <= prob:
			map.set_landscape_by_descriptor(cell_pos, "grass")
			if has_block() and get_block().get_class() == "BlockBugHill":
				get_block().play_particle_animation()
				get_block().remove()

func get_speed_factor(_panda):
	return 1