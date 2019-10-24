tool
extends ColorRect

export var block_tile_id:int setget set_block_tile_id
export var costs_bamboo:int setget set_costs_bamboo
export var costs_stone:int setget set_costs_stone
export var costs_leaves:int setget set_costs_leaves

export var col_inactive:Color = Color(0.0,0.0,0.0, 0.07)
export var col_active:Color = Color(0.4,0.7,0.3, 1.0)

var buildManager

onready var sprite = $HBoxContainer/TextureRect/Sprite
onready var costsBamboo = $HBoxContainer/VBoxContainer/CostsBamboo
onready var costsStone = $HBoxContainer/VBoxContainer/CostsStone
onready var costsLeaves = $HBoxContainer/VBoxContainer/CostsLeaves

# Set ny Buyables
var locked_id

var is_selected = false

# required by ArtefactScreen
var is_active = true
var is_unlockable = false
var unlockable_parent = null

func _ready():
	sprite.frame = block_tile_id
	costsBamboo.value = costs_bamboo
	costsBamboo.update()
	costsStone.value = costs_stone
	costsStone.update()
	costsLeaves.value = costs_leaves
	costsLeaves.update()
	
	update_color()
	
		
	buildManager = get_tree().get_nodes_in_group("build_manager")
	if buildManager.size() > 0:
		buildManager = buildManager[0]
	else:
		buildManager = null

func update_color():
	if is_selected:
		set_all_colors_to(col_active)
	else:
		set_all_colors_to(col_inactive)
		

func set_all_colors_to(c):
	self.color = c
	
	
func on_gui_input(event):
	if is_active:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
			var was_selected = is_selected
			
			if is_unlockable:
				unlockable_parent.on_click_buyable(self)
			else:
				if buildManager.has_selected_building():
					buildManager.cancel()
				
				if !was_selected:
					select()
	get_tree().set_input_as_handled()
	return true
	

			
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

func highlight():
	$AnimationPlayer.play("highlight")

func select():
	buildManager.select_building(self)
	is_selected = true
	update_color()
	
func unselect():
	is_selected = false
	update_color()