extends Node

var selected_building_or_null = null

var map

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
	if selected_building_or_null != null:
		selected_building_or_null.unselect()
	selected_building_or_null = building
	show_possible_build_sites()
	
func cancel():
	if selected_building_or_null != null:
		selected_building_or_null.unselect()
	selected_building_or_null = null
	hide_possible_build_sites()
	
	
func input(event):
	if !event is InputEventMouseButton:
		return false
		
	if has_selected_building():
		if event.button_index == BUTTON_RIGHT:
			cancel()
			return true
			
		if event.button_index == BUTTON_LEFT and !event.pressed:
			var rect = get_viewport().get_visible_rect().size
			var cam = get_parent().get_node("Camera2D")

			var click_pos = (event.position - rect / 2) * cam.zoom + cam.offset
			var clicked_tile = map.calc_closest_tile_from(click_pos)
			
			if map.landscapes.has(clicked_tile):
				var dst = click_pos.distance_to(map.calc_px_pos_on_tile(clicked_tile))
				if dst <= 70:
					var proto = map.lex.get_proto_block_by_tile_id(selected_building_or_null.block_tile_id)
					if map.landscapes[clicked_tile].can_build_on(map, clicked_tile) and proto.can_be_build_on(map, clicked_tile):
						buy(map, clicked_tile)
						cancel()
					else:
						cancel()
				else:
					cancel()
			else:
				cancel()
			return true
	
	return false


func show_possible_build_sites():
	var proto = map.lex.get_proto_block_by_tile_id(selected_building_or_null.block_tile_id)
	
	hide_possible_build_sites()
		
	for pos in map.landscapes:
		if map.landscapes[pos].can_build_on(map, pos) and proto.can_be_build_on(map, pos):
			map.map_overlay.set_cellv(pos, 1 + map.cell_infos[pos].height * map.layer_offset);
			
func hide_possible_build_sites():
	for pos in map.map_overlay.get_used_cells():
		map.map_overlay.set_cellv(pos, -1);
		
	map.show_homes()

func buy(map, cell_pos):
	var selected_building = selected_building_or_null
	if selected_building != null:
		ressourceManager.add_ressource("bamboo", -selected_building.costs_bamboo)
		ressourceManager.add_ressource("stone", -selected_building.costs_stone)
		ressourceManager.add_ressource("leaves", -selected_building.costs_leaves)
	
		# WIP is always under image
		map.set_block_by_tile_id(cell_pos, selected_building.block_tile_id + map.tile_cols)
		
	
	