extends Particles2D
var time_to_start = 0.2
var time_left
func init(radius, pos):
	position = pos
	time_left = 0.8 * (radius+1)
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
		emitting = true
	#time_left -= delta
	#if time_left < -3:
	#	queue_free()
