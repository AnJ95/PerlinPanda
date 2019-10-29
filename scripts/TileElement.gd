extends Object

# init arguments
var map
var cell_pos
var cell_info
var args
var nth

func get_class(): return "TileElement"

func init(map, cell_pos, cell_info, args, nth):
	self.map = map
	self.cell_pos = cell_pos
	self.cell_info = cell_info
	self.args = args
	self.nth = nth
	
	init_particles()
	
	# Randomize variant if not set
	if !args.has("var"):
		args.var = randi() % (get_max_var()+1)
	
	update_tile()
		
###################################################	
### TILE

func get_tile_id():
	return 0
	
func get_max_var():
	return 0
	
func panda_in_center(panda):
	if fire_or_null != null:
		fire_or_null.extinguish()

func update_tile():
	printerr("Non over-written update_tile() in " + get_class())
	pass
	
func tick():
	pass
	
func get_speed_factor():
	return 1.0
	
func got_welled():
	if fire_or_null != null:
		fire_or_null.extinguish()

################################################
### FERTILITY

# Override me
func get_fertility_bonus():
	return 0
	
###################################################	
### PARTICLES
var particle_inst

func init_particles():
	particle_inst = get_particle_instance_or_null()
	if particle_inst != null:
		particle_inst.position = map.calc_px_pos_on_tile(cell_pos)
		set_particle_emitting(false)
		get_particle_holder().add_child(particle_inst)
		
func remove_particles():
	if particle_inst != null:
		particle_inst.queue_free()
		
func set_particle_emitting(emit:bool):
	if particle_inst != null:
		particle_inst.emitting = emit
		
# Override me
func get_particle_instance_or_null():
	return null

################################################
### FIRE
var fire_or_null = null

func remove_fire():
	if fire_or_null != null:
		fire_or_null.extinguish()
		
func extinguished_fire():
	fire_or_null = null
	
# Block and Landscape add custom behavior
func catch_fire():
	if fire_or_null == null and !Engine.editor_hint:
		fire_or_null = nth.Fire.instance().prep(map, cell_pos, cell_info, nth)
		get_particle_holder().call_deferred("add_child", fire_or_null)

# Override me
func get_prob_lightning_strike():
	return 0

# Override me
func get_fire_increase_time():
	return 0
	
func got_burned_to_the_ground():
	extinguished_fire()
	

################################################
### HELPERS AND GETTERS
func has_block():
	return map.blocks.has(cell_pos)
func get_block():
	return map.blocks[cell_pos]
func get_landscape():
	return map.landscapes[cell_pos]
func get_weather():
	return map.weather
func get_particle_holder():
	return map.get_node("Navigation2D/ParticleHolder")
func get_ui_holder():
	return map.get_node("Navigation2D/UIHolder")
func get_bug_holder():
	return map.get_node("Navigation2D/BugHolder")
func get_middle_holder():
	return map.get_node("Navigation2D/MiddleHolder")
		
###################################################	

func remove():
	remove_fire()
	remove_particles()