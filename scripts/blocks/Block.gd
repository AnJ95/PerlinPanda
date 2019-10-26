extends "res://scripts/TileElement.gd"

var stock:int

func get_class(): return "Block"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)

	# Inventory
	if has_inventory():
		var Inventory = load("res://scenes/Inventory.tscn")
		inventory = Inventory.instance()
		inventory = adjust_inventory(inventory).init(self, true, {}, inventory_max_values())
		inventory.position = map.calc_px_pos_on_tile(cell_pos) - Vector2(0, 100)
		get_ui_holder().call_deferred("add_child", inventory)

		scheduled_inventory = load("res://scenes/Inventory.tscn").instance().init(self, true, {}, inventory_max_values())

	# Set stock
	if args.has("stock"):
		stock = args.stock

	return self

func panda_in_center(panda):
	.panda_in_center(panda)

	if ressource_name_or_null() != null and panda.perform_next_action() and stock > 0 and panda.inventory.get_free(ressource_name_or_null()) >= 1:
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
		map.p("... increased stock of ressource " + ressource_name_or_null() + " from " + str(stock_before) + " to " + str(stock))

func get_max_stock():
	return 0
func ressource_name_or_null():
	return null
func ressource_work_time():
	return 0
func time_update(_time:float):
	pass

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

func is_passable():
	return true

func multiple_in_one_path_allowed():
	return false

func can_be_build_on(map, cell_pos):
	return !map.blocks.has(cell_pos)

func remove():
	.remove()
	if has_inventory():
		inventory.queue_free()
	map.blocks.erase(cell_pos)
	map.map_blocks.set_cellv(cell_pos, -1)

################################################
### FIRE
func catch_fire():
	# dont consider when landscape below is water
	if map.landscapes[cell_pos].get_class() == "LandscapeWater":
		return
	.catch_fire()

# Overrides
func get_fire_increase_time():
	return 7
func got_burned_to_the_ground():
	.got_burned_to_the_ground()
	remove()
	pass

################################################
### INVENTORY
var inventory
var scheduled_inventory

# Overrides

func adjust_inventory(inventory):
	return inventory
func has_inventory():
	return false
func inventory_max_values():
	return {}
func notify_inventory_increase(_ressource, _amount):
	pass
