extends Node3D

@onready var Options = $CanvasLayer
@onready var map = $SubViewportContainer
@onready var Skipper = $Skipper
@onready var vhs = $CanvasLayer/vhs
@export var pad_1: StaticBody3D 
@export var hidden :Array[RigidBody3D]
var config_ 
var menuOpen = false
var world 



func _enter_tree() -> void:
	load_()
	Globals.Tutorial = config_.TutorialOnLaunch
func _ready() -> void:
	return
	#test_()


func save_ ():
	for action in InputMap.get_actions():
		config_.input_map[action] = InputMap.action_get_events(action)
	ResourceSaver.save(config_, "user://config.tres")
	Skipper.updateSettings()
	vhs.visible = config_.vhs

func load_():
	config_ = load("user://config.tres")
	if not config_:
		config_ = Config.new()
		config_.TutorialOnLaunch = true
	for action in config_.input_map:
		InputMap.action_erase_events(action)
		for input_event in config_.input_map[action]:
			InputMap.action_add_event(action, input_event)


func _input(event):
	#if event is InputEventKey and Input.is_action_just_pressed("options menu"):
	#	MenuToggle()
		
	if event is InputEventKey and Input.is_action_just_pressed("map"):
		map.visible = !map.visible

func MenuToggle():
	vhs.visible = config_.vhs
	Options.visible = !Options.visible
	menuOpen = !menuOpen
	get_tree().paused = !get_tree().paused

func test_():
	config_.volume = 0.5
	save_()
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func unHide():
	for item in hidden:
		item.reparent(pad_1)
		item.reReady()
		pad_1.newItems()
