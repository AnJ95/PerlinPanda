extends "Block.gd"

func initOverload(map, cell_pos3, stock):
	self.stock = stock
	return .init(map, cell_pos3)

func get_tile_id():
	return randi()%2+2
	
func ressource_name_or_null():
	return "stone"
func ressource_work_time():
	return 6
func get_ressource_amount():
	return 1
func get_sprite_num():
	return 4


func get_ressource_amount_after_work_done():
	var amount = .get_ressource_amount_after_work_done()
	if stock == 0:
		remove()
	return amount
	
	