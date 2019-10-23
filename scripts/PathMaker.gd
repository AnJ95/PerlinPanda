extends Node

export var map_node_path:String = "/root/Scene/Map"
onready var map = get_node(map_node_path)

onready var RessourceUpdater = preload("res://scenes/ui/RessourceUpdater.tscn")
var updaters = {}

onready var Inventory = preload("res://scenes/Inventory.tscn")
var inventory

var active:bool = false
var panda
var path = []

onready var tile_ids = {
	"home_start" : 			0,
	"home_end" : 			0 + 1*map.tile_cols,
	"path" : 				0 + 2*map.tile_cols,
	"path_multiple" : 		0 + 3*map.tile_cols,
	
	"walk" : 				1,
	"walk_multiple" :		1 + 1*map.tile_cols,
	"artefact" : 			1 + 2*map.tile_cols,
	
	"build_yes" : 			2,
	"build_no" : 			2 + 1*map.tile_cols,
	
	"ressource" : 			3,
	"build" : 				3 + 1*map.tile_cols}

var c:Color = Color(1,1,1,0)
func _unhandled_input(event: InputEvent):	
				
	# Hover effect: show panda path when mouse over house
	if event is InputEventMouseMotion:
		# first hide all lines
		for panda in get_tree().get_nodes_in_group("panda"):
			if panda.line != null:
				c.a = 0.0
				panda.line.default_color = c
				
		# then calc where mouse is
		var rect = get_viewport().get_visible_rect().size
		var cam = get_parent().get_node("Camera2D")
		
		var click_pos = (event.position - rect / 2) * cam.zoom + cam.offset
		var hovered_cell = map.calc_closest_tile_from(click_pos)
		for updater in updaters:
			if updater == hovered_cell:
				updaters[updater].visible = true
				continue
			var area = Rect2(updaters[updater].position, updaters[updater].get_node("Box").rect_size)
			if updaters[updater].visible == true and area.has_point(click_pos):
				updaters[updater].visible = true
				continue
			updaters[updater].visible = false
		
		# if panda in range: show its line
		var other = get_panda_in_range(click_pos)
		if other != null:
			
			if other.line != null:
				c.a = 0.8
				other.line.default_color = c
	
	# Scrolling first
	if get_parent().get_node("Camera2D").input(event):
		return
	
	# build manager first!
	var buildMgr = get_parent().get_node("BuildManager")
	if buildMgr.input(event):
		if active:
			cancel()
		return

	# cancel
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and !event.pressed:
		cancel()
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed:
		var rect = get_viewport().get_visible_rect().size
		var cam = get_parent().get_node("Camera2D")
		var click_pos = (event.position - rect / 2) * cam.zoom + cam.offset
		var clicked_tile = map.calc_closest_tile_from(click_pos)
		
		var clicked_panda = get_panda_in_range(click_pos)
		var just_ended_path = false
		
		
		if active and clicked_tile != null:
			if clicked_panda == null or panda == clicked_panda or is_valid_next(get_last_cell_pos(), clicked_tile):
				just_ended_path = add_to_current_path(clicked_tile)
			else:
				cancel()
				
		if !just_ended_path and clicked_panda != null and (!active or panda != clicked_panda) and (!active or is_valid_next(get_last_cell_pos(), clicked_tile)): #start new
			try_start_path_from(clicked_panda)
				
func get_panda_in_range(click_pos):
	for panda in get_tree().get_nodes_in_group("panda"):
		if !panda.show_start_anim and map.calc_px_pos_on_tile(panda.home_pos).distance_to(click_pos) < 40:
			return panda
	return null
	
