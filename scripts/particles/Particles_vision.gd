extends Particles2D
var time_to_start = 0.2
var time_left
var has_emitted = false
func init(radius, pos):
	position = pos
	time_left = 0.4 * (radius+1)
	lifetime = time_left
	#process_material.scale = radius+2
	scale = Vector2(radius+2, radius+2)
	return self

func _ready():
	emitting = false
	
	
func _process(delta):
	pass
	time_to_start -= delta
	if time_to_start <= 0:
		if !has_emitted:
			emitting = true
			has_emitted = true
		time_left -= delta
		if time_left < -3:
			queue_free()
