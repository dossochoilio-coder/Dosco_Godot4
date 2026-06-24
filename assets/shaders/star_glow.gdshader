shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.3, 0.7, 1.0, 0.8);
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float glow_radius : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Simple glow effect using distance from center
    float dist = length(UV - vec2(0.5));
    float glow = glow_intensity * exp(-dist * glow_radius);
    
    COLOR = tex_color + (glow_color * glow * tex_color.a);
}
