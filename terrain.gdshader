shader_type spatial;

uniform sampler2D albedo;
uniform sampler2D detailnormal;
uniform sampler2D heightmap;
uniform float height_ratio = 1.0;

void vertex() {
	VERTEX.y += texture(heightmap, UV).r * height_ratio;
}

void fragment() {
	ALBEDO = texture(albedo, UV).rgb;
	NORMAL_MAP = texture(detailnormal, UV2).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
