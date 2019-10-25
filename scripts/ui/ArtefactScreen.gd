extends Node2D

onready var unlocked_buyables = get_tree().get_nodes_in_group("unlocked_buyables")[0]
onready var locked_buyables = get_tree().get_nodes_in_group("locked_buyables")[0]
onready var buyables = $FollowLayer/Buyables

var ressourceManager
var selected_building = null

const unlock_possibilities = 3

func _ready():
	# hide and show in first _process
	buyables.modulate = Color(1,1,1,0.0)
	buyables.hide()
	
	# add Buyables to own UI
	var selecteds = select_random_buyables()
	for selected in selecteds:
		var buyable = selected.duplicate()
		# init properties to let Buyable know it's an unlockable
		buyable.locked_id = selected.locked_id
		buyable.is_unlockable = true
		buyable.unlockable_parent = self
		buyables.add_child(buyable)
		
	# reposition UI
	var ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0: self.ressourceManager = ressourceManager[0]
		
var appeared = false
var time_left_to_appearing = 1.5
func _process(delta):
	buyables.rect_position = Vector2(-buyables.rect_size.x / 2.0, -184)
	
	if !appeared:
		time_left_to_appearing -= delta
		if time_left_to_appearing <= 0:
			buyables.show()
			appeared = true
			$Tween.interpolate_property(buyables, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
			$Tween.start()
	if disappearing:
		time_left_until_disappeared -= delta
		if time_left_until_disappeared <= 0:
			queue_free()
			

func on_click_buyable(buyable):
	var dupl = buyable.duplicate()
	
	dupl.is_active = true
	dupl.is_unlockable = false
	dupl.unlockable_parent = null
	dupl.locked_id = buyable.locked_id
	
	# remove from list of unlockables
	for locked in locked_buyables.get_children():
		if locked.locked_id == dupl.locked_id:
			locked.queue_free()
			
	# dont add duplicates to ui ()
	var already_unlocked = false
	for unlocked in unlocked_buyables.get_children():
		if unlocked.locked_id == dupl.locked_id:
			already_unlocked = true
			
	# add to ui
	if !already_unlocked:
		unlocked_buyables.add_child(dupl)
		dupl.highlight()
	
	after_select(dupl)

var disappearing = false
var time_left_until_disappeared = 1.5
func after_select(dupl):
	ressourceManager.on_artefact_selected(dupl)
	$Tween.interpolate_property(buyables, "modulate", buyables.modulate, Color(1,1,1,0), time_left_until_disappeared, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()
	disappearing = true

func set_position(pos:Vector2):
	position = pos
	return self
	
func select_random_buyables():
	var selected_ids = []
	var left = locked_buyables.get_children().size()
	for i in range(min(unlock_possibilities, left)):
		var selected_id = randi()%left
		while selected_ids.find(selected_id) != -1:
			selected_id = randi()%left
		selected_ids.append(selected_id)


	var selected = []
	for selected_id in selected_ids:
		selected.append(locked_buyables.get_children()[selected_id])
		
	return selected
