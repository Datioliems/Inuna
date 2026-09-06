shader_type spatial;
render_mode specular_disabled, blend_mix;

uniform vec4 deep_color : source_color = vec4(0.20, 0.42, 0.44, 0.82);
uniform vec4 shallow_color : source_color = vec4(0.43, 0.72, 0.72, 0.78);
uniform vec4 foam_color : source_color = vec4(0.92, 0.93, 0.84, 0.88);
uniform float wave_speed = 0.35;
uniform float wave_scale = 5.0;
uniform float foam_amount = 0.12;

float stripe(vec2 uv, float offset) {
	float value = sin((uv.x + uv.y + offset) * wave_scale);
	return smoothstep(1.0 - foam_amount, 1.0, value);
}

void vertex() {
	VERTEX.y += sin((VERTEX.x + TIME * wave_speed) * 1.7) * 0.025;
	VERTEX.y += cos((VERTEX.z + TIME * wave_speed * 0.7) * 1.3) * 0.02;
}

void fragment() {
	float wave = stripe(UV, TIME * wave_speed);
	vec3 color = mix(deep_color.rgb, shallow_color.rgb, clamp(UV.y, 0.0, 1.0));
	color = mix(color, foam_color.rgb, wave);
	ALBEDO = color;
	ALPHA = mix(deep_color.a, foam_color.a, wave);
	ROUGHNESS = 1.0;
}
