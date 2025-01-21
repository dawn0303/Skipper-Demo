extends Node3D

@onready var Options = $CanvasLayer
@onready var map = $SubViewportContainer
@onready var Skipper = $Skipper

var config_ 
var menuOpen = false
var world 

func _enter_tree() -> void:
	load_()
func _ready() -> void:
	return
	#test_()


func save_ ():
	for action in InputMap.get_actions():
		config_.input_map[action] = InputMap.action_get_events(action)
	ResourceSaver.save(config_, "user://config.tres")
	Skipper.updateSettings()
	

func load_():
	config_ = load("user://config.tres")
	if not config_:
		config_ = Config.new()
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
	Options.visible = !Options.visible
	menuOpen = !menuOpen
	get_tree().paused = !get_tree().paused

func test_():
	config_.volume = 0.5
	save_()
	OS.shell_open(ProjectSettings.globalize_path("user://"))
