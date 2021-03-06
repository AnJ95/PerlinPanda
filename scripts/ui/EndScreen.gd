tool
extends Node2D

var active = false

const anim_text_frame_time = 1
var playing_text_anim = true
var cur_text_id = -1
var anim_text_time_left = anim_text_frame_time

export var signal_listening_to = "island_restored"
export var won = true
export var anim_nodes = [[], ["TextMain", "ColorRect"], "bamboo", "panda", "TextPandas", "TextSteps", "TextRessources", "TextTime", "BtnNext"]

var anim_panda_time = 0
var ressourceManager

func _ready():
	for node in get_children():
		node.visible = false

	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
		ressourceManager.connect(signal_listening_to, self, "activate")
		
func activate():
	if active:
		return
	if won:
		$TextMain.text = "Island " + str(ressourceManager.level) + " restored!"
	$TextPandas/TextValue.text = str(ressourceManager.ressources.population)
	$TextSteps/TextValue.text = str(ressourceManager.steps_taken)
	$TextRessources/TextValue.text = str(ressourceManager.ressources_gathered)
	$TextTime/TextValue.text = str(round(ressourceManager.time / 60)) + "mins"
	
	active = true
		
func _process(delta):

	if active and playing_text_anim:
		anim_text_time_left -= delta
		if anim_text_time_left <= 0:
			anim_text_time_left = anim_text_frame_time
			cur_text_id += 1
			if cur_text_id >= anim_nodes.size():
				active = false
			else:
				if anim_nodes[cur_text_id] is Array:
					for node in anim_nodes[cur_text_id]:
						show_child(get_node(node))
				else:
					show_child(get_node(anim_nodes[cur_text_id]))
		
	anim_panda_time += delta
	if won:
		$panda.rotation_degrees = sin(anim_panda_time * 10)
	else:
		anim_panda_time += delta
		$panda.rotation_degrees = 15*sin(anim_panda_time * 5)
		if anim_panda_time > anim_text_frame_time * 10:
			$panda.position.x += delta * 110
	
func show_child(node):
	
	node.modulate = Color(1,1,1,0)
	node.visible = true
	$Tween.interpolate_property(node, "modulate", Color(1,1,1,0), Color(1,1,1,1), anim_text_time_left / 2.0, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()


func on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
		var g = load("res://scripts/NonToolFix.gd").new().g()
			
		if won:
			g.level += 1
		
		ressourceManager.reset()
		var _x = get_tree().reload_current_scene()
