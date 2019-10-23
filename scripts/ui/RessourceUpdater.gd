tool
extends Node2D

var show:bool = true
export var show_max:bool = true setget set_show_max
export var show_when_0:bool = true setget set_show_when_0
export var show_when_max_0:bool = true
export var show_when_max_undefined:bool = true

export var ressources = {} setget set_ressources
export var ressources_max = {} setget set_ressources_max
export var changeable:bool = true setget set_changeable
export var signum:int = 1
onready var classButton = preload("res://scenes/ui/RessourceUpdaterButton.tscn")
onready var classRessource = preload("res://scenes/ui/Ressource.tscn")

const RESSOURCE_HEIGHT = 37
const BORDER_WIDTH = 5
const BUTTON_WIDTH = 25

var ress = {}
var btns = []

var is_ready = false 
func _ready():
	is_ready = true
	init()
	pass

func init():
	# clear Ressources first
	for node in $Box/Ressources.get_children():
		node.queue_free()
	for res in ress:
		ress[res].queue_free()
	ress = {}
	for node in btns:
		node.queue_free()
	btns = []
	
	# calc total width
	var width = 57
	var res_width = width
	if show_max:
		width += 23
		res_width = width
	if changeable:
		width += BUTTON_WIDTH * 2
		
	# add Ressource and set basic properties
	var visible_ressources = 0
	for ressource_name in ressources:
		var value = 0
		if ressources.has(ressource_name):
			value = ressources[ressource_name]
			
		if (show_when_0 or value > 0) and (show_when_max_0 or ressources_max.has(ressource_name) and ressources_max[ressource_name] > 0) and (show_when_max_undefined or ressources_max.has(ressource_name)):
			visible_ressources += 1
		else:
			continue
			
		if changeable:
			var btn = classButton.instance()
			if !Engine.editor_hint: btn.init(self, false, ressource_name)
			btn.rect_position = Vector2(0, (visible_ressources-1)*RESSOURCE_HEIGHT)
			btn.rect_size = Vector2(BUTTON_WIDTH, RESSOURCE_HEIGHT)
			
			$Box.add_child(btn)
			btns.append(btn)
		
		var ressource = classRessource.instance()
		ressource.ressource_name = ressource_name
		ressource.texture = load("res://assets/images/" + ressource_name + ".png")
		ressource.do_update = false
		ressource.small = true
		
		ressource.value = value
		
		ressource.rect_size = Vector2(res_width, RESSOURCE_HEIGHT)
		
		ressource.show_max_value = show_max
		if show_max and ressources_max.has(ressource_name):
			ressource.max_value = ressources_max[ressource_name]
		
		ress[ressource_name] = ressource
		$Box/Ressources.add_child(ressource)
		
		if changeable:
			var btn = classButton.instance()
			if !Engine.editor_hint: btn.init(self, true, ressource_name)
			btn.rect_position = Vector2(width - BUTTON_WIDTH, (visible_ressources-1)*RESSOURCE_HEIGHT)
			btn.rect_size = Vector2(BUTTON_WIDTH, RESSOURCE_HEIGHT)
			
			$Box.add_child(btn)
			btns.append(btn)
		
	
	# set up positions and sizes
	$Box.rect_size = Vector2(width, RESSOURCE_HEIGHT * visible_ressources)
	$Box/Black.rect_position = Vector2(0, $Box.rect_size.y - BORDER_WIDTH)
	$Box/Black.rect_size = Vector2($Box.rect_size.x, BORDER_WIDTH)
	$Box/Ressources.rect_size = Vector2(res_width, RESSOURCE_HEIGHT * visible_ressources)
	if changeable:
		$Box/Ressources.rect_position.x = BUTTON_WIDTH
	else:
		$Box/Ressources.rect_position.x = 1
		
	position -= Vector2(width / 2.0, -40)

func update():
	if is_ready:
		for ressource_name in ressources:
			var node = ress[ressource_name]
			node.value = ressources[ressource_name]
			if show_max and ressources_max.has(ressource_name):
				node.max_value = ressources_max[ressource_name]
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
		inventory.add(ressource, signum*ressources[ressource])
	return self
	
func set_from_ressource_block(panda_inventory, _taking_from_home, _house_inventory, block):
	var res = block.ressource_name_or_null()
	ressources = {res : min(1, panda_inventory.get_free(res))}

	show_max = false
	show_when_0 = false
	changeable = false
	return self
	
func set_from_foreign_house(panda_inventory, taking_from_home, house_inventory, block):
	ressources = {}
	ressources_max = {}
	for res in panda_inventory.inventory:
		ressources[res] = panda_inventory.get(res)
		ressources_max[res] = panda_inventory.get(res) + house_inventory.get(res) - taking_from_home.ressources[res]
	signum = -1
	changeable = false
	return self
	
func set_from_own_house(_panda_inventory, _taking_from_home, _house_inventory, _block):
	ressources = {"bamboo":0,"stone":0,"leaves":0}
	ressources_max = {}
	show = false
	changeable = false
	return self
	
func set_from_smoker(panda_inventory, taking_from_home, house_inventory, block):
	ressources = {}
	ressources_max = {}
	ressources["leaves"] = min(panda_inventory.get("leaves"), block.inventory.get_free("leaves"))
	ressources_max["leaves"] = panda_inventory.get("leaves") + house_inventory.get("leaves") - taking_from_home.ressources["leaves"]
	signum = -1
	changeable = false
	return self
	
func set_from_wip_block(panda_inventory, taking_from_home, house_inventory, block):
	ressources = {}
	ressources_max = {}

	for res in block.inventory.maximums:
		if block.inventory.maximums[res] > 0:
			var still_needed = block.inventory.get_max(res) - block.inventory.get(res)
			ressources[res] = min(still_needed, panda_inventory.get(res))
			ressources_max[res] = panda_inventory.get(res) + house_inventory.get(res) - taking_from_home.ressources[res]
	
	signum = -1
	show_max = true
	show_when_max_undefined = false
	changeable = false
	return self

###################################
var changes = {}
func attempt_change(ressource, amount):
	var new_amount = ressources[ressource] + amount
	if new_amount >= 0 and new_amount <= ressources_max[ressource]:
		ressources[ressource] += amount
		if amount != new_amount:
			if !changes.has(ressource): changes[ressource] = 0
			changes[ressource] += new_amount - amount
		update()
	

var subscriber = null
func set_subscriber(subscriber):
	self.subscriber = subscriber
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
	
###################################
func _to_string():
	return "RessourceUpdater(" + str(signum) + "*" + str(ressources) + " / " + str(ressources_max) + ")"
