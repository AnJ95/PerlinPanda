extends Object


var map
var cell_pos3


func init(map, cell_pos3):
	self.map = map
	self.cell_pos3 = cell_pos3
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	map.map_landscape.set_cellv(cell_pos, get_tile_id() + map.tile_height_id_dst * cell_pos3.z); # dirt
	return self

func time_update(time:float):
	pass
		
func get_tile_id():
	return 0
	
func panda_in_center(_panda):
	pass
	
func tick():
	pass
	
func can_spread_grass():
	return false
	
func get_speed_factor():
	return 1.0

func can_build_on(map, cell_pos):
	return true
	
func remove():
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	map.landscapes.erase(cell_pos)


func get_adjacent_spreadable_percent():
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	var num_spreading = 0
	var num_non_spreading = 0
	for y in range(-cell_pos3.y-4, cell_pos3.y+4):
		for x in range(-cell_pos3.x-4, cell_pos3.x+4):
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
