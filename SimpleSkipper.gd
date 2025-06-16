extends RigidBody3D
var throttle : float = 0.0
var thrust = 500
var mouse_input : Vector2
var money = 10
var moneySaved = 0
@onready var thrustLabel = $Label3D2
@onready var twrLabel = $Label3D4
@onready var altLabel = $AltLabel
@onready var velLabel = $VELlabel
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
@onready var animTree2 = $SkipperNew/AnimationTree2
@onready var altimeter = $Altimiter
@onready var Ambiance = $Ambiance
@onready var EngineAudio = $Engines
@onready var Headlamp = $cameraRoot/Camera3D/SpotLight3D
@onready var tutorialDialogue = load("res://Dialogue/tutorial.dialogue")
@onready var RoxDialogue = load("res://Dialogue/Roxy.dialogue")
@onready var tooltip = $CanvasLayer/Tooltip
@onready var DTMF: AudioStreamPlayer = $pager2/Cube/AudioStreamPlayer

var roxchat = false
var world
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
var maxDist = 800
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
var resetCamPRot
var resetCamRot
var volume
var modulate
var firstInput = false

#Called when the node enters the scene tree for the first time.
func _ready():
	camera.current = true
	resetCamPRot = camParent.rotation
	resetCamRot = camera.rotation
	world = get_parent()
	updateSettings()
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
	Ambiance.play()
	EngineAudio.volume_linear = 0
	EngineAudio.play()
	#Globals.throttleTest = false
	#if Globals.Tutorial:
	#	DialogueManager.show_dialogue_balloon(tutorialDialogue, "start")

func updateSettings():
	VHS.visible=world.config_.vhs
	Static.speed_scale = world.config_.staticAnimation
	volume = world.config_.volume/100
	Ambiance.volume_linear = world.config_.volume/100
	

func _unhandled_input(event):
	if world.menuOpen:
		return
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
	if Globals.Tutorial and !firstInput and event.is_pressed():
		firstInput = true
		DialogueManager.show_dialogue_balloon(tutorialDialogue, "start")
		
	if world.menuOpen:
		return
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
		DTMF.dialTone("D")
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
		DTMF.dialTone("A")
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
		DTMF.dialTone("B")
		match padMode:
			"manifest":
				openDepotManifest()
				padMode="depot"
			"depot":
				openManifest()
				padMode="manifest"
	
	if list.visible and event is InputEventKey and Input.is_action_just_pressed("ui_left"):
		DTMF.dialTone("C")
	
	if list.visible and Input.is_action_just_pressed("LeftButton") and padSensor.has_overlapping_areas():
		DTMF.dialTone("#")
		match padMode:
			"manifest":
				sellCargo(list.index)
			"depot":
				getCargo(list.index)


