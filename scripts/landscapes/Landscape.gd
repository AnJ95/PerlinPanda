extends Object


var map
var cell_pos
var cell_info
var args
var nth

var particle_inst

func get_class(): return "Landscape"

func init(map, cell_pos, cell_info, args, nth):
	self.map = map
	self.cell_pos = cell_pos
	self.cell_info = cell_info
	self.args = args
	self.nth = nth
	
	# Particles
	particle_inst = get_particle_instance_or_null()
	if particle_inst != null:
		particle_inst.position = map.calc_px_pos_on_tile(cell_pos)
		set_particle_emitting(false)
		map.get_node("Navigation2D/ParticleHolder").add_child(particle_inst)
		
	# Variant
	if !args.has("var"):
		if get_max_var() > 0:
			args.var = randi() % (get_max_var() + 1)
		else:
			args.var = 0
			
	# Visual
	update_tile()
	return self




func update_tile():
	var tile_id = get_tile_id()

	# add variance id offset (always to right)
	tile_id += args["var"]

	# add tile id offset for height
	tile_id += map.layer_offset * cell_info.height

	# set tile id
	map.map_landscape.set_cellv(cell_pos, tile_id);

func time_update(_time:float):
	pass

func get_tile_id():
	return 0

func get_max_var():
	return 0

func panda_in_center(_panda):
	if fire_or_null != null:
		fire_or_null.extinguish()
	pass

func tick():
	tick_fire()
	pass

func can_spread_grass():
	return false

func get_speed_factor():
	return 1.0

func can_build_on(_map, _cell_pos):
	return true

func remove():
	if particle_inst != null:
		particle_inst.queue_free()
	map.landscapes.erase(cell_pos)

func got_welled():
	pass

func get_adjacent_spreadable_percent():
	var num_spreading = 0
	var num_non_spreading = 0
	for pos in map.get_adjacent_tiles(cell_pos):
		var a = map.map_landscape.map_to_world(cell_pos, false)
		var b = map.map_landscape.map_to_world(pos, false)
		if map.landscapes.has(pos) and map.landscapes[pos] != null:
			if a.distance_to(b) <= 105:
				if map.landscapes[pos].can_spread_grass():
					num_spreading += 1
				else:
					num_non_spreading += 1
	if num_spreading == 0:
		return 0
	else:
		return 100 * (num_spreading / float(num_spreading + num_non_spreading))


###################################################	
### PARTICLES
func get_particle_instance_or_null():
	return null
	
func set_particle_emitting(emit:bool):
	if particle_inst != null:
		particle_inst.emitting = emit
	
	
################################################
### FIRE
var fire_or_null = null
func try_catch_fire():
	# if block exists: try catching fire there instead
	if map.blocks.has(cell_pos):
		map.blocks[cell_pos].try_catch_fire()
	else:
		if randi()%100 <= get_prob_fire_catch():
			caught_fire()
func caught_fire():
	if fire_or_null == null:
		if !Engine.editor_hint:
			fire_or_null = nth.Fire.instance().prep(map, cell_pos, cell_info)
			map.get_node("Navigation2D/ParticleHolder").call_deferred("add_child", fire_or_null)
func extinguished_fire():
	fire_or_null = null
func tick_fire():
	# if is already on fire
	if fire_or_null != null:
		return

	var fire_levels = 0.0
	var adj_tiles = 6.0
	for adj in map.get_adjacent_tiles(cell_pos):
		if !map.landscapes.has(adj):
			continue
		var landscape = map.landscapes[adj]
		if landscape.fire_or_null != null:
			fire_levels += landscape.fire_or_null.fire_level
	var score = (fire_levels / 3.0) / adj_tiles # 0 when nothing burning, 1 when all adj burning with max strength
	score *= 8 # 0-8
	#print(score)
	if randi()%100 <= score * 100:
		self.try_catch_fire() # spread Fire


# Overrides
func get_prob_fire_catch():
	return -1
func get_fire_increase_time():
	return 10
func got_burned_to_the_ground():
	map.set_landscape_by_descriptor(cell_pos, "burnt")
	fire_or_null = null
	pass

