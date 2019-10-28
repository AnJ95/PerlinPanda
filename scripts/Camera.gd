extends Camera2D

var dragging = false
var drag_offset = Vector2()

var has_dragged = false
var drag_start_pos

var last_mouse_pos = Vector2()

onready var map = get_parent().get_node("Map")

const ALLOW_MOUSE_DRAG = true
const ALLOW_WASD_DRAG = true

const WASD_CAM_MOVE_ACCEL = 29.0
const WASD_CAM_MOVE_MAX_VEL = 400
var wasd_cam_move_vel = Vector2(0, 0)

func input(event):
	
		
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP and event.is_pressed():
		zoom.x = min(3.5, zoom.x * 1.03)
		zoom.y = min(3.5, zoom.y * 1.03)
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN and event.is_pressed():
		zoom.x = max(1, zoom.x / 1.03)
		zoom.y = max(1, zoom.y / 1.03)
		
	if ALLOW_MOUSE_DRAG:
		if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT:
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
				if event.scancode == 81: # Q
					map.set_block_by_descriptor(cell_pos, "artefact")
				if event.scancode == 66: # B
					map.set_block_by_descriptor(cell_pos, "bughill_var_2")
					map.blocks[cell_pos].spawn()

func _process(delta):
	if !ALLOW_WASD_DRAG:
		return
	var move_dir = Vector2()
	for action in wasd_map:
		var dir = wasd_map[action]
		if Input.is_action_pressed(action):
			move_dir += dir
		else:
			var relevantVel = wasd_cam_move_vel.x; if dir.y != 0: relevantVel = wasd_cam_move_vel.y
			var relevantDir = dir.x; if dir.y != 0: relevantDir = dir.y
			if relevantVel * relevantDir > 0:
				move_dir -= dir
	
	wasd_cam_move_vel += WASD_CAM_MOVE_ACCEL * move_dir
	wasd_cam_move_vel.x = max(-WASD_CAM_MOVE_MAX_VEL, min(WASD_CAM_MOVE_MAX_VEL, wasd_cam_move_vel.x))
	wasd_cam_move_vel.y = max(-WASD_CAM_MOVE_MAX_VEL, min(WASD_CAM_MOVE_MAX_VEL, wasd_cam_move_vel.y))
		
	var effective_vel = Vector2(round(wasd_cam_move_vel.x), round(wasd_cam_move_vel.y))
	if abs(effective_vel.x) <= WASD_CAM_MOVE_ACCEL: effective_vel.x = 0
	if abs(effective_vel.y) <= WASD_CAM_MOVE_ACCEL: effective_vel.y = 0
	
	offset += effective_vel * delta
			
	
			
var wasd_map = {
	"ui_up": Vector2(0,-1),
	"ui_left": Vector2(-1,0),
	"ui_down": Vector2(0,1),
	"ui_right": Vector2(1,0)
}