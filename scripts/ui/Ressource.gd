tool

extends HBoxContainer

export var value:int = 1
export var ressource_name:String

export var show_max_value:bool = false
export var max_ressource_name:String
export var max_value:int = 1
export var texture:Texture
export var do_update:bool = true

export var small:bool = false setget set_small


func _ready():
	update()
	
	$TextureRect.texture = texture
	
	if do_update and !Engine.editor_hint:
		var ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
		if ressourceManager.size() > 0:
			ressourceManager[0].connect("ressource_changed", self, "ressource_changed")
		
	
	$Label.add_font_override("font", $Label.get_font("font").duplicate())
	switch_small()
	
func ressource_changed(ressource_name, value):
	if ressource_name == self.ressource_name:
		self.value = value
		update()
	if ressource_name == self.max_ressource_name:
		self.max_value = value
		update()

func update():
	var text = str(value)
	if show_max_value:
		text += "/" + str(max_value)
	$Label.text = text
	
	
func switch_small():
	var factor = 2.0
	if small:
		factor = 1.0
	
	
	$TextureRect.rect_min_size.x = 27 * factor
	$TextureRect.rect_min_size.y = 35 * factor
	$TextureRect.rect_size.y = $TextureRect.rect_min_size.y
	
	$Label.rect_min_size.x = 10 * factor
	$Label.rect_size.x = 10 * factor
	
	$Label.rect_min_size.y = 35 * factor
	$Label.rect_size.y = $Label.rect_min_size.y 
	$Label.rect_position.y = 0
	
	$Label.get_font("font").set("size", int(16 * factor))
	
	self.rect_min_size.x = 49 * factor
	self.rect_min_size.y = 35 * factor
	self.rect_size.x = self.rect_min_size.x
	self.rect_size.y = self.rect_size.y
		
func set_small(new_small):
	if small != new_small:
		small = new_small
	if get_child_count() > 0:
		switch_small()