func _physics_process(_delta):
	if Input.is_action_just_pressed("Reset"):
		reset()
	
	if Input.is_action_just_pressed("Headlamp") and !Headlamp.visible:
		Headlamp.visible = true
	elif Input.is_action_just_pressed("Headlamp") and Headlamp.visible:
		Headlamp.visible = false
		
	if  VHS.get_material().get_shader_parameter("wiggle") > VHSBaseWiggle:
		VHS.get_material().set_shader_parameter("wiggle", lerpf(VHS.get_material().get_shader_parameter("wiggle"), VHSBaseWiggle, 0.01))
	
	if  VHS.get_material().get_shader_parameter("smear") > VHSBaseSmear:
		VHS.get_material().set_shader_parameter("smear", lerpf(VHS.get_material().get_shader_parameter("smear"), VHSBaseSmear, 0.01))
	
	
	if glitch.get_material().get_shader_parameter("shake_power") > 0:
		glitch.get_material().set_shader_parameter("shake_power", lerpf(glitch.get_material().get_shader_parameter("shake_power"), 0, 0.005))
		
	if glitch.get_material().get_shader_parameter("shake_color_rate")> 0:
		glitch.get_material().set_shader_parameter("shake_color_rate", lerpf(glitch.get_material().get_shader_parameter("shake_color_rate"), 0, 0.005))
	
	
	if Input.is_action_pressed("Rclick") or Input.is_action_pressed("freelook") :
		if world.menuOpen:
			return
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		if world.menuOpen:
			return
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
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
	
	throttle = clampf(throttle, 0.0, 1.0)
	TWR = (throttle*(ActualThrust/9.81))/(mass/6) 
	#twrLabel.text = str(int(round(TWR*100)), "%")
	twrLabel.text = str("%.2f" % TWR)
	thrustLabel.text = str(int(round(throttle*100)), "%")
	velLabel.text = str(int(round(linear_velocity.length())))
	if altimeter.is_colliding():
		altLabel.text = str(int(global_position.distance_to(altimeter.get_collision_point())), "M")
	else:
		altLabel.text = "NaN"
	
	altimeter.global_rotation = Vector3.ZERO
	
	if (global_position*Vector3(1, 0, 1)).length() > maxDist and global_position.y > maxHeight:
		Static.modulate.a = ((global_position*Vector3(1, 0, 1)).length()-maxDist)/staticMargin + (global_position.y-maxHeight)/staticMargin
		if enableStatic and !Static.is_playing():
			Static.play()
	elif (global_position*Vector3(1, 0, 1)).length() > maxDist:
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
	
	match  Globals.tutorialMode:
		"Throttle":
			if !Globals.throttledUp:
				tooltip.text = "%s" % InputMap.action_get_events("throttle up")[0].as_text().to_upper() + " TO THROTTLE UP \n" + "%s" % InputMap.action_get_events("max throttle")[0].as_text().to_upper() + " FOR MAX THROTTLE"
			if throttle > 0.5:
				Globals.throttledUp = true
				tooltip.text = "%s" % InputMap.action_get_events("throttle down")[0].as_text().to_upper() + " TO THROTTLE DOWN \n" + "%s" % InputMap.action_get_events("cut engines")[0].as_text().to_upper() + " TO CUT ENGINES"
			
			if throttle == 0 and Globals.throttledUp:
				Globals.throttledDown = true
			if Globals.throttledDown and Globals.throttledUp:
				tooltip.text = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "throttle")
				Globals.tutorialMode = ""
				throttle = 0
				
		"Stick":
			if !Globals.pitchedDown:
				tooltip.text = "%s" % InputMap.action_get_events("forwards")[0].as_text().to_upper().to_upper() + " TO PITCH DOWN"
				if Input.is_action_pressed("forwards"):
					Globals.pitchedDown = true
			elif !Globals.pitchedUp:
				tooltip.text = "%s" % InputMap.action_get_events("backwards")[0].as_text().to_upper() + " TO PITCH UP"
				if Input.is_action_pressed("backwards"):
					Globals.pitchedUp = true
			elif !Globals.rolledRight:
				tooltip.text = "%s" % InputMap.action_get_events("right")[0].as_text().to_upper() + " TO ROLL RIGHT"
				if Input.is_action_pressed("right"):
					Globals.rolledRight = true
			elif !Globals.rolledLeft:
				tooltip.text = "%s" % InputMap.action_get_events("left")[0].as_text().to_upper() + " TO ROLL LEFT"
				if Input.is_action_pressed("left"):
					Globals.rolledLeft = true
			else:
				tooltip.text = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "stick")
				Globals.tutorialMode = ""
		
		"Pedal":
			if !Globals.yawedRight:
				tooltip.text = "%s" % InputMap.action_get_events("yaw right")[0].as_text().to_upper() + " TO YAW RIGHT"
				if Input.is_action_pressed("yaw right"):
					Globals.yawedRight = true
			elif !Globals.yawedLeft:
				tooltip.text = "%s" % InputMap.action_get_events("yaw left")[0].as_text().to_upper() + " TO YAW LEFT"
				if Input.is_action_pressed("yaw left"):
					Globals.yawedLeft = true
			else:
				tooltip.text = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "pedals")
				Globals.tutorialMode = ""
		
		"TerminalUp":
			tooltip.text = "%s" % InputMap.action_get_events("open_manifest")[0].as_text().to_upper() + " TO VIEW TERMINAL"
			if Input.is_action_pressed("open_manifest"):
				Globals.tutorialMode = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "terminal")
				tooltip.text = ""
		
		"Tab":
			tooltip.text = "%s" % InputMap.action_get_events("ui_right")[0].as_text().to_upper() + " TO CHANGE TO DEPOT INVENTORY"
			if Input.is_action_pressed("ui_right"):
				Globals.tutorialMode = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "tab")
				tooltip.text = ""
		
		"Pickup":
			tooltip.text = "%s" % InputMap.action_get_events("LeftButton")[0].as_text().to_upper() + " TO PICK UP OR/SELL CARGO"
			if cargo.size() > 0:
				Globals.tutorialMode = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "pickup")
				tooltip.text = ""
		
		"TerminalDown":
			tooltip.text = "%s" % InputMap.action_get_events("open_manifest")[0].as_text().to_upper() + " TO STOW TERMINAL"
			if Input.is_action_pressed("open_manifest"):
				Globals.tutorialMode = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "terminalDown")
				tooltip.text = ""
		
		"Map":
			tooltip.text = "%s" % InputMap.action_get_events("map")[0].as_text().to_upper() + " TO VIEW MAP"
			if Input.is_action_pressed("map"):
				Globals.tutorialMode = ""
				DialogueManager.show_dialogue_balloon(tutorialDialogue, "map")
				tooltip.text = ""
	
	#if Globals.Tutorial: old
		#return
		#if Globals.throttleTest:
			#if !Globals.throttledUp:
				#tooltip.text = "%s" % InputMap.action_get_events("throttle up")[0].as_text().to_upper() + " TO THROTTLE UP \n" + "%s" % InputMap.action_get_events("max throttle")[0].as_text().to_upper() + " FOR MAX THROTTLE"
			#if throttle > 0.5:
				#Globals.throttledUp = true
				#tooltip.text = "%s" % InputMap.action_get_events("throttle down")[0].as_text().to_upper() + " TO THROTTLE DOWN \n" + "%s" % InputMap.action_get_events("cut engines")[0].as_text().to_upper() + " TO CUT ENGINES"
			#
			#if throttle == 0 and Globals.throttledUp:
				#Globals.throttledDown = true
			#if Globals.throttledDown and Globals.throttledUp:
				#tooltip.text = ""
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "throttle")
				#Globals.throttleTest = false
				#throttle = 0
				#
		#elif Globals.stickTest:
			#if !Globals.pitchedDown:
				#tooltip.text = "%s" % InputMap.action_get_events("forwards")[0].as_text().to_upper().to_upper() + " TO PITCH DOWN"
				#if Input.is_action_pressed("forwards"):
					#Globals.pitchedDown = true
			#elif !Globals.pitchedUp:
				#tooltip.text = "%s" % InputMap.action_get_events("backwards")[0].as_text().to_upper() + " TO PITCH UP"
				#if Input.is_action_pressed("backwards"):
					#Globals.pitchedUp = true
			#elif !Globals.rolledRight:
				#tooltip.text = "%s" % InputMap.action_get_events("right")[0].as_text().to_upper() + " TO ROLL RIGHT"
				#if Input.is_action_pressed("right"):
					#Globals.rolledRight = true
			#elif !Globals.rolledLeft:
				#tooltip.text = "%s" % InputMap.action_get_events("left")[0].as_text().to_upper() + " TO ROLL LEFT"
				#if Input.is_action_pressed("left"):
					#Globals.rolledLeft = true
			#else:
				#tooltip.text = ""
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "stick")
				#Globals.stickTest = false
		#
		#elif Globals.pedalTest:
			#if !Globals.yawedRight:
				#tooltip.text = "%s" % InputMap.action_get_events("yaw right")[0].as_text().to_upper() + " TO YAW RIGHT"
				#if Input.is_action_pressed("yaw right"):
					#Globals.yawedRight = true
			#elif !Globals.yawedLeft:
				#tooltip.text = "%s" % InputMap.action_get_events("yaw left")[0].as_text().to_upper() + " TO YAW LEFT"
				#if Input.is_action_pressed("yaw left"):
					#Globals.yawedLeft = true
			#else:
				#tooltip.text = ""
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "pedals")
				#Globals.pedalTest = false
		#
		#elif Globals.terminalUp:
			#tooltip.text = "%s" % InputMap.action_get_events("open_manifest")[0].as_text().to_upper() + " TO VIEW TERMINAL"
			#if Input.is_action_pressed("open_manifest"):
				#Globals.terminalUp = false
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "terminal")
				#tooltip.text = ""
		#
		#elif Globals.tabChange:
			#tooltip.text = "%s" % InputMap.action_get_events("ui_right")[0].as_text().to_upper() + " TO CHANGE TO DEPOT INVENTORY"
			#if Input.is_action_pressed("ui_right"):
				#Globals.tabChange = false
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "tab")
				#tooltip.text = ""
		#
		#elif Globals.pickUp:
			#tooltip.text = "%s" % InputMap.action_get_events("LeftButton")[0].as_text().to_upper() + " TO PICK UP OR/SELL CARGO"
			#if cargo.size() > 0:
				#Globals.pickUp = false
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "pickup")
				#tooltip.text = ""
		#
		#elif Globals.terminalDown:
			#tooltip.text = "%s" % InputMap.action_get_events("open_manifest")[0].as_text().to_upper() + " TO STOW TERMINAL"
			#if Input.is_action_pressed("open_manifest"):
				#Globals.terminalDown = false
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "terminalDown")
				#tooltip.text = ""
		#
		#elif Globals.mapUp:
			#tooltip.text = "%s" % InputMap.action_get_events("map")[0].as_text().to_upper() + " TO VIEW MAP"
			#if Input.is_action_pressed("map"):
				#Globals.mapUp = false
				#DialogueManager.show_dialogue_balloon(tutorialDialogue, "map")
				#tooltip.text = ""

