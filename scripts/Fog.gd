tool
extends TextureRect

var fog_pos_arr = []
func _ready():
	if Engine.editor_hint:
		for _i in range(30):
			fog_pos_arr.append(Vector2(randi()%1024, 600+randi()%600))
	update_fog_pos_array()
		

func add_fog_pos(pos):
	fog_pos_arr.append(pos)
	update_fog_pos_array()
	


const BYTE = 0xFF
const SIGN = (1 << 7)
const BYTE_NO_SIGN = BYTE - SIGN

func update_fog_pos_array():
	var txt = create_texture_from_pos_array(fog_pos_arr)

	# Upload the texture to my shader
	material.set_shader_param("fog_pos_arr", txt)
	
func create_texture_from_pos_array(pos_arr):
	# You'll have to get thoose the way you want
	var array_width = 2 * pos_arr.size()
	var array_height = 2

	# The following is used to convert the array into a Texture
	var byte_array = PoolByteArray()
	for pos in pos_arr:
		byte_array.append(int(pos.x) & BYTE)
		var signum = 0; if pos.x < 0: signum = SIGN
		byte_array.append(((int(abs(pos.x))>>8) & BYTE_NO_SIGN) + signum)
	for pos in pos_arr:
		byte_array.append(int(pos.y) & BYTE)
		var signum = 0; if pos.y < 0: signum = SIGN
		byte_array.append(((int(abs(pos.y))>>8) & BYTE_NO_SIGN) + signum)

	# I don't want any mipmaps generated : use_mipmaps = false
	# I'm only interested with 1 component per pixel (the corresponding array value) : Format = Image.FORMAT_R8
	var img = Image.new()
	img.create_from_data(array_width, array_height, false, Image.FORMAT_R8, byte_array)

	var texture = ImageTexture.new()

	# Override the default flag with 0 since I don't want texture repeat/filtering/mipmaps/etc
	texture.create_from_image(img, 0)
	
	return texture
	
func _process(delta):
	var pos_arr = []
	for panda in get_tree().get_nodes_in_group("panda"):
		pos_arr.append(panda.position)
		pos_arr.append(panda.home.light.position)
	
	var txt = create_texture_from_pos_array(pos_arr)
	material.set_shader_param("clear_pos_arr", txt)