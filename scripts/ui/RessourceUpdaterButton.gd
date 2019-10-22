extends ColorRect

var ownr
var is_plus
var ressource

func init(ownr, is_plus, ressource):
	self.ownr = ownr
	self.is_plus = is_plus
	self.ressource = ressource
	if is_plus:
		$Label.text = "+"
	else:
		$Label.text = "-"
	return self

func _mouse_entered():
	color.a = 0.1
	
func _mouse_exited():
	color.a = 0.0

func _gui_input(event:InputEvent):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			color.a = 0.2
			clicked()
		else:
			color.a = 0.1
			
		return true

func clicked():
	if ownr != null:
		var change = -1
		if is_plus:
			change = 1
		ownr.attempt_change(ressource, change)

			