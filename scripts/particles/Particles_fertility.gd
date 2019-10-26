extends Node2D

const frag = 8

var inited = false

func _ready():
	if !inited: init()

func init():
	for node in get_children():
		if node == $P1:
			node.emitting = false
		else:
			node.queue_free()
	
	for i in range(2, frag + 1):
		var node = $P1.duplicate()
		node.set_name("P" + str(i))
		node.rotation_degrees += randi() % 160 - 80
		add_child(node)
		
	inited = true

func update_fertility(fertility):
	if !inited: init()
	var tier = fertility * frag
	for i in range(0, frag):
		get_children()[i].emitting = i+1 <= tier
	return self