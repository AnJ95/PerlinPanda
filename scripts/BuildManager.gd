extends Node

var selected_building_or_null = null

onready var Panda = preload("res://scenes/Panda.tscn")

var ressourceManager
func _ready():
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
	else:
		ressourceManager = null
	
		
func has_selected_building():
	return selected_building_or_null != null

func select_building(building):
	selected_building_or_null = building
	
func cancel():
	selected_building_or_null = null
	
	
func input(event):
	if !event is InputEventMouseButton:
		return false
		
	if has_selected_building():
		if event.button_index == BUTTON_RIGHT:
			cancel()
			return true
			
		if event.button_index == BUTTON_LEFT and event.pressed:
			var rect = get_viewport().get_visible_rect().size
			var cam = get_parent().get_node("Camera2D")
			var click_pos = (event.position - rect / 2) * cam.zoom + cam.offset
			var map = get_parent().get_node("Map")
			var cell_pos = map.map_overlay.world_to_map(click_pos + map.map_overlay.cell_size / 2.0)
			
			if map.landscapes.has(cell_pos) and map.landscapes[cell_pos].can_build_on(map, cell_pos) and !map.blocks.has(cell_pos):
				buy(map, cell_pos)
			return true
	
	return false
	
func buy(map, cell_pos):
	
	ressourceManager.add_ressource("bamboo", -selected_building_or_null.costs_bamboo)
	ressourceManager.add_ressource("stone", -selected_building_or_null.costs_stone)
	
	var clazz = load(selected_building_or_null.building_script_path)
	
	var cell_pos3 = Vector3(cell_pos.x, cell_pos.y, map.height_layer[cell_pos])
	map.blocks[cell_pos] = clazz.new().initOverload(map, cell_pos3, Panda)
	
	cancel()