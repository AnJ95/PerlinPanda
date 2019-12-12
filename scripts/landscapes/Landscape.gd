extends "res://scripts/TileElement.gd"

func get_class(): return "Landscape"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	return self


func update_tile():
	var tile_id = get_tile_id()

	# add variance id offset (always to right)
	tile_id += args.var

	# add tile id offset for height
	tile_id += map.layer_offset * cell_info.height

	# set tile id
	map.map_landscape.set_cellv(cell_pos, tile_id);
	
	update_fertility()

func time_update(_time:float):
	pass

func panda_in_center(panda):
	.panda_in_center(panda)

func tick():
	tick_fire()
	update_fertility()
	pass

func can_spread_grass():
	return false

func can_build_on(_map, _cell_pos):
	return true

func remove():
	.remove()
	if fertility_particle != null:
		fertility_particle.queue_free()
	map.map_landscape.set_cellv(cell_pos, -1)
	map.landscapes.erase(cell_pos)

################################################
### FERTILITY
	
var fertility_particle
var fertility = get_fertility_bonus() # overwritten, but good start for initial calc
func update_fertility():
	fertility = 0.0
	fertility += cell_info.fertility
	
	fertility += 0.5 * get_fertility_bonus()
	if has_block(): fertility += 0.5 * get_block().get_fertility_bonus()
	
	for adj in map.get_adjacent_tiles(cell_pos, 2):
		if map.landscapes.has(adj):
			var factor = map.y(map.are_tiles_adjacent(cell_pos, adj), 0.25/6.0, 0.25/12)
			fertility += factor * map.landscapes[adj].fertility
			
	fertility = min(1, max(0, fertility))
	
	if fertility > 0.1 and fertility_particle == null:
		init_fertility()
		
	if fertility_particle != null:
		fertility_particle.update_fertility(fertility)
		
func init_fertility():
	fertility_particle = nth.ParticlesFertility.instance()
	fertility_particle.position = map.calc_px_pos_on_tile(cell_pos)
	get_particle_holder().add_child(fertility_particle)

################################################
### FIRE

func catch_fire():
	# if block exists: try catching fire there instead
	if has_block():
		get_block().catch_fire()
	else:
		.catch_fire()

func tick_fire():
	# if is already on fire
	if fire_or_null != null:
		return

	# get prob to burn
	var prob = get_prob_lightning_strike()
	if has_block(): prob = get_block().get_prob_lightning_strike()
	if randi()%100 > prob:
		return

	var fire_levels = 0.0
	var adj_tiles = 6.0
	for adj in map.get_adjacent_tiles(cell_pos):
		if !map.landscapes.has(adj): continue
		var landscape = map.landscapes[adj]
		if landscape.fire_or_null != null:
			fire_levels += landscape.fire_or_null.fire_level
	var score = (fire_levels / 3.0) / adj_tiles # 0 when nothing burning, 1 when all adj burning with max strength
	score *= 10 # 0-10

	if randi()%100 <= score * 100:
		self.catch_fire() # spread Fire


# Overrides
func get_fire_increase_time():
	return 10
func got_burned_to_the_ground():
	.got_burned_to_the_ground()
	map.set_landscape_by_descriptor(cell_pos, "burnt")
	pass
	