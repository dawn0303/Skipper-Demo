extends MeshInstance3D
const CONTAINER = preload("res://environment/Bases/General/Container.gdshader")
const TEX = preload("res://environment/Bases/General/container1.png")
const MASK = preload("res://environment/Bases/General/containerMask.png")
func _ready() -> void:
	randomize()
	var newMat = ShaderMaterial.new()
	newMat.shader = CONTAINER
	newMat.set_shader_parameter("base_texture", TEX)
	newMat.set_shader_parameter("mask_texture", MASK)
	newMat.set_shader_parameter("offset", randf())
	self.material_override = newMat
	#get_mesh().surface_get_material(0).set_shader_parameter("offset", randf())
