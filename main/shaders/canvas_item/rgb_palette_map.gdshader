// Modified version of this:
// https://godotshaders.com/shader/game-boy-palette-overlay/
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness : hint_range(-1, 1) = 0; // Usable if and only if the palette is ordered by brightness
uniform sampler2D palette;

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	ivec2 pal_size = textureSize(palette, 0);

	float color_diff = 1.0;
	ivec2 nearest_swatch;

	for (int swatch_x=0; swatch_x < pal_size.x; swatch_x++) {
		for (int swatch_y=0; swatch_y < pal_size.y; swatch_y++) {
			ivec2 swatch = ivec2(swatch_x, swatch_y);
			vec4 sampled_color = texelFetch(palette, swatch, 0);
			float new_color_diff = distance(sampled_color, screen_color);
			if (new_color_diff < color_diff) {
				color_diff = new_color_diff;
				nearest_swatch = swatch;
			}
		}
	}

	// only used with brightness feature and only for 1D palette textures
	// could update this for later tho
	//int swatch_offset = int(brightness * float(pal_size.x));
	//int target_swatch = clamp(nearest_swatch, 0, pal_size.x -1);

	COLOR = texelFetch(palette, nearest_swatch, 0);
}