shader_type canvas_item;

uniform bool play_shader = false;
uniform bool show_bg = false;

void fragment() {
	vec4 col_before = texture(TEXTURE, UV);
	vec4 col_after = col_before;
	
	if (play_shader) {
		if (col_before.a > 0.0) {
			if (show_bg) {
				col_after = mix(col_before, vec4(1,1,1, col_before.a), 0.2*(sin(7.0*UV.x + 9.0*UV.y + 9.0*TIME)+1.0)/2.0);
			} else {
				col_after.a = min((sin(6.0*UV.x + 8.0*UV.y + 6.0*TIME)+1.0)/2.0, col_before.a);
			}
		}
	}
	
	COLOR = col_after;
}