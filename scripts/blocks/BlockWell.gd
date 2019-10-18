extends "Block.gd"

var particle_inst

const percent_each_tile = 65
func init(map, cell_pos, cell_info, args, nth):
	particle_inst = nth.ParticlesDrops.instance()
	particle_inst.position = map.calc_px_pos_on_tile(cell_pos)
	set_particle_emitting(false)
	map.add_child(particle_inst)
	
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return 40

func get_speed_factor():
	return 0.7
	
func get_build_time():
	return 5.0
	
func is_passable():
	return false
	
func tick():
	
	var adjacents = map.get_adjacent_tiles(cell_pos)
	adjacents.shuffle()
	
	set_particle_emitting(true)
	
	for adjacent in adjacents:
		if map.landscapes.has(adjacent):
			if randi()%100 <= percent_each_tile:
				map.landscapes[adjacent].got_welled()
			if map.blocks.has(adjacent):
				map.blocks[adjacent].got_welled()

func set_particle_emitting(emit):
	particle_inst.emitting = emit


