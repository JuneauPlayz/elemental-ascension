shader_type canvas_item;

const int MAX_RECTS = 10;

uniform int rect_count = 0;
uniform vec2 rect_positions[MAX_RECTS];
uniform vec2 rect_sizes[MAX_RECTS];
uniform float softness : hint_range(0.0, 100.0) = 10.0;

void fragment() {
	vec2 viewport_size = vec2(1.0) / SCREEN_PIXEL_SIZE;
	vec2 frag_pos = FRAGCOORD.xy;

	float alpha = 1.0; // start fully dark

	for (int i = 0; i < rect_count; i++) {
		if (i >= MAX_RECTS) break;

		vec2 rect_center = rect_positions[i] * viewport_size;
		vec2 half_size = rect_sizes[i] * 0.5;

		vec2 d = abs(frag_pos - rect_center) - half_size;
		float outside_dist = length(max(d, vec2(0.0)));
		float rect_alpha = smoothstep(0.0, softness, outside_dist);

		// Combine highlights: minimum alpha keeps bright holes
		alpha = min(alpha, rect_alpha);
	}

	COLOR = vec4(0.0, 0.0, 0.0, alpha * 0.35);


}
