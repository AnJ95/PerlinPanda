extends "Block.gd"


func get_class(): return "BlockWIP"

func init(map, cell_pos, cell_info, args, nth):
	return .init(map, cell_pos, cell_info, args, nth)

func get_build_time():
	var proto = map.lex.get_proto_block_by_tile_id(args.of)
	return proto.get_build_time()
	
func inst_actual_block():
	map.set_block_by_tile_id(cell_pos, args.of)
	
func get_tile_id():
	print(args.of)
	return args.of + 6 # todo
	
func get_speed_factor():
	return 1.2
	
func ressource_name_or_null():
	return null
	
func panda_in_center(panda):
	panda.start_building(self)
	
################################################
### FIRE
func get_prob_fire_catch():
	return 50
func get_fire_increase_time():
	return 8