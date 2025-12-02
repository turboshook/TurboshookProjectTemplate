shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform int quantize_steps = 16;

vec4 quantize(vec4 color, int steps) {
    return floor(color * float(steps)) / float(steps);
}

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	vec4 quantized_color = quantize(screen_color, quantize_steps);
	COLOR = quantized_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
