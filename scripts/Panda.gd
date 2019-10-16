extends Node2D

var home_pos
var home_pos3
var map

const SPEED = 30
const SPEED_FACTOR_PER_LAYER_UP = 0.8

# for path iteration
var path = null
var curr_path_pos = 0
var next_paths = []
var line
var last_target = null

# for working on ressource
var working_on_ressource = false

# for building
var building = false

# for working and building
var job_on = null
var job_time_left = 1


var timer = 0

var ressourceManager

var inventory = {}

func move_inventory():
	for res_name in inventory.keys():
		ressourceManager.add_ressource(res_name, inventory[res_name])
		inventory.erase(res_name)
	inventory_changed()

		
func add_to_inventory(res_name, res_value):
	if !inventory.has(res_name):
		inventory[res_name] = res_value
	else:
		inventory[res_name] += res_value
	inventory_changed()

func inventory_changed():
	var num_visible = 0
	for res in ["bamboo", "stone"]:
		var val = 0
		if inventory.has(res):
			val = inventory[res]
			if val > 0:
				num_visible += 1
		
		var node = get_node("Inventory_" + res)
		if val == 0:
			node.hide()
		else:
			node.show()
		node.value = val
		node.update()
		
	
	if num_visible == 2:
		$Inventory_stone.rect_position.y = -135
	else:
		$Inventory_stone.rect_position.y = -103
		
			
	
func prep(map, cell_pos, cell_info):
	self.map = map
	self.home_pos3 = Vector3(cell_pos.x, cell_pos.y, cell_info.height)
	self.home_pos = cell_pos
	return self
	
func _ready():
	position = map.calc_px_pos_on_tile(home_pos)
	
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
		ressourceManager.add_ressource("population", 1)
	else:
		ressourceManager = null
		
	map.show_homes()
	inventory_changed()
	$Particles_sleeping.emitting = true
		
	
func _process(delta: float) -> void:
	timer += delta
	# wait idly if no path defined yet
	if path == null or path.size() == 0:
		return
	
	# Calc Speed factor
	var speed_factor = calc_speed_factor()
	
	#### IS DOING A JOB
	if building or working_on_ressource:
		job_time_left -= delta * speed_factor
		#### DONE
		if job_time_left <= 0:
			#### DONE BUILDING
			if building:
				building = false
				job_on.inst_actual_block()
				stop_particles()
			### DONE WORKING
			if working_on_ressource:
				working_on_ressource = false
				stop_particles()
				var ressource_name = job_on.ressource_name_or_null()
				var ressource_value = job_on.get_ressource_amount_after_work_done()
				add_to_inventory(ressource_name, ressource_value)
				print("Got " + str(ressource_value) + " " + ressource_name + ", " + str(job_on.stock) + " stock left ")
		#### NOT DONE
		else:
			var angle = 15*sin(5 * (job_on.ressource_work_time() - job_time_left) * (2*PI))
			$Sprite.rotation_degrees = angle
			return # prevent path walking

	var target_pos = map.calc_px_pos_on_tile(path[curr_path_pos])
	
	# Check if current target in vicinity
	var d:float = position.distance_to(target_pos)
	if d > 10:
		$Sprite.rotation_degrees = 8 * sin(1 * timer * (2*PI))
		position = position.linear_interpolate(target_pos, (speed_factor*SPEED * delta)/d)
		update_sprite((target_pos - position))
	else:
		var arr = Array(line.points)
		arr.pop_front()
		line.points = PoolVector2Array(arr)
		var reached_cell = path[curr_path_pos]
		map.generate_next(reached_cell, 1)
		last_target = reached_cell
		
		# give blocks and landscapes below their triggers
		if map.blocks.has(reached_cell):
			var block = map.blocks[reached_cell]
			if block != null:
				block.panda_in_center(self)
		if map.landscapes.has(reached_cell):
			var landscape = map.landscapes[reached_cell]
			landscape.panda_in_center(self)
		
		
		
		curr_path_pos += 1
		# when panda walked full circle
		if curr_path_pos == path.size():
			# move pandas inventory to global ressources
			move_inventory()
			
			curr_path_pos = 0
			# when he is scheduled to change path
			if next_paths.size() > 0:
				path = next_paths.pop_front()
			else:
				path = null
				$Particles_sleeping.emitting = true
				update_sprite(Vector2(1,1))
	
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
		
	
	
func set_path(path):
	print("Set path " + str(path))
	if self.path == null:
		self.path = path
	else:
		next_paths.append(path)
	

func start_building(BlockWIP):
	building = true
	job_on = BlockWIP
	job_time_left = BlockWIP.get_build_time()
	
	$Particles_bamboo.emitting = true
	$Particles_stone.emitting = true
	
func start_working_on_ressource(ressource):
	if ressource.ressource_name_or_null() == null:
		printerr("Tried working on non-ressource block")
		return
	working_on_ressource = true
	job_on = ressource
	job_time_left = ressource.ressource_work_time()
	
	get_node("Particles_" + ressource.ressource_name_or_null()).emitting = true
	
func stop_particles():
	$Particles_bamboo.emitting = false
	$Particles_stone.emitting = false
	$Particles_sleeping.emitting = false
	
	