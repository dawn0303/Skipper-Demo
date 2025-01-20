extends Control
var world
@onready var Main = $Main
@onready var Remap = $Remap
func _ready() -> void:
	world = get_parent().get_parent()


func _on_button_pressed() -> void:
	world.save_()
	get_tree().quit()

func return_():
	Remap.visible = false
	Main.visible = true

func _on_item_list_item_activated(index: int) -> void:
	match index:
		0:
			Main.visible = false
			Remap.visible = true
			


func _on_remap_save() -> void:
	world.save_()


func _on_remap_return() -> void:
	return_()
