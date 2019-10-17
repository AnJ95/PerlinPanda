extends Camera2D

var dragging = false
var drag_offset = Vector2()

var has_dragged = false

func input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				zoom.x = min(2.5, zoom.x * 1.03)
				zoom.y = min(2.5, zoom.y * 1.03)
				return
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom.x = max(1, zoom.x / 1.03)
				zoom.y = max(1, zoom.y / 1.03)
				return
			dragging = true
			has_dragged = false
			drag_offset = event.position + offset
		else:
			dragging = false
			return has_dragged
	elif event is InputEventMouseMotion and dragging:
		if (event.position - drag_offset).length() > 4:
			has_dragged = true
			offset = drag_offset - event.position
			return true