func apply_thrust():
	if Globals.Tutorial:
		return
	apply_force(throttle*ActualThrust * transform.basis.y)
	EngineAudio.volume_linear = throttle*volume

func manualThrottle():
	if world.menuOpen or padOn:
		return
	throttleaxis = Input.get_axis("throttleAxisDown", "throttleAxisUp")
	if throttleaxis>0:
		throttle = (throttleaxis)
	if Input.is_action_pressed("throttle up") and throttle < 1:
		throttle += 0.01
	if Input.is_action_pressed("throttle down") and throttle > 0:
		throttle -= 0.01
	if Input.is_action_pressed("max throttle"):
		throttle = 1
	if Input.is_action_pressed("cut engines"):
		throttle = 0
	animTree.set("parameters/TimeSeek/seek_request", throttle*5)
	animTree2.set("parameters/TimeSeek/seek_request", throttle*3.3333)

func manualRotation():
	
	var yawAxis = Input.get_axis("yaw left", "yaw right")
	apply_torque(-yawAxis*torque* transform.basis.y)
	animTree.set("parameters/BlendSpace1D/blend_position", yawAxis)
	animTree2.set("parameters/BlendSpace1D/blend_position", yawAxis)
	var input_dir = Input.get_vector("left", "right", "forwards", "backwards")
	apply_torque(-input_dir.x*torque*transform.basis.x)
	apply_torque(-input_dir.y*torque*transform.basis.z)
	animTree.set("parameters/BlendSpace2D/blend_position", input_dir*Vector2(1,-1))
	animTree2.set("parameters/BlendSpace2D/blend_position", input_dir*Vector2(1,-1))
	angular_velocity = angular_velocity.lerp(Vector3(0,0,0), steerStrength)

