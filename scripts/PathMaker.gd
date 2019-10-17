extends Node

export var map_node_path:String = "/root/Scene/Map"
onready var map = get_node(map_node_path)

var active:bool = false
var panda
var path = []

onready var tile_ids = {
	"home_start" : 			0,
	"home_end" : 			0 + 1*map.tile_cols,
	"path" : 				0 + 2*map.tile_cols,
	"walk" : 				1,
	"bamboo" : 				2,
	"stone" : 				3,
	"leaves" : 				2,
	"build" : 				4
	}

var c:Color = Color(1,1,1,0)
func _input(event: InputEvent):	
				
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
		
		# if panda in range: show its line
		var other = get_panda_in_range((event.position - rect / 2) * cam.zoom + cam.offset)
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
			print("CANCEL")
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
		if active and clicked_tile != null:
			if clicked_panda == null or panda == clicked_panda:
				add_to_current_path(clicked_tile)
			else:
				cancel()
				
		if clicked_panda != null and (!active or panda != clicked_panda): #start new
			try_start_path_from(clicked_panda)
				
func get_panda_in_range(click_pos):
	for panda in get_tree().get_nodes_in_group("panda"):
		if !panda.show_start_anim and map.calc_px_pos_on_tile(panda.home_pos).distance_to(click_pos) < 40:
			return panda
	return null
	
func add_to_current_path(this_tile):
	if !active or !panda or path.size() == 0:
		printerr("IllegalStateException: add_to_current_path() before try_start_path() worked")
		
	var last_tile = path[path.size()-1]
	
	if is_valid_next(last_tile, this_tile):
		path.append(this_tile)
		
		if this_tile == path[0]:
			done_with_path()
		
		update_preview()

func is_valid_next(last_tile, this_tile):
	return (!map.blocks.has(this_tile) or map.blocks[this_tile].is_passable()) and map.map_landscape.get_cellv(this_tile) >= 0 and map.are_tiles_adjacent(last_tile, this_tile) and cell_pos_not_already_in_path(this_tile) 

func update_preview():
	map.map_overlay.clear()
	if !active:
		$Line2D.hide()
		map.show_homes()
		return
	var cur_tile = path[path.size()-1]
	
	for that_tile in map.get_adjacent_tiles(cur_tile):
		# if valid adjacent tile
		if is_valid_next(cur_tile, that_tile):
			
			var tile_id = tile_ids.walk
			
			# if home pos = goal pos
			if that_tile == panda.home_pos:
				tile_id = tile_ids.home_end
			# check for ressources
			if map.blocks.has(that_tile):
				if map.blocks[that_tile].ressource_name_or_null() != null:
					tile_id = tile_ids[map.blocks[that_tile].ressource_name_or_null()]
				if map.blocks[that_tile].is_wip:
					tile_id = tile_ids.build

			# set calculated tile id
			var tile_id_offset = map.cell_infos[that_tile].height * map.layer_offset
			map.map_overlay.set_cellv(that_tile, tile_id + tile_id_offset)
				
	for cur_tile in path:
		var tile_id_offset = map.cell_infos[cur_tile].height * map.layer_offset
		map.map_overlay.set_cellv(cur_tile, tile_ids.path + tile_id_offset)
	
	var pts = []
	for cell in path:
		pts.append(map.map_overlay.map_to_world(cell) + Vector2(0, map.cell_infos[cell].height * map.layer_px_dst))
	$Line2D.points = PoolVector2Array(pts)
	$Line2D.show()
	

func cell_pos_not_already_in_path(cell_pos):
	return !path.has(cell_pos) or cell_pos == path[0]

func done_with_path():
	if !active or !panda or path.size() < 3:
		printerr("IllegalStateException: done_with_path() before try_start_path() worked")
	active = false
	panda.set_path(path)
	
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
		pts.append(map.map_overlay.map_to_world(cell) + Vector2(0, map.cell_infos[cell].height * map.layer_px_dst))
	
	panda.line.points = PoolVector2Array(pts)
	
	
func try_start_path_from(panda):
		active = true
		self.panda = panda
		path = [panda.home_pos]
		panda.stop_particles()
		update_preview()
		return
			
func cancel():
	if active:
		active = false
		update_preview()
			
func y(c, a, b):
	if c:
		return a
	else:
		return b