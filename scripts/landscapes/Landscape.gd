extends Object


var map
var cell_pos
var cell_info
var args
var nth

func init(map, cell_pos, cell_info, args, nth):
	self.map = map
	self.cell_pos = cell_pos
	self.cell_info = cell_info
	self.args = args
	self.nth = nth
	if !args.has("var"):
		if get_max_var() > 0:
			args.var = randi() % (get_max_var() + 1)
		else:
			args.var = 0
	update_tile()
	return self
	

	
func update_tile():
	var tile_id = get_tile_id()
	
	# add variance id offset (always to right)
	tile_id += args["var"]
	
	# add tile id offset for height
	tile_id += map.layer_offset * cell_info.height
	
	# set tile id
	map.map_landscape.set_cellv(cell_pos, tile_id);

func time_update(_time:float):
	pass
		
func get_tile_id():
	return 0
	
func get_max_var():
	return 0
	
func panda_in_center(_panda):
	pass
	
func tick():
	pass
	
func can_spread_grass():
	return false
	
func get_speed_factor():
	return 1.0

func can_build_on(_map, _cell_pos):
	return true
	
func remove():
	map.landscapes.erase(cell_pos)


func get_adjacent_spreadable_percent():
	var num_spreading = 0
	var num_non_spreading = 0
	for y in range(-cell_pos.y-4, cell_pos.y+4):
		for x in range(-cell_pos.x-4, cell_pos.x+4):
			var pos = Vector2(x, y)
			if pos == cell_pos:
				continue

			var a = map.map_landscape.map_to_world(cell_pos, false)
			var b = map.map_landscape.map_to_world(pos, false)
			if map.landscapes.has(pos) and map.landscapes[pos] != null:
				if a.distance_to(b) <= 105:
					if map.landscapes[pos].can_spread_grass():
						num_spreading += 1
					else:
						num_non_spreading += 1
	if num_spreading == 0:
		return 0
	else:
		return 100 * (num_spreading / float(num_spreading + num_non_spreading))
