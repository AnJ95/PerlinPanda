extends "Block.gd"

var panda

func initOverload(map, cell_pos3, Panda):
	.init(map, cell_pos3)
	
	if !Engine.editor_hint:
		panda = Panda.instance().prep(map, cell_pos3)
		map.get_parent().call_deferred("add_child", panda)
		map.show_homes()
	
	map.generate_next(Vector2(cell_pos3.x, cell_pos3.y), 2)
	
	
	return self
	
func get_tile_id():
	return  4
	
func get_speed_factor():
	return 1.2

func ressource_name_or_null():
	return null

