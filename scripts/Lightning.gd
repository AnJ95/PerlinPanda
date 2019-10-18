tool
extends Node2D

const FRAME_TIME = 0.19
const FRAME_SEQ = [0, 1, 2, 3, 2, 3, 2]

const STRUCK_AT_ID = 2
var frame_id = 0

var frame_time = 0.0

var map
var cell_pos
func init(map, cell_pos):
	self.map = map
	self.cell_pos = cell_pos
	
	position = map.calc_px_pos_on_tile(cell_pos)
	
	return self
	
func _process(delta):
	frame_time += delta
	if frame_time >= FRAME_TIME:
		frame_time -= FRAME_TIME
		# if has next
		if frame_id < FRAME_SEQ.size() - 1:
			frame_id += 1
			$Bolt.frame = FRAME_SEQ[frame_id]
			# fire extras at STRUCK_AT_ID frame id
			if frame_id == STRUCK_AT_ID:
				strike()
		else:
			if !Engine.editor_hint:
				queue_free()

func strike():
	var end_scale = Vector2(40, 40)
	var end_mod = Color(1,1,1,0.0)
	$Light.scale = Vector2(1,1)
	$Light.modulate = Color(1,1,1,0.6)
	print("STRIKE")
	$Tween.interpolate_property($Light, "modulate", $Light.modulate, end_mod, FRAME_TIME*2, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()
	$Tween.interpolate_property($Light, "scale", $Light.scale, end_scale, FRAME_TIME / 2.0, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()
	pass
	# TODO spawn fire @ cell_pos