extends Control
@onready var description: Label = $PanelContainer/MarginContainer/Description
@onready var portrait: TextureRect = $PanelContainer2/portrait
@onready var contactName: Label = $Name


var contact : String = "error"

func _ready() -> void:
	visible = false

func open():
	contactName.text = contact
	if Globals.descriptions.has(contact):
		description.text = Globals.descriptions[contact]
	else:
		description.text = "No Description"
	
	var portrait_path: String = "res://UI/characterPortraits/%s.png" %contact
	if ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
	else:
		portrait.texture = load("res://UI/characterPortraits/unknown.png")
	
	

func up():
	pass

func down():
	pass

func left():
	get_parent().get_parent().goTo("CONTACTS")

func right():
	pass
	

func Hash():
	pass

func star():
	pass
