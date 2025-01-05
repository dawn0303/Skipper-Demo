extends RigidBody3D
@export var value : int
@export var Name : String
@export var Description : String = ""
@export var Destination : Node
@export var Resistance : int
@onready var collider = $CollisionShape3D
@onready var condition = 100
@onready var startValue = value
@onready var savedValue = value
var carried 
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().is_in_group("Skipper"):
		carried = true
		collider.disabled = true
		get_parent().cargo.push_back(self)
		Destination.expected += 1
		Destination.update()
	if get_parent().is_in_group("Pad"):
		carried = false
		collider.disabled = true
		Destination.update()
		



func Check(pad : Node, index:int, skipper:Node):
	if pad == Destination:
		get_parent().addMoney(value)
		get_parent().cargo.remove_at(index)
		Destination.expected -=1
		Destination.update()
		queue_free()
	if carried == false:
		var dup = self.duplicate()
		skipper.add_child(dup)
		dup.name = name
		pad.outgoing.remove_at(index)
		queue_free()
		pad.update()

func Damage(damage, index):
	if damage < Resistance:
		return
	condition -= damage
	value = int(startValue*(condition/100))
	print("oof "+str(Name)+" took "+str(damage)+"and is now worth "+str(value))
	if condition < 1:
		get_parent().cargo.remove_at(index)
		queue_free()
		print(str(Name)+" broke!")
