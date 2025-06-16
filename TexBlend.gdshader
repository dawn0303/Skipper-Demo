shader_type spatial;

uniform sampler2D mask_texture : hint_default_white, repeat_disable ;
uniform vec4 albedo_a:source_color  = vec4(1.0f);
uniform sampler2D texture_a:hint_default_white ;
uniform vec4 albedo_b:source_color  = vec4(1.0f);
uniform sampler2D texture_b:hint_default_white ;

void fragment() {
	vec3 mask = texture(mask_texture, UV).rgb;
	vec3 a = albedo_a.rgb * texture(texture_a, UV).rgb;
	vec3 b = albedo_b.rgb * texture(texture_b, UV).rgb;
	vec3 color = mix(a, b, mask);
	ALBEDO = color;
}