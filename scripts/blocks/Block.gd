extends Object


var map
var cell_pos3
var stock:int


func init(map, cell_pos3):
	self.map = map
	self.cell_pos3 = cell_pos3
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	
	var tile_id = get_tile_id()
	
	# add tile id offset stock (if this is a ressource)
	if ressource_name_or_null() != null:
		tile_id += (3 - stock) * map.tile_cols
	
	# add tile id offset for height
	tile_id += map.tile_height_id_dst * (cell_pos3.z)
	
	# set tile id
	map.map_blocks.set_cellv(cell_pos, tile_id); # bamboo
	
	return self

func get_tile_id():
	return 0
	
func panda_in_center(panda):
	if ressource_name_or_null() != null and stock > 0:
		panda.start_working_on_ressource(self)

func get_ressource_amount_after_work_done():
	# if stock was 0 before (only when multiple pandas or other influences decreased stock)
	# since shouldnt start working when stock = 0
	if stock == 0:
		return 0
	
	# decrease stock by one
	stock = max(0, stock - 1)
	
	update_tile()
	
	return 1

func update_tile():
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	# update sprite at thresholds

	var current_tile = map.map_blocks.get_cellv(cell_pos)
	var original_tile = ((current_tile % map.tile_height_id_dst) % map.tile_cols)
	var new_tile = (3-stock)*map.tile_cols + original_tile
	new_tile += map.tile_height_id_dst * cell_pos3.z
	map.map_blocks.set_cellv(cell_pos, new_tile)
		
func tick():
	if ressource_name_or_null() != null and randi()%100 < get_stack_increase_prob():
		stock = min(3, stock + 1)
		print("increased stock from " + str(stock-1) + " to " + str(stock))
		update_tile()
		print("... increased stock of ressource " + ressource_name_or_null())
	
func get_max_stock():
	return 3
func ressource_name_or_null():
	return null
func ressource_work_time():
	return 0
func get_sprite_num():
	return 4
func get_speed_factor():
	return 1.0
	
func get_stack_increase_prob():
	return 0
	
func remove():
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	map.blocks.erase(cell_pos)
	