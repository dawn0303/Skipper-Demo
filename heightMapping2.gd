extends MeshInstance3D

@onready var colshape = $StaticBody3D/CollisionShape3D
@export var chunksize = 2000
@export var height_ratio = 0.597
@export var colShapeRatio = 200
@export var heightMap = "res://textures/LRO_LOLA_DEM_NPolar875_10m.png"

var img = Image.new()
var shape = HeightMapShape3D.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	colshape.shape = shape
	mesh.size = Vector2(chunksize, chunksize)
	update_terrain(height_ratio, colShapeRatio)

func update_terrain(_height_ratio, _colshape_size_ratio):
	#material_override.set("shader_parameter/height_ratio", _height_ratio)
	img.load(heightMap)
	img.convert(Image.FORMAT_RF)
	img.resize(img.get_width()*_colshape_size_ratio, img.get_height()*_colshape_size_ratio)
	var data = img.get_data().to_float32_array()
	for i in range(0, data.size()):
		data[i] *= _height_ratio
	shape.map_width = img.get_width()
	shape.map_depth = img.get_height()
	shape.map_data = data
	var scale_ratio = chunksize/float(img.get_width())
	colshape.scale = Vector3(scale_ratio, 1, scale_ratio)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

