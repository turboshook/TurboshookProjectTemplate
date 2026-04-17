shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 inverted_color = vec4(
		1.0 - screen_color.r,
		1.0 - screen_color.g,
		1.0 - screen_color.b,
		1.0
	);
	COLOR = inverted_color;
}
