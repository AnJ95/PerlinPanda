extends "Landscape.gd"

const PARTICLE_DST = 0.15

func get_class(): return "LandscapeSand"

func get_tile_id():
	return 2 * 12
	
func get_max_var():
	return 4

var last_water_height = -1
func time_update(_time:float):
	var water_height = get_weather().tide.now()
	
	# if water rising and above threshold
	set_particle_emitting(last_water_height > water_height and water_height - PARTICLE_DST < cell_info.precise_height)
	if water_height < cell_info.precise_height:
		conv()
		
	last_water_height = water_height

func conv():
	if fire_or_null != null:
		fire_or_null.extinguish()
	elif (has_block() and get_block().fire_or_null != null):
		get_block().fire_or_null.extinguish()
	map.set_landscape_by_descriptor(cell_pos, "water")

func can_spread_grass():
	return false
	
func get_speed_factor(_panda):
	return 0.9
	
func can_build_on(_map, _cell_pos):
	return false
	
func get_particle_instance_or_null():
	return nth.ParticlesSpray.instance()