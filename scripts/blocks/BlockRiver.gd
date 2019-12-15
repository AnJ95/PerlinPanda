extends "Block.gd"

var river_parts = []

func get_class(): return "BlockRiver"

func init(map, cell_pos, cell_info, args, nth):
	.init(map, cell_pos, cell_info, args, nth)
	
	
	var adjs = cell_info.river_prev + cell_info.river_next
	
	var pos = map.map_blocks.map_to_world(cell_pos)
	pos.y += map.layer_px_dst * cell_info.height
	
	for adj in cell_info.river_prev:
		var rot = map.map_blocks.map_to_world(cell_pos).angle_to_point(map.map_blocks.map_to_world(adj))
		rot = rot/(2.0*PI)*360.0 + 90
		var river = nth.River.instance()
		map.get_node("Navigation2D/MiddleHolder").add_child(river.init(pos, rot, true))
	for adj in cell_info.river_next:
		var rot = map.map_blocks.map_to_world(cell_pos).angle_to_point(map.map_blocks.map_to_world(adj))
		rot = rot/(2.0*PI)*360.0 + 90
		var river = nth.River.instance()
		map.get_node("Navigation2D/MiddleHolder").add_child(river.init(pos, rot, false))
	
	return self
	
	
func remove():
	.remove()
	for part in river_parts:
		part.queue_free()
	

func get_tile_id():
	return 11 + 6*12

func get_speed_factor():
	return 2.3

func shields_landscape_durability():
	return true

