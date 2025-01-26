shader_type spatial;

uniform sampler2D noise_texture;
uniform sampler2D color_texture;
uniform float smoothness: hint_range(0.0, 0.2, 0.01);
uniform float wobble_strength: hint_range(0.0, 1.0, 0.01);
uniform float color_intensity: hint_range(0.0, 1.0, 0.01);
uniform float opacity: hint_range(0.0, 1.0, 0.1);
uniform float speed: hint_range(0.0, 2.0) = 1.0;
instance uniform float size = 1.0;
instance uniform float noise_offset = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 noise_crd = VERTEX.xz * smoothness + vec2(TIME * speed * 0.1) + noise_offset;
	float height = texture(noise_texture, noise_crd).r;
	VERTEX += NORMAL * (height - 0.5) * wobble_strength;
	VERTEX *= size;
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
	ALBEDO = vec3(1.0, 1.0, 1.0)
		- texture(color_texture, world_position.xz + vec2(world_position.y + TIME * speed * 0.1)).rgb * color_intensity;
	ALPHA = fres * opacity;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
