extends Camera2D

var dragging = false
var drag_offset = Vector2()

var has_dragged = false
var drag_start_pos

var last_mouse_pos = Vector2()

onready var map = get_parent().get_node("Map")

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
	if event is InputEventMouseMotion:
		last_mouse_pos = event.position
		if dragging:
			if (event.position - drag_start_pos).length() > 12:
				has_dragged = true
				offset = drag_offset - event.position
				return true
			
	if map.debug_mode:
		if event is InputEventKey and !event.pressed:
			var rect = get_viewport().get_visible_rect().size
			var click_pos = (last_mouse_pos - rect / 2) * zoom + offset
			var cell_pos = map.calc_closest_tile_from(click_pos)
			
			if cell_pos != null:
				if event.scancode == 76: # L
					var lightning = load("res://scenes/lightning.tscn").instance().init(map, cell_pos)
					map.get_node("Navigation2D/PandaHolder").add_child(lightning)
				if event.scancode == 65: # A
					map.set_block_by_descriptor(cell_pos, "artefact")
				if event.scancode == 66: # B
					map.set_block_by_descriptor(cell_pos, "bughill_var_2")
					map.blocks[cell_pos].spawn()

			
