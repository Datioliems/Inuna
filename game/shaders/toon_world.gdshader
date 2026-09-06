shader_type spatial;
render_mode specular_disabled;

uniform vec4 shadow_color : source_color = vec4(0.25, 0.32, 0.28, 1.0);
uniform vec4 mid_color : source_color = vec4(0.38, 0.58, 0.45, 1.0);
uniform vec4 light_color : source_color = vec4(0.60, 0.75, 0.58, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.95, 0.88, 0.60, 1.0);
uniform float shadow_step = 0.20;
uniform float mid_step = 0.55;
uniform float highlight_step = 0.84;
uniform float ambient_lift = 0.24;
uniform float saturation = 0.95;

vec3 apply_saturation(vec3 color, float sat) {
	float gray = dot(color, vec3(0.299, 0.587, 0.114));
	return mix(vec3(gray), color, sat);
}

void fragment() {
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
}

void light() {
	float ndotl = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	vec3 band = shadow_color.rgb;
	if (ndotl > shadow_step) {
		band = mid_color.rgb;
	}
	if (ndotl > mid_step) {
		band = light_color.rgb;
	}
	if (ndotl > highlight_step) {
		band = highlight_color.rgb;
	}
	band = apply_saturation(band, saturation);
	DIFFUSE_LIGHT += (band * LIGHT_COLOR * ATTENUATION) + (band * ambient_lift);
}

