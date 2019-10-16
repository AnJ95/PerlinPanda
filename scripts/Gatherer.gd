extends Node2D

var map
var ressourceManager

var inventory = {}

var timer = 0

# for working on ressource
var working_on_ressource = false
# for building
var building = false
# for working and building
var job_on = null
var job_time_left = 1

func init(map):
	self.map = map
	
func _ready():
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
		ressourceManager.add_ressource("population", 1)
	else:
		ressourceManager = null
	update_inventory_view()

func _process(delta:float):
	timer += delta

####################################
## OVERRIDES
func can_gather():
	return false
func gatherable_ressources():
	return []
func can_build():
	return false
	
#####################################
## GATHERING AND BUILDING
func gather_and_build(delta, speed_factor):
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
		#### NOT DONE
		else:
			var angle = 15*sin(5 * (job_on.ressource_work_time() - job_time_left) * (2*PI))
			$Sprite.rotation_degrees = angle
			return true# prevent path walking

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
	if ressource.ressource_name_or_null() in gatherable_ressources():
		working_on_ressource = true
		job_on = ressource
		job_time_left = ressource.ressource_work_time()
		get_node("Particles_" + ressource.ressource_name_or_null()).emitting = true
	
func stop_particles():
	$Particles_bamboo.emitting = false
	$Particles_stone.emitting = false
####################################
## MOVEMENT
func move_towards_then(target_cell, speed, delta):
	var target_pos = map.calc_px_pos_on_tile(target_cell)
	
	# Check if current target in vicinity
	var d:float = position.distance_to(target_pos)
	if d > 10:
		var wiggle = get_sprite_wiggle_amp_freq()
		$Sprite.rotation_degrees = get_sprite_angle() + wiggle[0] * sin(wiggle[1] * timer * (2*PI))
		position = position.linear_interpolate(target_pos, (speed * delta)/d)
		return false
	else:
		return true
func get_sprite_angle():
	return 0
func get_sprite_wiggle_amp_freq():
	return [8, 1]


####################################
## INVENTORY

func move_inventory_to_target():
	for res_name in inventory.keys():
		inventory_emptied(res_name, inventory[res_name])
		inventory.erase(res_name)
	update_inventory_view()

func move_inventory_to_other_gatherer(other):
	for res_name in inventory.keys():
		other.add_to_inventory(res_name, inventory[res_name])

func inventory_emptied(res_name, value):
	pass
	
		
func add_to_inventory(res_name, res_value):
	if !inventory.has(res_name):
		inventory[res_name] = res_value
	else:
		inventory[res_name] += res_value
	update_inventory_view()

func update_inventory_view():
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
		
	
