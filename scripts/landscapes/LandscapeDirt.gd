extends "Landscape.gd"

const PROB_TO_GRASS_CONVERSION_WHEN_SPREADING = 50#%
const PROB_TO_SPAWN_BUG_HILL = 16#%

func get_class(): return "LandscapeDirt"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 6 # TODO  6 = map.tile_cols
	
func get_max_var():
	return 4
	
func got_welled():
	map.set_landscape_by_descriptor(cell_pos, "grass")
	
func tick():
	# Spawn bug hill
	if !map.blocks.has(cell_pos):
		if randi()%100 <= PROB_TO_SPAWN_BUG_HILL: 
			map.set_block_by_descriptor(cell_pos, "bughill")
			return
	
	# Transform to grass
	if (!map.blocks.has(cell_pos) or map.blocks[cell_pos].is_bug_hill) and randi()%100 <= get_adjacent_spreadable_percent():
		if randi()%100 <= PROB_TO_GRASS_CONVERSION_WHEN_SPREADING:
			remove()
			map.set_landscape_by_descriptor(cell_pos, "grass")

func get_speed_factor():
	return 1