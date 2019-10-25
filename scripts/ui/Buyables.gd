extends PanelContainer


func _ready():
	var g = load("res://scripts/NonToolFix.gd").new().g()
	
	# Set unique and constant unlocked_id
	var locked_id = 0
	for locked in $Locked.get_children():
		locked.locked_id = locked_id
		locked_id += 1
	
	var locked_buyables = $Locked.get_children()
	
	# Unlock all in debug mode
	if get_parent().get_parent().get_parent().get_node("Map").debug_mode:		
		g.unlocked_buyables = []
		for locked in $Locked.get_children():
			g.unlocked_buyables.append(locked.locked_id)
		
	# add previously unlocked buildings
	for locked_id in g.unlocked_buyables:
		var locked = locked_buyables[locked_id]
		locked.get_parent().remove_child(locked)
		$Unlocked.add_child(locked)

