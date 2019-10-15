extends Node

var block_sheet = [
	"bamboo_var_0_stock_3", "bamboo_var_1_stock_3", "stone_var_0_stock_3", "stone_var_1_stock_3", "home", "farm_stock_4",
	"bamboo_var_0_stock_2", "bamboo_var_1_stock_2", "stone_var_0_stock_2", "stone_var_1_stock_2", "wip", "farm_stock_2",
	"bamboo_var_0_stock_1", "bamboo_var_1_stock_1", "stone_var_0_stock_1", "stone_var_1_stock_1", "street", "farm_stock_2",
	"bamboo_var_0_stock_0", "bamboo_var_1_stock_0", "stone_var_0_stock_0", "stone_var_1_stock_0", "wip", "farm_stock_1",
	"mountain_var_0", "mountain_var_1", "mountain_var_2", "mountain_var_4", "", "farm_stock_0",
	"", "", "", "", "", "wip",
]

var landscape_sheet = [
	"grass_durability_1", "grass_durability_2", "grass_durability_3", "grass_durability_4", "grass_durability_5", "",
	"dirt_var_0", "dirt_var_1", "dirt_var_2", "dirt_var_3", "dirt_var_4", "",
	"sand_var_0", "sand_var_1", "sand_var_2", "sand_var_3", "sand_var_4", "",
	"water_var_0", "water_var_1", "water_var_2", "water_var_3", "water_var_4", "",
	"", "", "", "", "", ""
]


var block_scripts = {
	"bamboo": load("res://scripts/blocks/BlockBamboo.gd"),
	"stone": load("res://scripts/blocks/BlockStone.gd"),
	"house": load("res://scripts/blocks/BlockHouse.gd"),
	"mountain": load("res://scripts/blocks/BlockMountain.gd"),
	"farm": load("res://scripts/blocks/BlockFarm.gd"),
	"wip": load("res://scripts/blocks/BlockWIP.gd"),
	#"": "res://scripts/blocks/Block.gd",
	#"": "res://scripts/blocks/Block.gd",
	#"": "res://scripts/blocks/Block.gd",
	#"": "res://scripts/blocks/Block.gd"
}

var landscape_scripts = {
	"grass": load("res://scripts/landscapes/LandscapeGrass.gd"),
	"dirt": load("res://scripts/landscapes/LandscapeDirt.gd"),
	"sand": load("res://scripts/landscapes/LandscapeSand.gd"),
	"water": load("res://scripts/landscapes/LandscapeWater.gd")
	#"": "res://scripts/landscapes/Landscape.gd"
}

func err(msg):
	printerr("LEX:   " + str(msg))

## SEARCH BY NAME ONLY - NO ARGUMENTS!
func get_info_on_block_name(block_name):
	return _get_info_on_name(block_scripts, block_sheet, block_name)
func get_info_on_landscape_name(landscape_name):
	return _get_info_on_name(landscape_scripts, landscape_sheet, landscape_name)
	
func _get_info_on_name(scripts, sheet, name):
	var info = {}
	if !scripts.has(name):
		err("LEX: invalid name '" + name + "', not found in scripts")
		return null
		
	info.name = name
	info.class = scripts[name]
	return info
########################################



## SEARCH BY DESCRIPTOR - POSSIBLY WITH ARGUMENTS
func get_info_on_block_descriptor(descriptor):
	return _get_info_on_descriptor(block_scripts, block_sheet, descriptor)
func get_info_on_landscape_descriptor(descriptor):
	return _get_info_on_descriptor(landscape_scripts, landscape_sheet, descriptor)
	
func _get_info_on_descriptor(scripts, sheet, descriptor):
	# get all infos on descriptor
	var descriptor_info = parse_descriptor(descriptor)
	if descriptor_info == null:
		return null
	
	# Construct return object
	var info = _get_info_on_name(scripts, sheet, descriptor_info[0])
	if info == null:
		return null
	
	info.args = descriptor_info[1]
	
	return info
########################################


## SEARCH BY TILE_ID IN SHEET - WITH ARGUMENTS HERE IN LEX!
func get_info_on_block_tile_id(tile_id):
	return _get_info_on_tile_id(block_scripts, block_sheet, tile_id)
func get_info_on_landscape_tile_id(tile_id):
	return _get_info_on_tile_id(landscape_scripts, landscape_sheet, tile_id)
	
func _get_info_on_tile_id(scripts, sheet, tile_id):
	# first get descriptor by tile id from sheet
	#var sheet_x = int(tile_id) % sheet[0].size()
	#var sheet_y = int(tile_id) / sheet[0].size()
	if tile_id < 0 or sheet.size() > tile_id:
		err("invalid tile_id '" + tile_id + "', is not in tilesheet")
		return null
	var descriptor = sheet[tile_id]
	
	# Then use function that does rest :P
	return _get_info_on_descriptor(scripts, sheet, descriptor)
	
########################################
	

func parse_descriptor(desc:String):
	var args = desc.split("_")
	
	if args.size() == 0:
		err("invalid descriptor '" + desc + "', has no arguments")
		return null
	if args.size() % 2 != 1:
		err("invalid descriptor '" + desc + "', number of arguments must be odd")
		return null
		
	var name = args[0]
	var settings = {}
	
	for i in range(1,  args.size(), 2):
		settings[args[i]] = int(args[i+1])
	
	return [name, settings]