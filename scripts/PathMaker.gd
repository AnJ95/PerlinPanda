extends Node

export var map_node_path:String = "/root/Scene/Map"
onready var map = get_node(map_node_path)

var active:bool = false
var panda
var path = []

onready var tile_ids = {
	"home_start" : 			0,
	"home_end" : 			0 + map.tile_cols,
	
	"walk_up_2" : 			1,
	"walk_up_1" : 			1 + 1*map.tile_cols,
	"walk" : 				1 + 2*map.tile_cols,
	"walk_down_1" : 		1 + 3*map.tile_cols,
	"walk_down_2" : 		1 + 4*map.tile_cols,
	
	"bamboo_up_2" : 		2,
	"bamboo_up_1" : 		2 + 1*map.tile_cols,
	"bamboo" : 				2 + 2*map.tile_cols,
	"bamboo_down_1" : 		2 + 3*map.tile_cols,
	"bamboo_down_2" : 		2 + 4*map.tile_cols,
	
	"stone_up_2" : 			3,
	"stone_up_1" : 			3 + 1*map.tile_cols,
	"stone" : 				3 + 2*map.tile_cols,
	"stone_down_1" : 		3 + 3*map.tile_cols,
	"stone_down_2" : 		3 + 4*map.tile_cols
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
				
	# build manager first!
	var buildMgr = get_parent().get_node("BuildManager")
	if buildMgr.input(event):
		return
	
	
	
	# cancel
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		if active:
			active = false
			update_preview()
			map.show_homes()	
	
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		var rect = get_viewport().get_visible_rect().size
		var cam = get_parent().get_node("Camera2D")
		var click_pos = (event.position - rect / 2) * cam.zoom + cam.offset
		
		
		if active:
			add_to_current_path(click_pos)
		else:
			try_start_path(click_pos)
				
func get_panda_in_range(click_pos):
	for panda in get_tree().get_nodes_in_group("panda"):
		if map.map_landscape.map_to_world(panda.home_pos).distance_to(click_pos) < 40:
			return panda
	
func add_to_current_path(click_pos):
	if !active or !panda or path.size() == 0:
		printerr("IllegalStateException: add_to_current_path() before try_start_path() worked")
		
	var last_tile = path[path.size()-1]
	var this_tile = map.map_overlay.world_to_map(click_pos + map.map_landscape.cell_size / 2.0)
	
	if map.map_landscape.get_cellv(this_tile) >= 0 and are_tiles_adjacent(last_tile, this_tile) and cell_pos_not_already_in_path(this_tile):
		path.append(this_tile)
		
		if this_tile == path[0]:
			done_with_path()
		
		update_preview()
		

func update_preview():
	map.map_overlay.clear()
	if !active:
		$Line2D.hide()
		map.show_homes()
		return
		
	var cur_tile = path[path.size()-1]
	
	
	for y in range(cur_tile.y - 1, cur_tile.y + 2):
		for x in range(cur_tile.x - 1, cur_tile.x + 2):
			var that_tile = Vector2(x, y)
			# if valid adjacent tile
			if map.map_landscape.get_cellv(that_tile) >= 0 and are_tiles_adjacent(cur_tile, that_tile) and cell_pos_not_already_in_path(that_tile):
				
				
				var dhdx = map.cell_infos[cur_tile].height - map.cell_infos[that_tile].height
				
				var height_suffix = y(dhdx == 0, "",
					y(dhdx > 0, "_up_" + str(min(2, dhdx)), "_down_" + str(min(2, -dhdx)))
				)
				var tile_id = tile_ids["walk" + height_suffix]
				
				# if home pos = goal pos
				if that_tile == panda.home_pos:
					tile_id = tile_ids.home_end
				# check for ressources
				if map.blocks.has(that_tile) and map.blocks[that_tile].ressource_name_or_null() != null:
					tile_id = tile_ids[map.blocks[that_tile].ressource_name_or_null() + height_suffix]
	
				# set calculated tile id
				var tile_id_offset = map.cell_infos[that_tile].height * map.tile_height_id_dst
				map.map_overlay.set_cellv(that_tile, tile_id + tile_id_offset)
				
	var tile_id_offset = map.cell_infos[cur_tile].height * map.tile_height_id_dst
	map.map_overlay.set_cellv(cur_tile, -1);
	
	var pts = []
	for cell in path:
		pts.append(map.map_overlay.map_to_world(cell) + Vector2(0, map.cell_infos[cell].height * map.layer_px_dst))
	$Line2D.points = PoolVector2Array(pts)
	$Line2D.show()
	

func cell_pos_not_already_in_path(cell_pos):
	return !path.has(cell_pos) or cell_pos == path[0]

func are_tiles_adjacent(a:Vector2, b:Vector2):
	
	var c1 = a.x == b.x and abs(a.y - b.y) == 1
	var c2 = abs(a.x - b.x) == 1 and a.y == b.y
	var c3 = int(round(abs(a.x))) % 2 == 0 and abs(a.x - b.x) == 1 and a.y-1 == b.y
	var c4 = int(round(abs(a.x))) % 2 == 1 and abs(a.x - b.x) == 1 and a.y+1 == b.y
	return c1 or c2 or c3 or c4

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
	
	
func try_start_path(click_pos):
		var panda = get_panda_in_range(click_pos)
		if panda != null:
			active = true
			self.panda = panda
			path = [panda.home_pos]
			panda.stop_particles()
			update_preview()
			return
			
func y(c, a, b):
	if c:
		return a
	else:
		return b