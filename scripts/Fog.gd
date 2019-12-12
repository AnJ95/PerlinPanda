tool
extends TextureRect

const BYTE = 0xFF
const SIGN = (1 << 7)
const BYTE_NO_SIGN = BYTE - SIGN
	
	
# NOT USED
# Creates a sampler2D for shaders from an array of vec2s
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