func autoThrottle():
	if Input.is_action_pressed("throttle up") and throttle < 1:
		throttle += 0.01
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		animTree2.set("parameters/TimeSeek/seek_request", throttle*3.3333)
		return
	if Input.is_action_pressed("throttle down") and throttle > 0:
		throttle -= 0.1
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		animTree2.set("parameters/TimeSeek/seek_request", throttle*3.3333)
		return
	if groundSensor.has_overlapping_bodies() or groundSensor.has_overlapping_areas():
		throttle = 0 
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		animTree2.set("parameters/TimeSeek/seek_request", throttle*3.3333)
		return
	if linear_velocity.y <0.001 and linear_velocity.y > -0.001:
		return
	if linear_velocity.y > 0.0 and throttle > 0:
		throttle = lerpf(throttle, 0, clampf((linear_velocity.y), -0.01, 0.01))
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		animTree2.set("parameters/TimeSeek/seek_request", throttle*3.3333)
		return
	if linear_velocity.y < -0.0:
		throttle = lerpf(throttle, 1, clampf((0-linear_velocity.y), -0.01, 0.01))
		animTree.set("parameters/TimeSeek/seek_request", throttle*5)
		animTree2.set("parameters/TimeSeek/seek_request", throttle*3.3333)

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
	animTree.set("parameters/TimeSeek/seek_request", throttle*5)
	animTree2.set("parameters/TimeSeek/seek_request", throttle*4.1667)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_position = resetPos 
	global_rotation = resetRot
	camParent.rotation = resetCamPRot 
	camera.rotation = resetCamRot
	camera.current = true
	animPlayer.play("RESET")
	desiredAlt = 0
	if enableStatic:
		Static.stop()
		
	for item in cargo:
		item.value = item.savedValue
		
	
	deathMsg.visible = false
	alive = true
	
	VHS.get_material().set_shader_parameter("wiggle", VHSBaseWiggle)
	VHS.get_material().set_shader_parameter("smear",VHSBaseSmear)
	
	glitch.get_material().set_shader_parameter("shake_power", 0.0)
	glitch.get_material().set_shader_parameter("shake_color_rate", 0.0)

