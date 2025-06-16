shader_type spatial;

uniform sampler2D base_texture : hint_default_white, filter_nearest ;
uniform sampler2D mask_texture : hint_default_white, filter_nearest ;

uniform float offset : hint_range(0, 1);

void fragment() {
	vec4 mask = texture(mask_texture, UV);
	vec3 Basetex = texture(base_texture, UV).rgb;
	vec3 Colour =  texture(base_texture, UV2+vec2(offset-0.5,0)).rgb ;
	
	
	ALBEDO = mix(Basetex*Colour/vec3(2,2,2), Basetex/vec3(3,3,3), mask.a);
}