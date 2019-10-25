extends ColorRect


var pressed = false

var map
var panda

func init(map, cell_pos, house):
	self.map = map
	self.panda = house.panda
	rect_position = map.calc_px_pos_on_tile(cell_pos) + Vector2(-30, 10)
	hide()
	return self

func can_currently_repeat():
	return panda.path != null or panda.next_paths.size() > 0

func on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
		if pressed or can_currently_repeat():
			set_pressed(!pressed)
			panda.set_repeat(pressed)
		get_tree().set_input_as_handled()
		return true

func set_pressed(pressed):
	self.pressed = pressed
	$Sprite.modulate = map.y(pressed, Color(0.8,0.3,0.2,0.8), Color(1,1,1,0.8))
		
func house_mouse_enter():
	if can_currently_repeat():
		show()
	
func house_mouse_leave():
	if !pressed:
		hide()
