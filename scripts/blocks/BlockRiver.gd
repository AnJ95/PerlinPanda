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
		river_parts.append(river)
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

func get_speed_factor(panda):
	
	# get similarities of river directions in distance across unit circle
	var min_dst = 100 ;var max_dst = 0
	for river in river_parts:
		var dst = panda.direction.distance_to(Vector2(1,0).rotated(deg2rad(river_parts[0]._flow_angle)))
		min_dst = min(dst, min_dst); max_dst = max(dst, max_dst)
	
	# calc walk boost
	var factor = 1
	if min_dst < 1:
		factor *= 1 + 1.3 * min(1, max(0, 1-min_dst))
	if max_dst > 1:
		factor *= 1 - 0.5 * min(1, max(0, max_dst-1))
		
	return factor

func shields_landscape_durability():
	return true

