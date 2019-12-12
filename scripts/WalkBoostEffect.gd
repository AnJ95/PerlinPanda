tool
extends Sprite

const PANDA_EFFECT_TIME = 15

func _ready():
	pass

var map
var cell_pos
var ownr

func init(map, cell_pos, ownr):
	self.map = map
	self.cell_pos = cell_pos
	self.ownr = ownr
	
	position = map.calc_px_pos_on_tile(cell_pos)
	
	return self
	
func _process(_delta):
	var pos = map.calc_px_pos_on_tile(cell_pos)
	for panda in map.get_tree().get_nodes_in_group("panda"):
		if pos.distance_squared_to(panda.position) <= (2*105)*(2*105) and pos.distance_to(panda.position) <= (2*105):
			panda.apply_effect({"speed": 1.5}, PANDA_EFFECT_TIME)