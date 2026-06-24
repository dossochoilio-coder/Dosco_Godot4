shader_type canvas_item;

uniform vec4 highlight_color : source_color = vec4(0.3, 0.65, 1.0, 0.6);
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 8.0) = 3.0;

void fragment() {
    float pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    float alpha = highlight_color.a * intensity * pulse;
    
    COLOR = vec4(highlight_color.rgb, alpha);
}
