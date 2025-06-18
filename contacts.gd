extends VBoxContainer
@onready var list: ItemList = $Container/ItemList
@onready var portrait: TextureRect = $Container/portrait

var index = 0
var terminal


func _ready() -> void:
	visible = false
	terminal = get_parent().get_parent()

func open():
	list.clear()
	for item in Globals.contacts:
			list.add_item(item)
	list.select(index)
	var portrait_path: String = "res://UI/character portraits/%s.png" %Globals.contacts[index]
	if FileAccess.file_exists(portrait_path):
		portrait.texture = load(portrait_path)
	else:
		portrait.texture = load("res://UI/character portraits/unknown.png")
	#if list.get_selected_items() == null:
	#	list.select(0)

func up():
	if list.selectPrev():
		index -=1
		var portrait_path: String = "res://UI/character portraits/%s.png" %Globals.contacts[index]
		if FileAccess.file_exists(portrait_path):
			portrait.texture = load(portrait_path)
		else:
			portrait.texture = load("res://UI/character portraits/unknown.png")

func down():
	if list.selectNext():
		index +=1
		var portrait_path: String = "res://UI/character portraits/%s.png" %Globals.contacts[index]
		if FileAccess.file_exists(portrait_path):
			portrait.texture = load(portrait_path)
		else:
			portrait.texture = load("res://UI/character portraits/unknown.png")

func left():
	get_parent().get_parent().goHome()

func right():
	terminal.comms_page.contact = Globals.contacts[index]
	terminal.goTo("COMMS")

func Hash():
	pass

func star():
	pass
