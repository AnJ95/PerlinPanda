extends Object


var map
var cell_pos
var cell_info
var args
var nth

var stock:int

var is_bamboo = false
var is_wip = false


func init(map, cell_pos, cell_info, args, nth):
	self.map = map
	self.cell_pos = cell_pos
	self.cell_info = cell_info
	self.args = args
	self.nth = nth
	
	update_tile()
	
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
	stock = max(0, int(stock) - 1)
	
	update_tile()
	
	return 1

func update_tile():
	var tile_id = get_tile_id()
	
	# add variance id offset (always to right)
	if args.has("var"):
		tile_id += args["var"]
	
	# add stock id offset if this is a ressource (always to top with rising stock)
	if args.has("stock"):
		stock = args["stock"]
	if ressource_name_or_null() != null:
		tile_id += (get_max_stock() - stock) * map.tile_cols
	
	# add tile id offset for height
	tile_id += map.tile_height_id_dst * cell_info.height
	
	# set tile id
	map.map_blocks.set_cellv(cell_pos, tile_id);
		
func tick():
	if ressource_name_or_null() != null and randi()%100 < get_stack_increase_prob():
		stock = min(int(get_max_stock()), int(stock) + 1)
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
func get_build_time():
	return 8.0
	
func get_stack_increase_prob():
	return 0
	
func is_passable():
	return false
	
func can_be_build_on(map, cell_pos):
	return !map.blocks.has(cell_pos)
	
func remove():
	map.blocks.erase(cell_pos)
	