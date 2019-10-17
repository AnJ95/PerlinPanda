extends Camera2D

var dragging = false
var drag_offset = Vector2()

var has_dragged = false
var drag_start_pos

func input(event):

	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
		zoom.x = min(3.5, zoom.x * 1.03)
		zoom.y = min(3.5, zoom.y * 1.03)
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
		zoom.x = max(1, zoom.x / 1.03)
		zoom.y = max(1, zoom.y / 1.03)
				
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed():
			dragging = true
			has_dragged = false
			drag_offset = event.position + offset
			drag_start_pos = event.position 
		else:
			dragging = false
			return has_dragged
	if event is InputEventMouseMotion and dragging:
		if (event.position - drag_start_pos).length() > 12:
			has_dragged = true
			offset = drag_offset - event.position
			return true
