extends CanvasLayer

var cam
func _ready():
	cam = get_tree().get_nodes_in_group("camera")[0]

func _process(_delta:float):
	var rect = get_viewport().get_visible_rect().size
	scale = Vector2(1.0/cam.zoom.x, 1.0/cam.zoom.y)
	offset = (-cam.offset + get_parent().global_position)/cam.zoom.x + rect/2.0