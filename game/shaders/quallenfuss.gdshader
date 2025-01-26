shader_type spatial;

uniform sampler2D noise_texture;

uniform float u_wobble_strength: hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float u_opacity: hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float u_wobble_speed: hint_range(0.0, 3.0, 0.01) = 1.5;
uniform float u_noisiness: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform vec3 u_color: source_color;
uniform float u_glow: hint_range(0.0, 10.0, 0.1) = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float sinus = sin(VERTEX.y + TIME * u_wobble_speed);
	float noise = texture(noise_texture, vec2(VERTEX.y + TIME * u_wobble_speed * 0.01, 0.0)).r;
	float displacement = sinus + noise * u_noisiness;
	VERTEX.z += (displacement - 0.5) * u_wobble_strength;
}

float fresnel(vec3 normal, mat4 camera_matrix) {
	vec3 view_direction_world = (camera_matrix * vec4(0.0, 0.0, 1.0, 0.0)).xyz;
	vec3 normal_world = (camera_matrix * vec4(normal, 0.0)).xyz;

	float fresnel = dot(view_direction_world, normal_world);
	fresnel = clamp(abs(fresnel), 0.0, 1.0);
	return 1.0 - fresnel;
}

void fragment() {
	float fres = fresnel(NORMAL, VIEW_MATRIX);
	ALBEDO = u_color * (u_glow + 1.0);
	ALPHA = smoothstep(0.0, 1.0 - fres, u_opacity);
}
