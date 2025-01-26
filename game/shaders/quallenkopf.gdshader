shader_type spatial;

uniform sampler2D noise_texture;

uniform float u_wobble_strength: hint_range(0.0, 0.25, 0.01) = 0.1;
uniform float u_opacity: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float u_wobble_speed: hint_range(0.0, 3.0, 0.01) = 1.5;
uniform float u_noisiness: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform vec3 u_color: source_color;
uniform float u_glow: hint_range(0.0, 10.0, 0.1) = 0.0;

varying vec3 world_position;
varying float distance_from_center;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float sinus = sin(VERTEX.y + TIME * u_wobble_speed);
	float noise = texture(noise_texture, VERTEX.xz + TIME * u_wobble_speed * 0.01).r;
	float displacement = sinus + noise * u_noisiness;
	
	VERTEX.xz *= 1.0 + (displacement * u_wobble_strength);
	distance_from_center = length(VERTEX.xz);
}

float fresnel(vec3 normal, mat4 camera_matrix) {
	vec3 view_direction_world = (camera_matrix * vec4(0.0, 0.0, 1.0, 0.0)).xyz;
	vec3 normal_world = (camera_matrix * vec4(normal, 0.0)).xyz;
	
	float fresnel = dot(view_direction_world, normal_world);
	fresnel = clamp(abs(fresnel), 0.0, 1.0);
	return 1.0 - fresnel;
}

void fragment() {
	ALBEDO = u_color * (u_glow + 1.0);
	float extraglow = exp((distance_from_center - 3.0) * 4.0) + 0.05;
	ALBEDO *= extraglow;
	//ALPHA = smoothstep(0.0, 1.0 - fres, u_opacity);
	//ALPHA = fres * u_opacity;
	//float fres = fresnel(NORMAL, VIEW_MATRIX);
	ALPHA = 0.9;
}
