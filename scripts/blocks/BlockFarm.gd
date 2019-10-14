extends "BlockBamboo.gd"

#onready var BlockBamboo = load("BlockBamboo.gd")


func initOverload(map, cell_pos3, _Panda):
	var cell_pos = Vector2(cell_pos3.x, cell_pos3.y)
	return .initOverload(map, cell_pos3, map.blocks[cell_pos].stock)
	
func get_tile_id():
	return 5
	

func ressource_work_time():
	return 2
func get_sprite_num():
	return 5
	
func get_speed_factor():
	return 2.5
	
func get_max_stock():
	return 4
	
func get_regrow_factor():
	return 1.4
	
func can_be_build_on(map, cell_pos):
	return map.blocks.has(cell_pos) and map.blocks[cell_pos].is_bamboo