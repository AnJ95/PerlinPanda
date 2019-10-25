extends "Block.gd"


const percent_each_tile = 70
var particles = {}


func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	
	for pos in map.get_adjacent_tiles(cell_pos):
		var particle = nth.ParticlesWelled.instance()
		particle.position = map.calc_px_pos_on_tile(pos)
		particle.emitting = false
		map.get_node("Navigation2D/ParticleHolder").add_child(particle)
		particles[pos] = particle
	return self
	
func get_tile_id():
	return 40

func get_speed_factor():
	return 0.7
	
func get_build_time():
	return 5.0
	
func is_passable():
	return true


var do_well = false
var time_to_well_at = -1
const well_time = 1.5
var tiles_to_well = []

func time_update(time):
	.time_update(time)
	if do_well:
		if time_to_well_at == -1:
			time_to_well_at = time + well_time
		else:
			if time >= time_to_well_at:
				for pos in tiles_to_well:
					map.landscapes[pos].got_welled()
					if map.blocks.has(pos): map.blocks[pos].got_welled()
				do_well = false	
				tiles_to_well = []
				time_to_well_at = -1
	
	
	
func tick():
	do_well = true
	
	var adjacents = map.get_adjacent_tiles(cell_pos)
	adjacents.shuffle()

	for adjacent in adjacents:
		if map.landscapes.has(adjacent):
			if randi()%100 <= percent_each_tile:
				tiles_to_well.append(adjacent)
				particles[adjacent].emitting = true
	set_particle_emitting(true)

func get_particle_instance_or_null():
	return nth.ParticlesDrops.instance()