func add_to_current_path(this_tile):
	if !active or !panda or path.size() == 0:
		printerr("IllegalStateException: add_to_current_path() before try_start_path() worked")

	var last_tile = get_last_cell_pos()
	
	if is_valid_next(last_tile, this_tile):
		var just_ended_path = false
		
		# add position
		path.append(this_tile)
		
		# add RessourceUpdater and change inventory
		if map.blocks.has(this_tile) and this_tile != panda.home_pos:
			var block = map.blocks[this_tile]
			var updater = create_ressource_updater(block)
			
			if block.get_class() == "BlockWIP":
				for res in updater.ressources_max:
					var missing = block.inventory.get_max(res) - block.inventory.get(res)
					var more_available = path[2].ressources_max[res] - path[2].ressources[res]
					var taking = max(min(missing, more_available), 0)
					print(taking)
					# take more from start
					path[2].ressources[res] += taking
					path[2].update()
					
					# update this blocks RessourceChanger
					updater.ressources[res] += taking
					updater.ressources_max[res] += taking
					updater.update()

			if updater != null:
				path.append(true)
				path.append(updater)
				
		if this_tile == path[0]:
			done_with_path()
			just_ended_path = true
			
		update_preview()
		
		return just_ended_path
		
func create_ressource_updater(block):
	var updater = null
	if block.ressource_name_or_null() != null:							updater = create_ressource_updater_from_ressource(block)
	if block.get_class() == "BlockWIP":									updater = create_ressource_updater_from_block_wip(block)
	if block.get_class() == "BlockHouse" and block.cell_pos != path[0]:	updater = create_ressource_updater_from_foreign_house(block)
	if block.get_class() == "BlockHouse" and block.cell_pos == path[0]:	updater = create_ressource_updater_from_own_house(block)
	if block.get_class() == "BlockSmoker":								updater = create_ressource_updater_from_smoker(block)
	
	if updater != null:
		updater.set_subscriber(self)
	return updater
		
		
func create_ressource_updater_from_ressource(block):
	return RessourceUpdater.instance().set_from_ressource_block(inventory, block)
	

func create_ressource_updater_from_block_wip(block):
	return RessourceUpdater.instance().set_from_wip_block(inventory, block)
	
func create_ressource_updater_from_foreign_house(block):
	return RessourceUpdater.instance().set_from_foreign_house(inventory, block)
func create_ressource_updater_from_own_house(block):
	return RessourceUpdater.instance().set_max_from_inventory(block.scheduled_inventory)
func create_ressource_updater_from_smoker(block):
	return RessourceUpdater.instance().set_from_smoker(inventory, block)
				
func is_valid_next(last_tile, this_tile):
	return (!map.blocks.has(this_tile) or map.blocks[this_tile].is_passable()) and map.map_landscape.get_cellv(this_tile) >= 0 and map.are_tiles_adjacent(last_tile, this_tile) and (cell_pos_not_already_in_path(this_tile) or (map.blocks.has(this_tile) and map.blocks[this_tile].multiple_in_one_path_allowed()))

func update_preview():
	map.map_overlay.clear()
	
	# show regular stuff if not active
	if !active:
		$Line2D.hide()
		map.show_homes()
		return
		
	update_overlay()
	update_line()
	update_inventory()
	p("Expected panda inventory is " + str(inventory.inventory))

func update_overlay():
	var cur_tile = get_last_cell_pos()
	# visualize walking possibilities
	for that_tile in map.get_adjacent_tiles(cur_tile):
		# if valid adjacent tile
		if is_valid_next(cur_tile, that_tile):
			
			var tile_id = tile_ids.walk
			
			# if home pos = goal pos
			if that_tile == panda.home_pos:
				tile_id = tile_ids.home_end
			# check for ressources and others
			if map.blocks.has(that_tile):
				var block = map.blocks[that_tile]
				if block.multiple_in_one_path_allowed():
					tile_id = tile_ids.walk_multiple
				if block.ressource_name_or_null() != null:
					tile_id = tile_ids["ressource"]
				if block.get_class() == "BlockWIP":
					tile_id = tile_ids.build
				if block.get_class() == "BlockArtefact":
					tile_id = tile_ids.artefact

			# set calculated tile id
			var tile_id_offset = map.cell_infos[that_tile].height * map.layer_offset
			map.map_overlay.set_cellv(that_tile, tile_id + tile_id_offset)
	
	# visualize path until now
	for path_elem in path:
		if path_elem is Vector2:
			var tile_id_offset = map.cell_infos[path_elem].height * map.layer_offset
			# dont override the "goal" or "walk" overlay
			var now = map.map_overlay.get_cellv(path_elem)
			if now != tile_ids.home_end + tile_id_offset and now != tile_ids.walk + tile_id_offset and now != tile_ids.walk_multiple + tile_id_offset:
				# show either black or black with hole
				var tile_id = tile_ids.path
				if map.blocks.has(path_elem) and map.blocks[path_elem].multiple_in_one_path_allowed():
					tile_id = tile_ids.path_multiple
				map.map_overlay.set_cellv(path_elem, tile_id + tile_id_offset)
			
