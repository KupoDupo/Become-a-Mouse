shader_type canvas_item;

uniform vec2 player_pos;   // player position in pixels
uniform float radius = 150.0;
uniform vec2 screen_size;  // screen size in pixels

void fragment() {
    vec2 frag_pos = SCREEN_UV * screen_size;
    float dist = distance(frag_pos, player_pos);

    // fully transparent in center, fully black outside
    float alpha = smoothstep(radius - 20.0, radius, dist);

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}