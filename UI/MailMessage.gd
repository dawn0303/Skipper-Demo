extends RichTextLabel
@export var from : String
@export var fromShort : String
@export var to : String
@export var Title : String
var SYSTEM_MESSAGES = load("res://Dialogue/system Messages.dialogue")
var interacted = false


func _ready() -> void:
	visible = false

func interact():
	if interacted:
		return
	interacted = true
	get_tree().root.get_child(2).unHide()
	DialogueManager.show_dialogue_balloon(SYSTEM_MESSAGES, "NewItem")
	print("interacted")