func update_line():
	var pts = []
	for cell in path:
		if cell is Vector2:
			pts.append(map.map_overlay.map_to_world(cell) + Vector2(0, map.cell_infos[cell].height * map.layer_px_dst))
	$Line2D.points = PoolVector2Array(pts)
	$Line2D.show()
	
func update_inventory():
	# reset inventory
	if inventory != null:
		inventory.queue_free()
	inventory = Inventory.instance().init(null, true, {"bamboo":0,"stone":0,"leaves":0}, panda.max_inventory())
	
	var last_cell_pos = null
	var last_perform_action = true
	for path_elem in path:
		if path_elem is Vector2:
			last_cell_pos = path_elem
		if path_elem is bool:
			last_perform_action = path_elem
		elif panda.is_ressource_updater(path_elem):
			if path_elem.get_parent() == null:
				path_elem.position = map.calc_px_pos_on_tile(last_cell_pos) - Vector2(path_elem.get_node("Box").rect_size.x / 2.0, -40)
				map.get_parent().get_node("MapControls").add_child(path_elem)
							
			updaters[last_cell_pos] = path_elem
			path_elem.add_to_inventory(inventory)
			p("adding " + str(inventory.inventory) + "... ")

func cell_pos_not_already_in_path(cell_pos):
	return !path.has(cell_pos) or cell_pos == path[0]

func done_with_path():
	if !active or !panda or path.size() < 3:
		printerr("IllegalStateException: done_with_path() before try_start_path() worked")
	active = false
	
	for updater in updaters:
		if updaters[updater].get_parent() != null:
			updaters[updater].get_parent().remove_child(updaters[updater])
	updaters = {}
		
	panda.add_path(path, inventory.clone())
	
	# new house inventory = old house inventory + panda inventory - initially taken
	var house = map.blocks[panda.home_pos]
	inventory.move_to_other(house.scheduled_inventory)
	for res in path[2].ressources:
		house.scheduled_inventory.add(res, -path[2].ressources[res])
	
	if panda.line == null:
		panda.line = $Line2D.duplicate()
		get_parent().get_node("Map/Navigation2D/PathHolder").add_child(panda.line)
		panda.line.points = PoolVector2Array()
	
	panda.line.modulate = Color(panda.line.modulate.r, panda.line.modulate.g, panda.line.modulate.b, 0.6)
	var pts = Array(panda.line.points)
	# only at start of path, to prevent popFront too early
	if pts.size() == 0:
		pts.push_front(map.map_overlay.map_to_world(path[0]) + Vector2(0, map.cell_infos[path[0]].height * map.layer_px_dst))
	for cell in path:
		if cell is Vector2:
			pts.append(map.map_overlay.map_to_world(cell) + Vector2(0, map.cell_infos[cell].height * map.layer_px_dst))
	
	panda.line.points = PoolVector2Array(pts)
	
	
func try_start_path_from(panda):
		active = true
		self.panda = panda
		var ressourceUpdater = create_ressource_updater_from_own_house(map.blocks[panda.home_pos])
		
		path = [panda.home_pos, true, ressourceUpdater]
		panda.stop_particles()
		update_preview()
		return
			
func cancel():
	if active:
		for updater in updaters:
			updaters[updater].queue_free()
		updaters = {}
		
		active = false
		update_preview()


func get_last_cell_pos():
	var last_tile_id = path.size()-1
	while !path[last_tile_id] is Vector2:
		last_tile_id -= 1
	return path[last_tile_id]
	
func notify_inventory_increase(_ressource, _add):
	pass
	
func ressourceUpdaterChanged():
	update_preview()
			
func y(c, a, b):
	if c:
		return a
	else:
		return b
		
func p(obj):
	if map.print_path_maker:
		print("## PathMaker ## " + str(obj))