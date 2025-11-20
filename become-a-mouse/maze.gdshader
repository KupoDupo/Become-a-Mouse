shader_type canvas_item;

uniform vec2 player_pos;   // player position in pixels
uniform float radius = 150.0;
uniform vec2 screen_size;  // screen size in pixels
uniform float darkness_strength : hint_range(0.0, 1.0) = 1.0; // <— NEW

void fragment() {
    vec2 frag_pos = SCREEN_UV * screen_size;
    float dist = distance(frag_pos, player_pos);

    // fully transparent in center, fully black outside
    float alpha = smoothstep(radius - 20.0, radius, dist);

    // scale by darkness_strength (0 = off, 1 = normal)
    alpha *= darkness_strength;

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
