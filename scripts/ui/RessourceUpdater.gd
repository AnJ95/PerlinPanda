tool
extends Node2D

export var show_max:bool = true setget set_show_max
export var show_when_0:bool = true setget set_show_when_0
export var ressources = {} setget set_ressources
export var ressources_max = {} setget set_ressources_max
export var changeable:bool = true setget set_changeable

onready var classButton = preload("res://scenes/ui/RessourceUpdaterButton.tscn")
onready var classRessource = preload("res://scenes/ui/Ressource.tscn")

const RESSOURCE_HEIGHT = 37
const BORDER_WIDTH = 5
const BUTTON_WIDTH = 25

var is_ready = false 
func _ready():
	is_ready = true
	init()
	pass

func init():
	#print($Box/Ressources.rect_size)
	# clear Ressources first
	for node in $Box/Ressources.get_children():
		node.queue_free()
	
	# calc total width
	var width = 57
	if show_max:
		width += 23
	if changeable:
		width += BUTTON_WIDTH * 2
		
	# add Ressource and set basic properties
	var visible_ressources = 0
	for ressource_name in ressources:
		var value = 0
		if ressources.has(ressource_name):
			value = ressources[ressource_name]
			
		if show_when_0 or value > 0:
			visible_ressources += 1
		else:
			continue
			
		if changeable:
			var btn = classButton.instance()
			if !Engine.editor_hint: btn.init(self, false, ressource_name)
			btn.rect_position = Vector2(0, (visible_ressources-1)*RESSOURCE_HEIGHT)
			btn.rect_size = Vector2(BUTTON_WIDTH, RESSOURCE_HEIGHT)
			
			$Box.add_child(btn)
		
		var ressource = classRessource.instance()
		ressource.ressource_name = ressource_name
		ressource.texture = load("res://assets/images/" + ressource_name + ".png")
		ressource.do_update = false
		ressource.small = true
		
		ressource.value = value
		
		ressource.show_max_value = show_max
		if show_max and ressources_max.has(ressource_name):
			ressource.max_value = ressources_max[ressource_name]
		
		ressource.set_name(ressource_name)
		$Box/Ressources.add_child(ressource)
		
		if changeable:
			var btn = classButton.instance()
			if !Engine.editor_hint: btn.init(self, true, ressource_name)
			btn.rect_position = Vector2(width - BUTTON_WIDTH, (visible_ressources-1)*RESSOURCE_HEIGHT)
			btn.rect_size = Vector2(BUTTON_WIDTH, RESSOURCE_HEIGHT)
			
			$Box.add_child(btn)
		
	
	# set up positions and sizes
	$Box.rect_size = Vector2(width, RESSOURCE_HEIGHT * visible_ressources)
	$Box/Black.rect_position = Vector2(0, $Box.rect_size.y - BORDER_WIDTH)
	$Box/Black.rect_size = Vector2($Box.rect_size.x, BORDER_WIDTH)
	if changeable:
		$Box/Ressources.rect_position.x = BUTTON_WIDTH
	else:
		$Box/Ressources.rect_position.x = 1

func update():
	for ressource_name in ressources:
		var node = $Box/Ressources.get_node(ressource_name)
		node.value = ressources[ressource_name]
		node.update()

###################################
### Special initializers

func set_max_from_inventory(inventory):
	show_max = true
	ressources = {}
	ressources_max = {"bamboo":0,"stone":0,"leaves":0}
	for ressource in ressources_max:
		ressources[ressource] = 0
		ressources_max[ressource] = inventory.get(ressource)
	return self
		
func set_value_and_max_from_inventory(inventory):
	show_max = true
	ressources = {}
	ressources_max = {}
	for ressource in ressources:
		ressources[ressource] = inventory.get(ressource)
		ressources_max[ressource] = inventory.get_max(ressource)
	return self
	
func add_to_inventory(inventory):
	for ressource in ressources:
		inventory.add(ressource, ressources[ressource])
	return self
	
func set_from_ressource_block(block):
	ressources = {block.ressource_name_or_null():1}

	show_max = false
	show_when_0 = false
	changeable = false
	return self
	
func set_from_wip_block(inventory, block):
	ressources = {}
	ressources_max = {}

	for ressource in block.inventory.maximums:
		var still_needed = block.inventory.get_max(ressource) - block.inventory.get(ressource)
		ressources[ressource] = min(still_needed, inventory.get(ressource))
		ressources_max[ressource] = ressources[ressource]

	show_max = true
	show_when_0 = true
	changeable = true
	return self

###################################
func attempt_change(ressource, amount):
	var new_amount = ressources[ressource] + amount
	if new_amount >= 0 and new_amount <= ressources_max[ressource]:
		ressources[ressource] += amount
	update()
	pass
	
	
###################################
### Setgets	
func set_show_max(val):
	show_max = val
	if is_ready: init()
		
func set_show_when_0(val):
	show_when_0 = val
	if is_ready: init()
		
func set_ressources(val):
	ressources = val
	if is_ready: init()

func set_ressources_max(val):
	ressources_max = val
	if is_ready: init()
		
func set_changeable(val):
	changeable = val
	if is_ready: init()

