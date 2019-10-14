extends Camera2D

var dragging = false
var drag_offset = Vector2()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			dragging = true
			drag_offset = event.position + offset
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		if (event.position - drag_offset).length() > 4:
			offset = drag_offset - event.position
