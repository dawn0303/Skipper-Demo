extends RigidBody3D
var throttle : float = 0.0
var thrust = 500
var mouse_input : Vector2
var money = 10
var moneySaved = 0
@onready var thrustLabel = $Label3D2
@onready var twrLabel = $Label3D4
@onready var camera = $cameraRoot/Camera3D
@onready var camParent = $cameraRoot
@onready var headCollide = $Area3D
@onready var animPlayer = $CanvasLayer/AnimationPlayer
@onready var Static = $CanvasLayer/CenterContainer/Static
@onready var groundSensor = $GroundSensor
@onready var padSensor = $PadSensor
@onready var sellButton = "res://buttonRow1.tscn"
@onready var canvas = $CanvasLayer
@onready var list = $"Control/SubViewport/Pager UI".List
@onready var pager = $pager2
@onready var pagerUI = $"Control/SubViewport/Pager UI"
@onready var glitch = $CanvasLayer/vhs
@onready var VHS = $CanvasLayer/vhs
@onready var deathMsg = $CanvasLayer/CenterContainer/Static/Label
@onready var animTree = $SkipperNew/AnimationTree

var padOn = false
var padMode = "manifest"
var enableStatic = true
var torque = 100
var resetPos
var resetRot
var throttleaxis
var debug = true
var steerStrength = 0.02
var ActualThrust 
var TWR
var alive = true
var maxDist = 200000
var maxHeight = 55
var staticMargin = 50
var manualThr = true
var manualRot = true
var autoThr = false
var autoAlt = false
var autoRot = false
var desiredAlt = 0.0
var desiredSpeed = Vector2(0, 0)
var lastPad
var cargo = []
var cargoSaved = []
var lastVel = Vector3.ZERO
var impactThreshold = 1.0
var VHSBaseWiggle = 0.03
var VHSBaseSmear
#Called when the node enters the scene tree for the first time.
func _ready():
	#VHSBaseWiggle = VHS.get_material().get_shader_parameter("wiggle")
	VHSBaseSmear = VHS.get_material().get_shader_parameter("smear")
	glitch.get_material().set_shader_parameter("shake_power", 0.0)
	glitch.get_material().set_shader_parameter("shake_color_rate", 0.0)
	pager.hide()
	throttle = 0
	resetPos = global_position
	resetRot = global_rotation
	ActualThrust = thrust*4*0.8135
	print("hiiii")
	

func _unhandled_input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED: 
		if event is InputEventMouseMotion:
			mouse_input = event.relative
			camera.rotate_z(event.relative.y * .005)
			camParent.rotate_y(-event.relative.x * .005)
			camParent.rotation.x = clamp(camParent.rotation.x, (-PI/2 +0.42), (PI/2 - 0.4))


func _init():
	if debug:
		RenderingServer.set_debug_generate_wireframes(true)



func _input(event):
	if debug and event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 5
	if event is InputEventKey and Input.is_action_just_pressed("open_manifest"):
		if padOn:
			closePad()
		elif  padSensor.has_overlapping_areas() or linear_velocity.length() <0.1:
			openPad()
			match padMode:
				"manifest":
					openManifest()
					padMode="manifest"
				"depot":
					openDepotManifest()
					padMode="depot"
		
	if list.visible and event is InputEventKey and Input.is_action_just_pressed("ui_down") :
		if list.selectNext():
			match padMode:
				"manifest":
					if cargo.size() > 0:
						pagerUI.top.text = "VALUE: "+ str(cargo[list.index].value)
						pagerUI.bottom.text = "DELIVER TO: "+ str(cargo[list.index].Destination.Name)
				"depot":
					if lastPad.outgoing.size() > 0:
						pagerUI.top.text = "VALUE: "+ str(lastPad.outgoing[list.index].value)
						pagerUI.bottom.text = "DELIVER TO: "+ str(lastPad.outgoing[list.index].Destination.Name)
	
	if list.visible and event is InputEventKey and Input.is_action_just_pressed("ui_up"):
		if list.selectPrev():
			match padMode:
				"manifest":
					if cargo.size() > 0:
						pagerUI.top.text = "VALUE: "+ str(cargo[list.index].value)
						pagerUI.bottom.text = "DELIVER TO: "+ str(cargo[list.index].Destination.Name)
				"depot":
					if lastPad.outgoing.size() > 0:
						pagerUI.top.text = "VALUE: "+ str(lastPad.outgoing[list.index].value)
						pagerUI.bottom.text = "DELIVER TO: "+ str(lastPad.outgoing[list.index].Destination.Name)
	
	
	if list.visible and event is InputEventKey and Input.is_action_just_pressed("ui_right"):
		match padMode:
			"manifest":
				openDepotManifest()
				padMode="depot"
			"depot":
				openManifest()
				padMode="manifest"
		
	if list.visible and Input.is_action_just_pressed("LeftButton") and padSensor.has_overlapping_areas():
		match padMode:
			"manifest":
				sellCargo(list.index)
			"depot":
				getCargo(list.index)


