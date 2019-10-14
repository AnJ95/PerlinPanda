extends Camera2D

var dragging = false
var drag_offset = Vector2()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom.x = min(2, zoom.x * 1.02)
				zoom.y = min(2, zoom.y * 1.02)
				return
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom.x = max(1, zoom.x / 1.02)
				zoom.y = max(1, zoom.y / 1.02)
				return
			dragging = true
			drag_offset = event.position + offset
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		if (event.position - drag_offset).length() > 4:
			offset = drag_offset - event.position
