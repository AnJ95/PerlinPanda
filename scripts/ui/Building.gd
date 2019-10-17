tool
extends Button

export var block_tile_id:int setget set_block_tile_id
export var costs_bamboo:int setget set_costs_bamboo
export var costs_stone:int setget set_costs_stone
export var costs_leaves:int setget set_costs_leaves

const col_yes:Color = Color(0.4,0.8,0.4, 255.0/255.0)
const col_no:Color = Color(0.8,0.5,0.4, 255.0/255.0)
const col_active:Color = Color(0.4,1,0.4, 255.0/255.0)

var ressourceManager
var buildManager

onready var sprite = $HBoxContainer/TextureRect/Sprite
onready var costsBamboo = $HBoxContainer/VBoxContainer/CostsBamboo
onready var costsStone = $HBoxContainer/VBoxContainer/CostsStone
onready var costsLeaves = $HBoxContainer/CenterContainer/CostsLeaves

var is_selected = false
var has_enough_ressources = false


func _ready():
	sprite.frame = block_tile_id
	costsBamboo.value = costs_bamboo
	costsStone.value = costs_stone
	costsLeaves.value = costs_leaves
	
	update_color()
	
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
		ressourceManager.connect("ressource_changed", self, "ressource_changed")
		ressource_changed(null, null)
	else:
		ressourceManager = null
		
	$HBoxContainer/VBoxContainer/CostsBamboo.update()
	$HBoxContainer/VBoxContainer/CostsStone.update()
	$HBoxContainer/CenterContainer/CostsLeaves.update()
		
	buildManager = get_tree().get_nodes_in_group("build_manager")
	if buildManager.size() > 0:
		buildManager = buildManager[0]
	else:
		buildManager = null
	
func ressource_changed(_ressource_name, _value):
	if !Engine.editor_hint:
		has_enough_ressources = ressourceManager.has_ressource("bamboo", costs_bamboo) and ressourceManager.has_ressource("stone", costs_stone) and ressourceManager.has_ressource("leaves", costs_leaves)
		self.disabled = !has_enough_ressources
		update_color()

func update_color():
	if is_selected:
		set_all_colors_to(col_active)
		print(col_active)
	else:
		if has_enough_ressources:
			set_all_colors_to(col_yes)
			print(col_yes)
		else:
			set_all_colors_to(col_no)
			print(col_no)
		

func set_all_colors_to(c):
	self.get_stylebox("normal").bg_color = c
	self.get_stylebox("hover").bg_color = c#Color(c.r, c.g, c.b, 50.0/255.0)
	self.get_stylebox("pressed").bg_color = c#Color(c.r, c.g, c.b, 70.0/255.0)
	self.get_stylebox("focus").bg_color = c#c
	
func _on_pressed():
	var last_selected = buildManager.selected_building_or_null
	
	if buildManager.has_selected_building():
		buildManager.cancel()
	
	if last_selected != self:
		if ressourceManager.has_ressource("bamboo", costs_bamboo) and ressourceManager.has_ressource("stone", costs_stone):
			select()
			
func set_block_tile_id(val):
	block_tile_id = val
	if sprite != null:
		sprite.frame = val
	
func set_costs_bamboo(val):
	costs_bamboo = val
	if costsBamboo != null:
		costsBamboo.value = val
		costsBamboo.update()
	
func set_costs_stone(val):
	costs_stone = val
	if costsStone != null:
		costsStone.value = val
		costsStone.update()

func set_costs_leaves(val):
	costs_leaves = val
	if costsLeaves != null:
		costsLeaves.value = val
		costsLeaves.update()


func select():
	buildManager.select_building(self)
	is_selected = true
	update_color()
	
func unselect():
	is_selected = false
	update_color()