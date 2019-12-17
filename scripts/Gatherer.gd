extends Node2D

var map
var nth
var ressourceManager

var timer = 0

# for working on ressource
var working_on_ressource = false
# for building
var building = false
# for working and building
var job_on = null
var job_time_left = 1

onready var inventory = $Inventory

func init(map, nth):
	self.map = map
	self.nth = nth
	
func _ready():
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
	else:
		ressourceManager = null
	inventory = inventory.init(self, true, {}, max_inventory())

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
				inventory.add(job_on.ressource_name_or_null(), job_on.get_ressource_amount_after_work_done())
				if self.is_in_group("panda"):
					ressourceManager.ressources_gathered += 1
		#### NOT DONE
		else:
			var angle = 15*sin(5 * (job_on.ressource_work_time() - job_time_left) * (2*PI))
			$Sprite.rotation_degrees = angle
			return true# prevent path walking

func start_building(BlockWIP):
	building = true
	job_on = BlockWIP
	job_time_left = BlockWIP.get_build_time()
	
	
	$Particles_bamboo.emitting = BlockWIP.inventory.maximums.bamboo > 0
	$Particles_stone.emitting = BlockWIP.inventory.maximums.stone > 0
	$Particles_leaves.emitting = BlockWIP.inventory.maximums.leaves > 0
	
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
	$Particles_leaves.emitting = false
####################################
## MOVEMENT
var direction = Vector2(0,0)
func move_towards_then(target_cell, speed, delta):
	var target_pos = map.calc_px_pos_on_tile(target_cell)
	
	direction = (target_pos - position).normalized()
	# Check if current target in vicinity
	var d:float = position.distance_to(target_pos)
	
	var wiggle = get_sprite_wiggle_amp_freq()
	$Sprite.rotation_degrees = get_sprite_angle() + wiggle[0] * sin(wiggle[1] * timer * (2*PI))
		
	if d > speed / 15.0:
		position = position.linear_interpolate(target_pos, (speed * delta)/d)
		return false
	elif d > speed / 30.0:
		position = position.linear_interpolate(target_pos, 0.5*(speed * delta)/d)
		return false
	elif d > speed / 60.0:
		position = position.linear_interpolate(target_pos, 0.25*(speed * delta)/d)
		return false
	else:
		return true
func get_sprite_angle():
	return 0
func get_sprite_wiggle_amp_freq():
	return [8, 1]


####################################
## INVENTORY

func max_inventory():
	return {}

func notify_inventory_increase(_ressource, _amount):
	pass

	
	
