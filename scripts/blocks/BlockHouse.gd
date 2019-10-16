extends "Block.gd"

var panda

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	
	if !Engine.editor_hint:
		panda = nth.Panda.instance().prep(map, cell_pos, cell_info)
		map.get_parent().call_deferred("add_child", panda)
		map.show_homes()
	
	map.generate_next(cell_pos, 2)

	return self
	
func get_tile_id():
	return  4
	
func get_speed_factor():
	return 1.5

func ressource_name_or_null():
	return null

