extends Node

var selected_building_or_null = null

var map

onready var BlockWIP = preload("res://scripts/blocks/BlockWIP.gd")
onready var Panda = preload("res://scenes/Panda.tscn")

var ressourceManager
func _ready():
	ressourceManager = get_tree().get_nodes_in_group("ressource_manager")
	if ressourceManager.size() > 0:
		ressourceManager = ressourceManager[0]
	else:
		ressourceManager = null
	map = get_parent().get_node("Map")
	
		
func has_selected_building():
	return selected_building_or_null != null

func select_building(building):
	selected_building_or_null = building
	show_possible_build_sites()
	
func cancel():
	selected_building_or_null = null
	hide_possible_build_sites()
	
	
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
			
			var cell_pos = map.map_overlay.world_to_map(click_pos + map.map_overlay.cell_size / 2.0)
			
			var clazz = load(selected_building_or_null.building_script_path)
			var proto = clazz.new()
			if map.landscapes.has(cell_pos) and map.landscapes[cell_pos].can_build_on(map, cell_pos) and proto.can_be_build_on(map, cell_pos):
				buy(map, cell_pos)
			return true
	
	return false


func show_possible_build_sites():
	var clazz = load(selected_building_or_null.building_script_path)
	var proto = clazz.new()
	for pos in map.landscapes:
		if map.landscapes[pos].can_build_on(map, pos) and proto.can_be_build_on(map, pos):
			map.map_overlay.set_cellv(pos, 13 + map.landscapes[pos].cell_pos3.z * map.tile_height_id_dst);
			
func hide_possible_build_sites():
	for pos in map.map_overlay.get_used_cells():
		map.map_overlay.set_cellv(pos, -1);
		
	map.show_homes()

func buy(map, cell_pos):
	
	ressourceManager.add_ressource("bamboo", -selected_building_or_null.costs_bamboo)
	ressourceManager.add_ressource("stone", -selected_building_or_null.costs_stone)
	
	var clazz = load(selected_building_or_null.building_script_path)
	
	var cell_pos3 = Vector3(cell_pos.x, cell_pos.y, map.height_layer[cell_pos])
	map.blocks[cell_pos] = BlockWIP.new().initOverload(map, cell_pos3, Panda, clazz)
	
	
	cancel()