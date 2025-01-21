extends Control
var world
@onready var List = $Main/ItemList
@onready var Main = $Main
@onready var Remap = $Remap
@onready var Acces = $AccesibilityMenu
func _ready() -> void:
	world = get_parent().get_parent()


func _on_button_pressed() -> void:
	world.save_()
	get_tree().quit()

func return_():
	Remap.visible = false
	Main.visible = true
	Acces.visible = false

func _on_item_list_item_activated(index: int) -> void:
	navigate(index)


func _on_save() -> void:
	world.save_()

func _input(event):
	if event is InputEventKey and Input.is_action_just_pressed("options menu"):
		return_()
		world.MenuToggle()

func _on_return() -> void:
	return_()


func _on_button_2_pressed() -> void:
	world.MenuToggle()


func _on_item_list_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	navigate(index)
	List.deselect(index)

func navigate(index):
	match index:
		0:
			Main.visible = false
			Remap.visible = true
		1:
			Main.visible = false
			Acces.visible = true
