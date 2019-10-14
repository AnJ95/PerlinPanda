extends "Block.gd"

var panda

func initOverload(map, cell_pos3, _Panda):
	.init(map, cell_pos3)
	map.generate_next(Vector2(cell_pos3.x, cell_pos3.y), 1)
	return self
	
func get_tile_id():
	return 14

func get_speed_factor():
	return 2.5
	
func ressource_name_or_null():
	return null

