extends "Gatherer.gd"

var home
var home_pos
var home_pos3

const MIN_SPEED = 15
const SPEED = 80
const SPEED_FACTOR_PER_LAYER_UP = 0.92
const SPEED_LOSS_PER_RES = {"bamboo":3, "stone":6, "leaves":1}

# for path iteration
var path = null
var curr_path_pos = 0
var next_paths = []
var line:Line2D
var last_target = null

# for inventory
var expected_inventory = null
var next_expected_inventories = []
# for animation
var show_start_anim
var start_anim_target



func prep(map, cell_pos, cell_info, nth):
	.init(map, nth)
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
	
	process_effects()
	var speed_bonus = 1.0
	if current_effects.has("speed"):
		speed_bonus = current_effects.speed[0]
	
	# start animation
	if show_start_anim:
		if move_towards_then(start_anim_target, 12*SPEED, delta):
			show_start_anim = false
			$Particles_sleeping.emitting = true
		else:
			return	

	# wait idly if no path defined yet
	if path == null or path.size() == 0:
		$Particles_exhaustion.emitting = false
		$Particles_exhaustion2.emitting = false
		return
	
	# get speed
	var speed_factor = calc_speed_factor()
	
	# gather and build, prevent walking if so
	if gather_and_build(delta, speed_bonus*speed_factor):
		$Particles_exhaustion.emitting = false
		$Particles_exhaustion2.emitting = false
		return
		
	# Exhaustion
	var ex = get_exhaustion()
	$Particles_exhaustion.emitting = ex >= 10
	$Particles_exhaustion2.emitting = $Particles_exhaustion.emitting
	if $Particles_exhaustion.emitting:
		var scale = min(2, 1 + (ex-10) / 40)
		$Particles_exhaustion.scale.x = scale
		$Particles_exhaustion.scale.y = scale
		$Particles_exhaustion2.scale.x = scale
		$Particles_exhaustion2.scale.y = scale
	var speed = speed_bonus * speed_factor * (SPEED-ex)
	speed = max(MIN_SPEED, speed)

	
	# Check if current target in vicinity
	var target_pos = map.calc_px_pos_on_tile(path[curr_path_pos])
	if move_towards_then(path[curr_path_pos], speed, delta):
		reached_cell()
		ressourceManager.steps_taken += 1
	else:
		update_sprite((target_pos - position))
		if line.points.size() > 0:
			line.points[0] = position
			line.points = line.points
				
	# Check for stepping on bug
	for bug in get_tree().get_nodes_in_group("bug"):
		if position.distance_squared_to(bug.position) < 2500 and position.distance_to(bug.position) < 50:
			bug.stepped_on(self)

func get_exhaustion():
	var ex = 0.0
	for res in inventory.inventory:
		ex += inventory.get(res) * SPEED_LOSS_PER_RES[res]
	return ex

func is_ressource_updater(e):
	return !e is bool and !e is Vector2 and e.get_filename().find("RessourceUpdater") > -1
	
func reached_cell():
	var arr = Array(line.points)
	arr.pop_front()
	line.points = PoolVector2Array(arr)
	var reached_cell = path[curr_path_pos]
	map.grant_vision(reached_cell, 1)
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
		if do_repeat:
			repeat()
		else:
			map.blocks[home_pos].scheduled_inventory = map.blocks[home_pos].inventory.clone()
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
	speed_factor *= landscape_standing_on.get_speed_factor(self)
	
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
		speed_factor *= block_standing_on.get_speed_factor(self)
	
	if map.debug_mode:
		speed_factor *= 1#3.5
	
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
	
func remove():
	queue_free()
	remove_from_group("panda")
	
	var pathMaker = get_tree().get_nodes_in_group("path_maker")
	if pathMaker.size() > 0 and pathMaker[0].active:
		if pathMaker[0].panda == self:
			pathMaker[0].cancel()
	
	if !pathMaker[0].active:
		map.map_overlay.clear()
		map.show_homes()
	
	if repeat_line != null:
		repeat_line.queue_free()
		
	ressourceManager.add_ressource("population", -1)