func _physics_process(_delta):
	if Input.is_action_just_pressed("Reset"):
		reset()
	
	
	if  VHS.get_material().get_shader_parameter("wiggle") > VHSBaseWiggle:
		VHS.get_material().set_shader_parameter("wiggle", lerpf(VHS.get_material().get_shader_parameter("wiggle"), VHSBaseWiggle, 0.01))
	
	if  VHS.get_material().get_shader_parameter("smear") > VHSBaseSmear:
		VHS.get_material().set_shader_parameter("smear", lerpf(VHS.get_material().get_shader_parameter("smear"), VHSBaseSmear, 0.01))
	
	
	if glitch.get_material().get_shader_parameter("shake_power") > 0:
		glitch.get_material().set_shader_parameter("shake_power", lerpf(glitch.get_material().get_shader_parameter("shake_power"), 0, 0.005))
		
	if glitch.get_material().get_shader_parameter("shake_color_rate")> 0:
		glitch.get_material().set_shader_parameter("shake_color_rate", lerpf(glitch.get_material().get_shader_parameter("shake_color_rate"), 0, 0.005))
	
	
	if !alive:
		return
	if headCollide.has_overlapping_bodies():
		die()

	
	if manualThr:
		manualThrottle()
	elif autoThr:
		autoThrottle()
	elif autoAlt:
		autoAltitude()
	
	
	manualRotation()
	
	if Input.is_action_pressed("Rclick"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	throttle = clampf(throttle, 0.0, 1.0)
	TWR = (throttle*(ActualThrust/9.81))/(mass/6) 
	#twrLabel.text = str(int(round(TWR*100)), "%")
	twrLabel.text = str("%.2f" % TWR)
	thrustLabel.text = str(int(round(throttle*100)), "%")
	
	if (global_position*Vector3(1, 0, 1)).length() > maxDist:
		Static.modulate.a = ((global_position*Vector3(1, 0, 1)).length()-maxDist)/staticMargin
		if enableStatic and !Static.is_playing():
			Static.play()
	elif global_position.y > maxHeight:
		Static.modulate.a = (global_position.y-maxHeight)/staticMargin
		if enableStatic and !Static.is_playing():
			Static.play()
	else:
		Static.modulate.a /=2
	
	if alive and Static.is_playing() and Static.modulate.a == 0:
			Static.stop()
			
	
	apply_thrust()
	lastVel = linear_velocity
	
	if abs(lastVel-linear_velocity).length() > impactThreshold:
		impact(abs(lastVel-linear_velocity).length())

func apply_thrust():
	apply_force(throttle*ActualThrust * transform.basis.y)

func manualThrottle():
	throttleaxis = Input.get_axis("throttleAxisDown", "throttleAxisUp")
	if throttleaxis>0:
		throttle = (throttleaxis)/8
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
	
	if Input.is_action_pressed("throttle up") and throttle < 1:
		throttle += 0.01
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
	if Input.is_action_pressed("throttle down") and throttle > 0:
		throttle -= 0.01
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
	if Input.is_action_pressed("max throttle"):
		throttle = 1
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
	if Input.is_action_pressed("cut engines"):
		throttle = 0
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)

