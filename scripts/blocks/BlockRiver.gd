extends "Block.gd"

var river_parts = []

func get_class(): return "BlockRiver"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	add_river_parts(cell_info.river_prev, true)
	add_river_parts(cell_info.river_next, false)
	return self


### RIVER SEGMENTS
func add_river_parts(list, prev_or_next=true):
	var pos = map.map_blocks.map_to_world(cell_pos)
	pos.y += map.layer_px_dst * cell_info.height
	var height = cell_info.height
	for adj in list:
		var rot = map.map_blocks.map_to_world(cell_pos).angle_to_point(map.map_blocks.map_to_world(adj))
		rot = rot/(2.0*PI)*360.0 + 90
		var river = nth.River.instance()
		map.get_node("Navigation2D/MiddleHolder").add_child(river.init(pos, rot, prev_or_next))
		if height - map.create_cell_info(adj).height == -1:
			add_falls_particles(pos, rot)

### PARTICLES
func add_falls_particles(pos, rot):
	var inst = nth.ParticlesWaterFalls.instance()
	inst.position = pos + Vector2(0, 52).rotated(deg2rad(rot)) - Vector2(0, 8)
	
	get_particle_holder().add_child(inst)

### OVERRIDES
func remove():
	.remove()
	for part in river_parts:
		part.queue_free()
	

func get_tile_id():
	return 11 + 6*12

func get_speed_factor():
	return 2.3

func shields_landscape_durability():
	return true

