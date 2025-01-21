extends Control
var world

signal Save
signal Return





func _Save_Button_Pressed() -> void:
	Save.emit()



func _on_return_pressed() -> void:
	Return.emit()
