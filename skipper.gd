extends RigidBody3D
var throttle = 0.0
var thrust = 1000
@onready var thruster1 = $Skipper/Skipper_004/thruster1
@onready var thruster2 = $Skipper/Skipper_004/thruster2
@onready var thruster3 = $Skipper/Skipper_004/thruster3
@onready var thruster4 = $Skipper/Skipper_004/thruster4
var thruster1Vector :Vector3
var thruster2Vector :Vector3
var thruster3Vector :Vector3
var thruster4Vector :Vector3
var rearThrustAdjust = 0.9
var FWDmod = 1.0
var BCKmod = 1.0
var LFTmod = 1.0
var RGTmod = 1.0
var steerStrength = 0.3
var steerBias = 0.02

#Called when the node enters the scene tree for the first time.
func _ready():
	thruster1Vector = rotationToVector(thruster1.rotation)
	thruster2Vector = rotationToVector(thruster2.rotation)
	thruster3Vector = rotationToVector(thruster3.rotation)
	thruster4Vector = rotationToVector(thruster4.rotation)
	print("hiiii")



func _physics_process(delta):
	if Input.is_action_pressed("throttle up") and throttle < 1:
		throttle += 0.01
	if Input.is_action_pressed("throttle down") and throttle > 0:
		throttle -= 0.01
	
	
	if Input.is_action_pressed("forwards"):
		FWDmod = lerpf(FWDmod, steerStrength, steerBias)
	else:
		FWDmod = lerpf(FWDmod, 1, steerBias)
		
	if Input.is_action_pressed("backwards"):
		BCKmod = lerpf(BCKmod, steerStrength, steerBias)
	else:
		BCKmod = lerpf(BCKmod, 1, steerBias)
	if Input.is_action_pressed("left"):
		LFTmod = lerpf(LFTmod, steerStrength, steerBias)
	else:
		LFTmod = lerpf(LFTmod, 1, steerBias)
	if Input.is_action_pressed("right"):
		RGTmod = lerpf(RGTmod, steerStrength, steerBias)
	else:
		RGTmod = lerpf(RGTmod, 1, steerBias)
	
	#
	#thruster1Vector = rotationToVector(thruster1.rotation)
	#thruster2Vector = rotationToVector(thruster2.rotation)
	#thruster3Vector = rotationToVector(thruster3.rotation)
	#thruster4Vector = rotationToVector(thruster4.rotation)
	
	apply_thrust()



func apply_thrust():
	apply_force(transform.basis*thruster1Vector*thrust*throttle*FWDmod*LFTmod, thruster1.position)
	apply_force(transform.basis*thruster3Vector*thrust*throttle*rearThrustAdjust*BCKmod*RGTmod, thruster3.position)
	apply_force(transform.basis*thruster2Vector*thrust*throttle*FWDmod*RGTmod, thruster2.position)
	apply_force(transform.basis*thruster4Vector*thrust*throttle*rearThrustAdjust*BCKmod*LFTmod, thruster4.position)

func rotationToVector(rot:Vector3):
	var x = sin(rot.x)
	var y = cos(rot.x)
	var z = y * cos(rot.y)
	if rot.y < 0:
		x = -x
	var vec = Vector3(x,y,z)
	print(vec)
	return vec

func addMoney(money):
	money