####################################
## REPEAT

func repeat():
	var pathMaker = nth.PathMaker.instance().init(false)
	map.get_parent().add_child(pathMaker)
	
	pathMaker.try_start_path_from(self)
	for i in range(repeat_path.size()):
		var path_elem = repeat_path[i]
		if path_elem is Vector2:
			pathMaker.add_to_current_path(path_elem);
			if pathMaker.path[pathMaker.path.size()-2] is bool and repeat_path.size() > i+1 and repeat_path[i+1] is bool:
				pathMaker.path[pathMaker.path.size()-2] = repeat_path[i+1]
				
	for p in range(repeat_next_paths.size()):
		var repeat_path = repeat_next_paths[p]
		pathMaker.try_start_path_from(self)
		for i in range(repeat_path.size()):
			var path_elem = repeat_path[i]
			if path_elem is Vector2:
				pathMaker.add_to_current_path(path_elem);
				if pathMaker.path[pathMaker.path.size()-2] is bool and repeat_path.size() > i+1 and repeat_path[i+1] is bool:
					pathMaker.path[pathMaker.path.size()-2] = repeat_path[i+1]
					
var do_repeat = false
var repeat_path
var repeat_next_paths
var repeat_line
func set_repeat(do_repeat):
	map.blocks[home_pos].repeat_icon.set_pressed(do_repeat)
	if do_repeat:
		repeat_path = path
		repeat_next_paths = []; for e in next_paths: repeat_next_paths.append(e)
		draw_orange_line()
	else:
		# delete anything but the current path
		next_paths = []
		
		# slice the line until house is reached
		var pts = Array(line.points)
		var pts_new = []
		var home_px_pos = map.map_overlay.map_to_world(home_pos) + Vector2(0, map.cell_infos[home_pos].height * map.layer_px_dst)
		for pt in pts:
			pts_new.append(pt)
			if pt == home_px_pos:
				break
		line.points = PoolVector2Array(pts_new)
		
		# hide orange line
		if repeat_line != null:
			repeat_line.hide()
			
	self.do_repeat = do_repeat
			
	
func draw_orange_line():
	
	var pts = []
	
	# create one list for all paths
	var paths = []
	paths.append(path)
	for path in next_paths: paths.append(path)
	
	# add all points
	for path in paths:
		if pts.size() == 0: pts.push_front(map.map_overlay.map_to_world(path[0]) + Vector2(0, map.cell_infos[path[0]].height * map.layer_px_dst))
		for cell in path:
			if cell is Vector2:
				var pt = map.map_overlay.map_to_world(cell) + Vector2(0, map.cell_infos[cell].height * map.layer_px_dst)
				pts.append(pt)

	if repeat_line == null:
		repeat_line = line.duplicate()
		repeat_line.default_color = Color(0.8,0.3,0.2,0.8)
	repeat_line.show()
	repeat_line.points = PoolVector2Array(pts)
	
	line.get_parent().add_child(repeat_line)

####################################
## EFFECT
var current_effects = {}
func apply_effect(boni, time):
	for bonus in boni:
		current_effects[bonus] = [boni[bonus], map.time + time]
		
func process_effects():
	var to_delete = []
	for bonus in current_effects:
		if current_effects[bonus][1] < map.time:
			to_delete.append(bonus)
	for bonus in to_delete:
		current_effects.erase(bonus)
		
	$Sprite.material.set_shader_param("play_shader", current_effects.has("speed"))

####################################
## INVENTORY
# Is not displayed concretly and therefore confusing
#func max_inventory():
	#return {"bamboo":1,"stone":1,"leaves":1}
	#return {"bamboo":4,"stone":2,"leaves":6}
	
	