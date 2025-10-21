shader_type canvas_item;

uniform vec2 rect_pos = vec2(0.5, 0.5); // normalized center of the hole (0–1)
uniform vec2 rect_size = vec2(200.0, 80.0); // width/height in pixels
uniform float softness : hint_range(0.0, 100.0) = 10.0; // edge smoothness

void fragment() {
    vec2 viewport_size = vec2(1.0) / SCREEN_PIXEL_SIZE;
    vec2 frag_pos = FRAGCOORD.xy;
    vec2 rect_center = rect_pos * viewport_size;
    vec2 half_size = rect_size * 0.5;

    // Distance from fragment to rectangle edge
    vec2 d = abs(frag_pos - rect_center) - half_size;

    // This line gives *rectangular* distance instead of circular
    float outside_dist = max(d.x, d.y);

    // Smooth fade near the edges
    float alpha = smoothstep(0.0, softness, outside_dist);

    // Dim overlay outside rectangle
    COLOR = vec4(0.0, 0.0, 0.0, alpha * 0.35);
}
