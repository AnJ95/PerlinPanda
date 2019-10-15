extends "Block.gd"



func init(map, cell_pos, cell_info, args, nth):
	is_wip = true
	return .init(map, cell_pos, cell_info, args, nth)

func get_build_time():
	var proto = map.lex.get_proto_block_by_tile_id(args.of)
	return proto.get_build_time()
	
func inst_actual_block():
	map.set_block_by_tile_id(cell_pos, args.of)
	
func get_tile_id():
	return args.of + 6 # todo
	
func get_speed_factor():
	return 1.2
	
func ressource_name_or_null():
	return null
	
func panda_in_center(panda):
	panda.start_building(self)