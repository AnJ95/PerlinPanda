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
	
