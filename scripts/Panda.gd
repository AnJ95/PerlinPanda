extends "Gatherer.gd"

var home_pos
var home_pos3

const SPEED = 45
const SPEED_FACTOR_PER_LAYER_UP = 0.9

# for path iteration
var path = null
var curr_path_pos = 0
var next_paths = []
var line
var last_target = null

# for inventory
var expected_inventory = null
var next_expected_inventories = []
# for animation
var show_start_anim
var start_anim_target



func prep(map, cell_pos, cell_info):
	.init(map)
	self.home_pos3 = Vector3(cell_pos.x, cell_pos.y, cell_info.height)
	self.home_pos = cell_pos
	return self
	
func _ready():
	._ready()
	ressourceManager.add_ressource("population", 1)
	position = map.calc_px_pos_on_tile(home_pos)
	map.show_homes()
	if get_tree().get_nodes_in_group("panda").size() > 1:
		$Particles_love.emitting = true
		show_start_anim = true
		start_anim_target = home_pos
		position = (home_pos +Vector2(800, 0)).rotated(randi()%360)

func _process(delta: float) -> void:
	._process(delta)
	
	# start animation
	if show_start_anim:
		if move_towards_then(start_anim_target, 12*SPEED, delta):
			show_start_anim = false
			$Particles_sleeping.emitting = true
		else:
			return	
	
	# wait idly if no path defined yet
	if path == null or path.size() == 0:
		return
	
	# gather and build, prevent walking if so
	var speed_factor = calc_speed_factor()
	var speed = speed_factor * SPEED
	if gather_and_build(delta, speed_factor):
		return

	var target_pos = map.calc_px_pos_on_tile(path[curr_path_pos])
	
	# Check if current target in vicinity
	if move_towards_then(path[curr_path_pos], speed, delta):
		reached_cell()
		ressourceManager.steps_taken += 1
	else:
		update_sprite((target_pos - position))
				
	# Check for stepping on bug
	for bug in get_tree().get_nodes_in_group("bug"):
		if position.distance_squared_to(bug.position) < 2500 and position.distance_to(bug.position) < 50:
			bug.stepped_on(self)

func is_ressource_updater(e):
	return !e is bool and !e is Vector2 and e.get_filename().find("RessourceUpdater") > -1
	
func reached_cell():
	var arr = Array(line.points)
	arr.pop_front()
	line.points = PoolVector2Array(arr)
	var reached_cell = path[curr_path_pos]
	map.generate_next(reached_cell, 1)
	last_target = reached_cell
	
	curr_path_pos += 1
	
	# give blocks and landscapes below their triggers
	if map.blocks.has(reached_cell):
		var block = map.blocks[reached_cell]
		if block != null:
			block.panda_in_center(self)
	if map.landscapes.has(reached_cell):
		var landscape = map.landscapes[reached_cell]
		landscape.panda_in_center(self)
	
	# when panda walked full circle
	if curr_path_pos == path.size():
		reached_house()
		return
	
	# skip perform_action
	if path[curr_path_pos] is bool:
		curr_path_pos += 1
		
	# take items from house as defined in houses RessourceUpdater
	var path_elem = path[curr_path_pos]
	if is_ressource_updater(path_elem):
		if map.blocks.has(reached_cell):
			var block = map.blocks[reached_cell]
			if block.get_class() == "BlockHouse":
				## Home
				if reached_cell == home_pos:
					for ressource in path_elem.ressources:
						var taken = map.blocks[home_pos].inventory.try_take(ressource, path_elem.ressources[ressource])
						inventory.add(ressource, taken)
						map.blocks[home_pos].inventory.update_view()
				
		curr_path_pos += 1
		
	
func perform_next_action():
	if curr_path_pos+0 >= path.size():
		return true
	var next = path[curr_path_pos+0]
	return !next is bool or next == true
	
