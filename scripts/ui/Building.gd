tool
extends Button

export var building_animation_frame:int = 4
export var costs_bamboo = 6
export var costs_stone = 0
export var building_script_path:String

const col_yes:Color = Color(0.4,1,0.4, 40.0/255.0)
const col_no:Color = Color(0.6,0,0, 40.0/255.0)
const col_active:Color = Color(0,1,0, 40.0/255.0)

var ressourceManager
var buildManager


onready var sprite = $HBoxContainer/TextureRect/Sprite  
onready var costsBamboo = $HBoxContainer/VBoxContainer/CostsBamboo
onready var costsStone = $HBoxContainer/VBoxContainer/CostsStone

func _ready():
	sprite.frame = building_animation_frame
	costsBamboo.value = costs_bamboo
	costsStone.value = costs_stone
	
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
		ressourceManager.connect("ressource_changed", self, "ressource_changed")
		ressource_changed(null, null)
	else:
		ressourceManager = null
		
	$HBoxContainer/VBoxContainer/CostsBamboo.update()
	$HBoxContainer/VBoxContainer/CostsStone.update()
		
		
	buildManager = get_tree().get_nodes_in_group("build_manager")
	if buildManager.size() > 0:
		buildManager = buildManager[0]
	else:
		buildManager = null
	
onready var rand = randi()%100
func ressource_changed(_ressource_name, _value):
	#print(str(rand) + " unfocus")
	if !Engine.editor_hint:
		if ressourceManager.has_ressource("bamboo", costs_bamboo) and ressourceManager.has_ressource("stone", costs_stone):
			set_all_colors_to(col_yes)
			self.disabled = false
		else:
			set_all_colors_to(col_no)
			self.disabled = true

func set_all_colors_to(c):
	self.get_stylebox("normal").bg_color = c
	self.get_stylebox("hover").bg_color = Color(c.r, c.g, c.b, 50.0/255.0)
	self.get_stylebox("pressed").bg_color = Color(c.r, c.g, c.b, 70.0/255.0)
	self.get_stylebox("focus").bg_color = c
	
func _on_pressed():
	
	if buildManager.has_selected_building():
		buildManager.cancel()
	else:
		if ressourceManager.has_ressource("bamboo", costs_bamboo) and ressourceManager.has_ressource("stone", costs_stone):
			#print(str(rand) + " focus")
			set_all_colors_to(col_active)
			
			buildManager.select_building(self)