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
var ressource_working_on = null
var time_left_to_work = 1

var timer = 0

var ressourceManager

func prep(map, home_pos3):
	self.map = map
	self.home_pos3 = home_pos3
	self.home_pos = Vector2(home_pos3.x, home_pos3.y)
	return self
	
func _ready():
	position = map.map_landscape.map_to_world(home_pos)
	
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
		ressourceManager.add_ressource("population", 1)
	else:
		ressourceManager = null
		
	
func _process(delta: float) -> void:
	timer += delta
	# wait idly if no path defined yet
	if path == null or path.size() == 0:
		return
	
	if working_on_ressource:
		time_left_to_work -= delta
		if time_left_to_work <= 0:
			working_on_ressource = false
			var ressource_name = ressource_working_on.ressource_name_or_null()
			var ressource_value = ressource_working_on.get_ressource_amount_after_work_done()
			ressourceManager.add_ressource(ressource_name, ressource_value)
			print("Got " + str(ressource_value) + " " + ressource_name)
		else:
			var angle = 15*sin(5 * (ressource_working_on.ressource_work_time() - time_left_to_work) * (2*PI))
			$Sprite.rotation_degrees = angle
			return # prevent path walking	
		
	var target_pos = map.map_landscape.map_to_world(path[curr_path_pos])
	
	var speed_factor = 1.0
	var standing_on = map.map_landscape.world_to_map(position + map.map_landscape.cell_size / 2.0)
	var landscape_standing_on = map.landscapes[standing_on]
	speed_factor *= landscape_standing_on.get_speed_factor()
	
	var dhdx = 0
	if last_target != null:
		dhdx = map.height_layer[last_target] - map.height_layer[path[curr_path_pos]]
	for _i in range(0, abs(dhdx)):
		speed_factor *= SPEED_FACTOR_PER_LAYER_UP
		
	
	if map.blocks.has(standing_on):
		var block_standing_on = map.blocks[standing_on]
		speed_factor *= block_standing_on.get_speed_factor()
	
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
			curr_path_pos = 0
			# when he is scheduled to change path
			if next_paths.size() > 0:
				path = next_paths.pop_front()
			else:
				path = null
				# todo anim sleep
				update_sprite(Vector2(1,1))


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
		
func start_working_on_ressource(ressource):
	if ressource.ressource_name_or_null() == null:
		printerr("Tried working on non-ressource block")
		return
	working_on_ressource = true
	ressource_working_on = ressource
	time_left_to_work = ressource.ressource_work_time()
	
	
	