func manualRotation():
	
	var yawAxis = Input.get_axis("yaw left", "yaw right")
	apply_torque(-yawAxis*torque* transform.basis.y)
	animTree.set("parameters/BlendSpace1D/blend_position", yawAxis)
	var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
	apply_torque(-input_dir.x*torque*transform.basis.x)
	apply_torque(-input_dir.y*torque*transform.basis.z)
	animTree.set("parameters/BlendSpace2D/blend_position", input_dir*Vector2(1,-1))
	angular_velocity = angular_velocity.lerp(Vector3(0,0,0), steerStrength)

func autoThrottle():
	if Input.is_action_pressed("throttle up") and throttle < 1:
		throttle += 0.01
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		return
	if Input.is_action_pressed("throttle down") and throttle > 0:
		throttle -= 0.1
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		return
	if groundSensor.has_overlapping_bodies() or groundSensor.has_overlapping_areas():
		throttle = 0 
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		return
	if linear_velocity.y <0.001 and linear_velocity.y > -0.001:
		return
	if linear_velocity.y > 0.0 and throttle > 0:
		throttle = lerpf(throttle, 0, clampf((linear_velocity.y), -0.01, 0.01))
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		return
	if linear_velocity.y < -0.0:
		throttle = lerpf(throttle, 1, clampf((0-linear_velocity.y), -0.01, 0.01))
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)

func autoAltitude():
	#if Input.is_action_pressed("throttle up"):
		#desiredAlt += 1
	#if Input.is_action_pressed("throttle down"):
		#desiredAlt -= 1
	#var altitude = (global_position.y - altimeter.get_collision_point().y )
	#var difference = desiredAlt - altitude
	#if difference < 0:
		#throttle = 0
	#if difference > 0.04:
		#throttle += 0.01  #lerpf(throttle, 0., clampf((difference/100), 0, 0.01))
	#print(altitude)
	#print(desiredAlt)
	#print(difference)
	return

func autoRotation():
	#
	#if linear_velocity.x > desiredSpeed.x:
		#apply_torque(transform.basis.x*-(5*desiredSpeed.x-linear_velocity.x))
	#if linear_velocity.x < desiredSpeed.x:
		#apply_torque(-transform.basis.x*(5*desiredSpeed.x-linear_velocity.x))
	#if linear_velocity.z > desiredSpeed.y:
		#1+1
	#if linear_velocity.z < desiredSpeed.y:
		#1+1
	#
	#
	#var yawAxis = Input.get_axis("yaw left", "yaw right")
	##apply_torque(-yawAxis*torque* transform.basis.y)
	#var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
	#desiredSpeed.y += input_dir.y/10
	#desiredSpeed.x += yawAxis/10
	#print(desiredSpeed)
	##apply_torque(-input_dir.x*torque*transform.basis.x)
	##apply_torque(-input_dir.y*torque*transform.basis.z)
	#angular_velocity = angular_velocity.lerp(Vector3(0,0,0), steerStrength)
	#
	#
	return

func rotationToVector(rot:Vector3):
	var x = sin(rot.x)
	var y = cos(rot.x)
	var z = y * cos(rot.y)
	if rot.y < 0:
		x = -x
	var vec = Vector3(x,y,z)
	print(vec)
	return vec

func reset():
	throttle = 0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = resetPos 
	global_rotation = resetRot
	camera.current = true
	animPlayer.play("RESET")
	desiredAlt = 0
	if enableStatic:
		Static.stop()
		
	for item in cargo:
		item.value = item.savedValue
		
	
	deathMsg.visible = false
	alive = true
	
	VHS.get_material().set_shader_parameter("wiggle",VHSBaseWiggle)
	VHS.get_material().set_shader_parameter("smear",VHSBaseSmear)
	
	glitch.get_material().set_shader_parameter("shake_power", 0.0)
	glitch.get_material().set_shader_parameter("shake_color_rate", 0.0)

func die():
	alive = false
	if enableStatic:
		Static.play()
	animPlayer.play("DIE")
	deathMsg.visible = true
	camera.current = false

func addMoney(amount):
	money+= amount
	print(amount, " profit!")

