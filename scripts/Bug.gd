extends Node2D

var map
var hill

const SPEED = 20
var frame_time = 0.15
var time_left = frame_time
var timer = 0.0
var angle = 0.0
var target_pos = null

var working_on_ressource = false
var job_time_left = 0.0
var job_on = null
	
func prep(map, cell_pos, hill):
	self.map = map
	self.hill = hill
	position = map.calc_px_pos_on_tile(cell_pos)
	print("prep at " + str(position))
	return self

 
func _process(delta: float) -> void:
	#### IS DOING A JOB
	if working_on_ressource:
		job_time_left -= delta
		#### DONE
		if job_time_left <= 0:
			working_on_ressource = false
			get_node("Particles_bamboo").emitting = false
			job_on.get_ressource_amount_after_work_done()
		#### NOT DONE
		else:
			var angle = 15*sin(5 * (job_on.ressource_work_time() - job_time_left) * (2*PI))
			$Sprite.rotation_degrees = angle
			return # prevent path walking
			
			
			
	# Sprite Animation
	time_left -= delta
	if time_left <= 0:
		time_left += frame_time
		$Sprite.frame = ($Sprite.frame + 1) % $Sprite.vframes
		
	# Determine next target if none
	if target_pos == null:
		target_pos = get_next_target()
	var target_px_pos = map.calc_px_pos_on_tile(target_pos)
	
	# Check if current target in vicinity
	timer += delta
	var d:float = position.distance_to(target_px_pos)
	if d > 10:
		$Sprite.rotation_degrees = fmod(angle + 5 * sin(2 * timer * (2*PI)), 360)
		position = position.linear_interpolate(target_px_pos, (SPEED * delta)/d)
	else:
		if map.blocks.has(target_pos) and map.blocks[target_pos].ressource_name_or_null() == "bamboo":
			start_working_on_ressource(map.blocks[target_pos])
		target_pos = null
		
func get_next_target():
	var cell_pos = map.calc_closest_tile_from(position)
	var valid = []
	var bamboo = []
	
	for adjacent in map.get_adjacent_tiles(cell_pos):
		if map.landscapes.has(adjacent) and (!map.blocks.has(adjacent) or map.blocks[adjacent].is_passable()):
			valid.append(adjacent)
		if map.blocks.has(adjacent) and map.blocks[adjacent].ressource_name_or_null() == "bamboo":
			bamboo.append(adjacent)
	
	var target
	if bamboo.size() > 0:
		target = bamboo[randi()%bamboo.size()]
	else:
		if valid.size() > 0:
			target = valid[randi()%valid.size()]
		else:
			target = cell_pos
	
	var dir = map.calc_px_pos_on_tile(target) - position
	angle = (360) * dir.angle() / (2*PI) + 90
	
	return target

func start_working_on_ressource(ressource):
	working_on_ressource = true
	job_on = ressource
	job_time_left = 4 * ressource.ressource_work_time()
	
	get_node("Particles_" + ressource.ressource_name_or_null()).emitting = true
	
func stepped_on():
	hill.bug_has_died()
	queue_free()
	