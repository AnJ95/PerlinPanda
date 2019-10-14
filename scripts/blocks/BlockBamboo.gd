extends "Block.gd"


func initOverload(map, cell_pos3, stock):
	self.stock = stock
	return .init(map, cell_pos3)
	
func get_tile_id():
	return randi()%2+0
	
func ressource_name_or_null():
	return "bamboo"
func ressource_work_time():
	return 3
func get_ressource_amount():
	return 1
func get_sprite_num():
	return 4
	
func get_stack_increase_prob():
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
	if num_spreading > 0:
		var prob_to_spread = 80 * (num_spreading / float(num_spreading + num_non_spreading))
		return prob_to_spread
	return 0