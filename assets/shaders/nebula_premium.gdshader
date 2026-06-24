shader_type canvas_item;

uniform vec4 deep_space : source_color = vec4(0.015, 0.02, 0.06, 1.0);
uniform vec4 nebula_color1 : source_color = vec4(0.1, 0.25, 0.55, 0.25);
uniform vec4 nebula_color2 : source_color = vec4(0.3, 0.15, 0.5, 0.2);
uniform float time_scale : hint_range(0.0, 1.0) = 0.25;
uniform float density : hint_range(0.5, 4.0) = 2.2;
uniform float brightness : hint_range(0.5, 3.0) = 1.3;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
    vec2 uv = UV * density;
    float t = TIME * time_scale;
    
    // Layered nebula
    float n1 = noise(uv * 1.5 + vec2(t * 0.3, t * 0.2));
    float n2 = noise(uv * 3.2 - vec2(t * 0.5, t * 0.4));
    float n3 = noise(uv * 6.0 + vec2(t * 0.8, -t * 0.6));
    
    float nebula = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;
    nebula = pow(nebula, 1.8);
    
    // Mix colors
    vec3 col = mix(deep_space.rgb, nebula_color1.rgb, nebula * 0.7);
    col = mix(col, nebula_color2.rgb, n2 * 0.4);
    
    // Add subtle stars
    float stars = step(0.985, noise(uv * 25.0));
    col += stars * vec3(0.9, 0.95, 1.0) * 0.8;
    
    COLOR = vec4(col * brightness, 1.0);
}
