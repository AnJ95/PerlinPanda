extends Particles2D

export var destroy_after = 1

func _process(delta):
	destroy_after -= delta
	if destroy_after <= 0:
		queue_free()