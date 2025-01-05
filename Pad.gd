extends StaticBody3D
@export var Name : String
@export var padArea : Area3D
@export var Recieving_lights : Node3D
@export var outgoing_lights : Node3D
@export var neutral_lights : Node3D
var outgoing = []
var expected : int



# Called when the node enters the scene tree for the first time.
func _ready():
	for item in get_children():
		if item.is_in_group("Deliverable"):
			print("pad storage ")
			print(item)
			outgoing.push_back(item)
	update()



func update():
	outgoing_lights.visible = false
	Recieving_lights.visible = false
	neutral_lights.visible = false
	if outgoing.size() > 0:
		outgoing_lights.visible = true
	if expected > 0:
		Recieving_lights.visible = true
	if outgoing.size() + expected == 0:
		neutral_lights.visible = true
	print(str(Name) + " outgoing: " + str(outgoing.size()))
	print(str(Name) + " expected: " + str(expected))
