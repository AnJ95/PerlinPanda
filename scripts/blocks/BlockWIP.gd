extends "Block.gd"

var Panda;
var actual_block;

func initOverload(map, cell_pos3, Panda, actual_class):
	is_wip = true
	self.Panda = Panda
	self.actual_block = actual_class.new()
	
	return .init(map, cell_pos3)

func inst_actual_block():
	map.blocks[Vector2(cell_pos3.x, cell_pos3.y)] = actual_block.initOverload(map, cell_pos3, Panda)
	
func get_tile_id():
	return 4 + 4 * 6
	
func get_speed_factor():
	return 1.2
	
func ressource_name_or_null():
	return null
	
func panda_in_center(panda):
	panda.start_building(self)