func loseModney(amount):
	money -= amount
	print("lost ", amount)

func _on_pad_sensor_area_entered(area):
	lastPad = area.get_parent()

func closePad():
	pager.hide()
	padOn = false

func openPad():
	pager.show()
	padOn = true

func openManifest():
	list.clear()
	pagerUI.top.text = "NO CARGO"
	pagerUI.bottom.text ="RETURN TO DEPOT"
	pagerUI.extra.text = "SHIP"
	if cargo.size() > 0:
		pagerUI.top.text = "VALUE: "+ str(cargo[list.index].value)
		pagerUI.bottom.text = "DELIVER TO: "+ str(cargo[list.index].Destination.Name)
	if cargo.size() == 0:
		return
	for item in cargo:
		list.add_item(item.name)
	list.select(list.index)

func openDepotManifest():
	list.clear()
	pagerUI.top.text = "DEPOT EMPTY"
	pagerUI.bottom.text ="NEXT DELIVERY"
	pagerUI.extra.text = "DEPOT"
	if lastPad.outgoing.size() > 0:
		pagerUI.top.text = "VALUE: "+ str(lastPad.outgoing[list.index].value)
		pagerUI.bottom.text = "DELIVER TO: "+ str(lastPad.outgoing[list.index].Destination.Name)
	if lastPad.outgoing.size() == 0:
		return
	for item in lastPad.outgoing:
		list.add_item(item.name)
	list.select(list.index)

func sellCargo(index):
	if !linear_velocity.length() <0.1 or cargo.size() == 0:
		return
	if cargo[index].Destination == lastPad:
		list.remove_item(index)
		if list.index==0:
			list.selectPrev()
		else:
			list.selectPrev()
		cargo[index].Check(lastPad, index,self)
		#addMoney(cargo[index].value)
		#cargo[index].queue_free()
		#cargo.remove_at(index)
		if cargo.size() == 0:
			pagerUI.top.text = "NO CARGO"
			pagerUI.bottom.text = "RETURN TO DEPOT"
		else:
			pagerUI.top.text = "VALUE: "+ str(cargo[list.index].value)
			pagerUI.bottom.text = "DELIVER TO: "+ str(cargo[list.index].Destination.Name)
		save()

func getCargo(index):
	if !linear_velocity.length() <0.1 or lastPad.outgoing.size() == 0:
		return
		
	list.remove_item(index)
	if list.index==0:
		list.selectPrev()
	else:
		list.selectPrev()
	lastPad.outgoing[index].Check(lastPad, index, self)
	if lastPad.outgoing.size() == 0:
		pagerUI.top.text = "DEPOT EMPTY"
		pagerUI.bottom.text = "NEXT DELIVERY"
	else:
		pagerUI.top.text = "VALUE: "+ str(lastPad.outgoing[list.index].value)
		pagerUI.bottom.text = "DELIVER TO: "+ str(lastPad.outgoing[list.index].Destination.Name)
	save()

func impact(speedChange):
	print("impact at: "+str(speedChange))
	if speedChange > 10:
		die()
	
	VHS.get_material().set_shader_parameter("wiggle",clampf((VHSBaseWiggle+round(speedChange/5)/10), VHSBaseWiggle, 1.5))
	VHS.get_material().set_shader_parameter("smear",clampf((VHSBaseSmear+round(speedChange*2)/10), VHSBaseSmear, 2.0))
	
	glitch.get_material().set_shader_parameter("shake_power", round(speedChange/2)/100)
	glitch.get_material().set_shader_parameter("shake_color_rate", round(speedChange/2)/100)
	
	for item in cargo:
		var index = 0
		item.Damage(speedChange, index)
		index+=1
	


func _on_body_entered(_body):
	if abs(lastVel-linear_velocity).length() > impactThreshold:
		impact(abs(lastVel-linear_velocity).length())
	


func save():
	for item in cargo:
		item.savedValue = item.value
	moneySaved = money
	cargoSaved = cargo
	resetPos = global_position + Vector3(0,0.2,0)
	print("saved")
	#resetRot = global_rotation