func get_next_ressource_updater():
	if curr_path_pos+1 >= path.size():
		return null
	var updater = path[curr_path_pos+1]
	if is_ressource_updater(updater):
		return updater
	else:
		return null
	 

func reached_house():
	var soll = expected_inventory.clone().inventory
	var ist = inventory.clone().inventory
	# move pandas inventory to house
	inventory.move_to_other(map.blocks[home_pos].inventory)
	p("####### PATH REPORT")
	p("## Expected: " + str(soll))
	var d = {}
	for res in ist:
		d[res] = ist[res]
	for res in soll:
		if d.has(res):
			d[res] -= soll[res]
		else:
			d[res] = -soll[res]
	for res in d:
		if d[res] != 0:
			p("## MISMATCH in " + res + ": " + str(ist[res]))
		map.blocks[home_pos].scheduled_inventory.add(res, d[res])
		# TODO Live update PathMakers path[2]
		for next_inventory in next_expected_inventories:
			next_inventory.add(res, d[res])
	
	next_path()
	
		
func next_path():
	curr_path_pos = 0
	# when he is scheduled to change path
	if next_paths.size() > 0:
		path = next_paths.pop_front()
		expected_inventory = next_expected_inventories.pop_front()
	else:
		path = null
		expected_inventory = null
		$Particles_sleeping.emitting = true
		update_sprite(Vector2(1,1))
	
	if path != null:
		p("######## PATH START")
		p("## Path:" + str(path))
		p("## Expected inventory: " + expected_inventory._to_string())
	
func calc_speed_factor():
	var speed_factor = 1.0
	
	var standing_on = map.calc_closest_tile_from(position)
	
	var landscape_standing_on = map.landscapes[standing_on]
	speed_factor *= landscape_standing_on.get_speed_factor()
	
	for panda in get_tree().get_nodes_in_group("panda"):
		if panda != self:
			var a:Vector2 = panda.position
			var b:Vector2 = self.position
			if a.distance_squared_to(b) < 80*80 and a.distance_to(b) < 80:
				speed_factor *= 0.75
			if a.distance_squared_to(b) < 40*40 and a.distance_to(b) < 40:
				speed_factor *= 0.5
	
	var dhdx = 0
	if last_target != null:
		dhdx = map.cell_infos[last_target].height - map.cell_infos[path[curr_path_pos]].height
	for _i in range(0, abs(dhdx)):
		speed_factor *= SPEED_FACTOR_PER_LAYER_UP
		
	
	if map.blocks.has(standing_on):
		var block_standing_on = map.blocks[standing_on]
		speed_factor *= block_standing_on.get_speed_factor()
	
	return speed_factor
		
func update_sprite(n):
	if n.x > 0:
		$Sprite.flip_h = false
	if n.x < 0:
		$Sprite.flip_h = true
	if n.y < 0:
		$Sprite.frame = 1
	if n.y > 0:
		$Sprite.frame = 0
		
func stop_particles():
	.stop_particles()
	$Particles_sleeping.emitting = false
	
func add_path(path, expected_inventory):
	p("######## PATH ADD")
	p("## Path:" + str(path))
	p("## Expected inventory: " + expected_inventory._to_string())
	next_paths.append(path)
	next_expected_inventories.append(expected_inventory)
	if self.path == null:
		next_path()

func get_last_expected_inventory():
	if next_expected_inventories == null or next_expected_inventories.size() == 0:
		if expected_inventory == null:
			return null
		return expected_inventory
	else:
		return next_expected_inventories[next_expected_inventories.size()-1]
		
func p(obj):
	if map.print_panda_pathing:
		print(obj)

func can_gather():
	return true
func gatherable_ressources():
	return ["bamboo", "stone", "leaves"]
func can_build():
	return true
	
####################################
## INVENTORY
# Is no displayed concretly and therefore confusing
#func max_inventory():
	#return {"bamboo":1,"stone":1,"leaves":1}
	#return {"bamboo":4,"stone":2,"leaves":6}
	
	