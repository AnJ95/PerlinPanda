extends Node2D

export var is_deco = false

var map
var cell_pos
var cell_info
var fire_level = 0.0

func prep(map, cell_pos, cell_info):
	self.map = map
	self.cell_pos = cell_pos
	self.cell_info = cell_info
	position = map.calc_px_pos_on_tile(cell_pos)
	return self

func _process(delta):
	if is_deco:
		fire_level = 2
	else:
		# Get landscape and block
		var landscape = map.landscapes[cell_pos]
		var block = null
		if map.blocks.has(cell_pos):
			block = map.blocks[cell_pos]
	
		# Determine time to increase fire strength and increase
		var fire_increase_time = landscape.get_fire_increase_time()
		if block != null:
			fire_increase_time = min(block.get_fire_increase_time(), fire_increase_time)
		increase_fire_level(delta / fire_increase_time)
	
	update_visuals()

func increase_fire_level(add):
	if !is_deco:
		fire_level += add
		
		# if above max: burn both landscape and map
		if fire_level >= 3:
			if map.blocks.has(cell_pos):
				map.blocks[cell_pos].got_burned_to_the_ground()
			map.landscapes[cell_pos].got_burned_to_the_ground()
			queue_free()
	else:
		fire_level = 2
	update_visuals()
	
func extinguish():
	map.landscapes[cell_pos].extinguished_fire()
	if map.blocks.has(cell_pos):
		map.blocks[cell_pos].extinguished_fire()
	queue_free()
		
func decrease_fire_level(mal):
	fire_level -= mal
	# if strengh==0: extinguish fire on both landscape and map
	if fire_level <= 0:
		extinguish()
	update_visuals()
			
func update_visuals():
	var strength = max(0, min(3, ceil(fire_level)))
	
	$Outer_1.emitting = strength >= 1
	$Outer_2.emitting = strength >= 2
	$Outer_3.emitting = strength >= 3
	$Smoke_1.emitting = strength >= 1
	$Smoke_2.emitting = strength >= 2
	$Smoke_3.emitting = strength >= 3
	
	$Light2D.texture_scale = 2 + fire_level
	$Light2D.energy = 0.4 + 0.1*fire_level