func die():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	throttle = 0
	linear_velocity = Vector3.ZERO
	global_position = resetPos 
	global_rotation = resetRot
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
	if !roxchat and !Globals.Tutorial:
		var i = randf()
		print(i)
		if i > 0.6 and throttle == 0:
			roxchat = true
			DialogueManager.show_dialogue_balloon(RoxDialogue, "start")

func openPad():
	pager.show()
	padOn = true

func openManifest():
	list.clear()
	list.index = 0
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
	list.index = 0
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
	if speedChange > 20:
		die()
	
	VHS.get_material().set_shader_parameter("wiggle",clampf((VHSBaseWiggle+round(speedChange/5)/10), VHSBaseWiggle, 1.5))
	VHS.get_material().set_shader_parameter("smear",clampf((VHSBaseSmear+round(speedChange*2)/10), VHSBaseSmear, 2.0))
	
	glitch.get_material().set_shader_parameter("shake_power", round(speedChange/2)/100)
	glitch.get_material().set_shader_parameter("shake_color_rate", round(speedChange/2)/100)
	
	var index = 0
	for item in cargo:
		if !item: return
		item.Damage(speedChange, index)
		index+=1
	


func _on_body_entered(_body):
	if !alive:return
	if abs(lastVel-linear_velocity).length() > impactThreshold:
		impact(abs(lastVel-linear_velocity).length())
	


func save():
	for item in cargo:
		item.savedValue = item.value
	moneySaved = money
	cargoSaved = cargo
	resetPos = global_position + Vector3(0,0.2,0)
	print("saved")
	resetCamPRot = camParent.rotation
	resetCamRot = camera.rotation
	#resetRot = global_rotation
