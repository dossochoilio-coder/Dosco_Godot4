shader_type canvas_item;
render_mode blend_mix;

uniform vec4 base_color : source_color = vec4(0.95, 0.97, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.4, 0.75, 1.0, 0.9);
uniform float glow_intensity : hint_range(0.0, 8.0) = 2.8;
uniform float ray_intensity : hint_range(0.0, 3.0) = 1.2;
uniform float pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float ray_count : hint_range(3.0, 12.0) = 6.0;
uniform float time_scale : hint_range(0.0, 3.0) = 1.0;

void fragment() {
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);
    
    // Base star
    vec4 color = base_color;
    
    // Soft glow
    float glow = exp(-dist * 4.5) * glow_intensity;
    color.rgb += glow_color.rgb * glow;
    
    // Rays (star-like)
    float angle = atan(uv.y, uv.x);
    float ray = pow(abs(sin(angle * ray_count + TIME * pulse_speed * time_scale)), 3.0);
    ray *= exp(-dist * 5.0) * ray_intensity;
    color.rgb += glow_color.rgb * ray * 0.7;
    
    // Subtle pulsing
    float pulse = sin(TIME * pulse_speed * time_scale) * 0.5 + 0.5;
    color.a *= mix(0.85, 1.0, pulse);
    
    COLOR = color * texture(TEXTURE, UV).a;
}
