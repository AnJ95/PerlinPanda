extends Node2D



func init(pos, rot, dir):
	position = pos
	rotation_degrees = rot
	
	var flow_rot = rot - 90
	
	flow_rot = 90
	if !dir:
		flow_rot += 180
	
	$Sprite.material = $Sprite.material.duplicate(true)
	$Sprite.material.set_shader_param("direction", Vector2(1.0, 0.0).rotated(deg2rad(flow_rot)))
	return self