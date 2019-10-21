extends Object


var map
var cell_pos
var cell_info
var args
var nth

var stock:int

var particle_inst

func get_class(): return "Block"

func init(map, cell_pos, cell_info, args, nth):
	self.map = map
	self.cell_pos = cell_pos
	self.cell_info = cell_info
	self.args = args
	self.nth = nth
	
	# Inventory
	if has_inventory():
		inventory = load("res://scenes/Inventory.tscn").instance().init(self, true, {}, inventory_max_values())
		inventory.position = map.calc_px_pos_on_tile(cell_pos)
		map.get_node("Navigation2D/UIHolder").call_deferred("add_child", inventory)
	
	# Particles
	particle_inst = get_particle_instance_or_null()
	if particle_inst != null:
		particle_inst.position = map.calc_px_pos_on_tile(cell_pos)
		set_particle_emitting(false)
		map.get_node("Navigation2D/ParticleHolder").add_child(particle_inst)
		
	# Randomize variant if not set
	if !args.has("var"):
		if get_max_var() > 0:
			args.var = randi() % (get_max_var()+1)
		else:
			args.var = 0
			
	# Set stock	
	if args.has("stock"):
		stock = args.stock
			
	update_tile()
	
	return self

func get_tile_id():
	return 0
	
func panda_in_center(panda):
	if fire_or_null != null:
		fire_or_null.extinguish()
	
	if ressource_name_or_null() != null and stock > 0:
		panda.start_working_on_ressource(self)

func get_ressource_amount_after_work_done():
	# if stock was 0 before (only when multiple pandas or other influences decreased stock)
	if stock == 0:
		return 0
	
	# decrease stock by one
	decrease_stock()
	
	return 1
	
func increase_stock():
	stock = min(int(get_max_stock()), int(stock) + 1)
	update_tile()
	
func decrease_stock():
	stock = max(0, int(stock) - 1)
	update_tile()

func update_tile():
	var tile_id = get_tile_id()
	
	# add variance id offset (always to right)
	tile_id += args.var
	
	# add stock id offset if this is a ressource (always to top with rising stock)
	if ressource_name_or_null() != null:
		tile_id += (get_max_stock() - stock) * map.tile_cols
	
	# add tile id offset for height
	tile_id += int(map.layer_offset * cell_info.height)
	
	# set tile id
	map.map_blocks.set_cellv(cell_pos, tile_id);
		
func tick():
	if ressource_name_or_null() != null and randi()%100 <= get_stack_increase_prob():
		var stock_before = stock
		increase_stock()
		print("... increased stock of ressource " + ressource_name_or_null() + " from " + str(stock_before) + " to " + str(stock))
	
func get_max_stock():
	return 0
func ressource_name_or_null():
	return null
func ressource_work_time():
	return 0
func time_update(_time:float):
	pass
func get_speed_factor():
	return 1.0
func get_build_time():
	return 8.0
func get_max_var():
	return 0
func get_stack_increase_prob():
	return 0
func prevents_landscape_tick():
	return false
func shields_landscape_durability():
	return false
	
func got_welled():
	pass
	
func is_passable():
	return true
	
func multiple_in_one_path_allowed():
	return false
	
func can_be_build_on(map, cell_pos):
	return !map.blocks.has(cell_pos)
	
	
###################################################	
### PARTICLES
func get_particle_instance_or_null():
	return null
	
func set_particle_emitting(emit:bool):
	if particle_inst != null:
		particle_inst.emitting = emit
	
func remove():
	if fire_or_null != null:
		fire_or_null.extinguish()
	if particle_inst != null:
		particle_inst.queue_free()
	map.blocks.erase(cell_pos)
	map.map_blocks.set_cellv(cell_pos, -1)

################################################
### FIRE
var fire_or_null = null
func try_catch_fire():
	# dont consider when landscape below is water
	if map.landscapes[cell_pos].get_class() == "LandscapeWater":
		return
	if randi()%100 <= get_prob_fire_catch():
		caught_fire()
func caught_fire():
	if fire_or_null == null:
		if !Engine.editor_hint:
			fire_or_null = nth.Fire.instance().prep(map, cell_pos, cell_info)
			map.get_node("Navigation2D/ParticleHolder").call_deferred("add_child", fire_or_null)
func extinguished_fire():
	fire_or_null = null
	
# Overrides
func get_prob_fire_catch():
	return 0
func get_fire_increase_time():
	return 7
func got_burned_to_the_ground():
	remove()
	fire_or_null = null
	pass

################################################
### INVENTORY
onready var inventoryClass = preload("res://scenes/Inventory.tscn")
var inventory

# Overrides
func has_inventory():
	return false
func inventory_max_values():
	return {}
func notify_inventory_increase(ressource, amount):
	pass

