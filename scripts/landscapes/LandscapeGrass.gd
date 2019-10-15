extends "Landscape.gd"


var durability = 0

func clone(): # enables pseudo-cloning, initOverload must reset everything though
	return self
	
func init(map, cell_pos, cell_info, args, nth):
	if args.has("durability"):
		durability = args[durability]
	else:
		durability = min(4, int(((cell_info.fertility+1.0)/2.0) * 5))
	.init(map, cell_pos, cell_info, args, nth)
	
	return self
	
func get_tile_id():
	return durability

func panda_in_center(_panda):
	durability -= 1
	if durability <= 0:
		remove()
		map.set_landscape_by_descriptor(cell_pos, "grass")
	else:
		update_tile()

func tick():
	var percent = get_adjacent_spreadable_percent()
	if percent / 4.0 > randi()%100:
		print("... grass durability hit (" + str(percent) + "%)")
	else:
		print("... grass durability miss (" + str(percent) + "%)")
		
	durability = min(4, durability + 1)
	update_tile()


func can_spread_grass():
	return true
	
func get_speed_factor():
	return 0.75