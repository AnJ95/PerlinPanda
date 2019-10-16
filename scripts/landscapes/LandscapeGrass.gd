extends "Landscape.gd"


var durability = 0
	
func init(map, cell_pos, cell_info, args, nth):
	if args.has("durability"):
		durability = args["durability"]
	else:
		durability = min(4, int(((cell_info.fertility+1.0)/2.0) * 5))
	return .init(map, cell_pos, cell_info, args, nth)
	
func get_tile_id():
	return durability

func panda_in_center(_panda):
	durability -= 1
	if durability <= 0:
		remove()
		map.set_landscape_by_descriptor(cell_pos, "dirt")
	else:
		update_tile()

func tick():	
	var percent = get_adjacent_spreadable_percent()
	if percent / 2.0 > randi()%100:
		print("... grass durability hit (" + str(percent) + "%)")
		durability = min(4, durability + 1)
		if !map.blocks.has(cell_pos) and durability >= 4 and (percent / 2.0 > randi()%100):
			map.set_block_by_descriptor(cell_pos, "vegetation")
			
	else:
		print("... grass durability miss (" + str(percent) + "%)")
		
	
	update_tile()

func got_welled():
	durability = min(4, durability + 1)
	if randi()%100 <= 30:
		map.set_block_by_descriptor(cell_pos, "vegetation")
	
	
func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.75