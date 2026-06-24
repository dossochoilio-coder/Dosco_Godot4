shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.02, 0.03, 0.08, 1.0);
uniform vec4 accent_color : source_color = vec4(0.1, 0.3, 0.6, 0.15);
uniform float time_scale : hint_range(0.0, 2.0) = 0.3;

void fragment() {
    vec2 uv = UV * 3.0;
    float t = TIME * time_scale;
    
    // Simple animated nebula effect
    float noise = sin(uv.x * 2.0 + t) * cos(uv.y * 3.0 - t * 0.7) * 0.5 + 0.5;
    noise += sin(uv.x * 5.0 - t * 1.3) * cos(uv.y * 4.0 + t) * 0.3;
    
    COLOR = mix(base_color, accent_color, noise * 0.6);
}
