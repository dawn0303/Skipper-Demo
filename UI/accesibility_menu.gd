extends Control

signal Save
signal Return
@onready var config_
@onready var VHSbutton = $"VBoxContainer/VHS EFFECTS/VHS"
@onready var STATICbutton = $"VBoxContainer/STATIC ANIMATON/Satic"
@onready var VolumeSlider = $VBoxContainer/HSlider
var volume


func _ready() -> void:
	config_ = get_parent().get_parent().get_parent().config_
	VHSbutton.setState(config_.vhs)
	STATICbutton.setState(config_.staticAnimation)
	VolumeSlider.value = config_.volume





func _on_return_pressed() -> void:
	Return.emit()
	VHSbutton.setState(config_.vhs)
	STATICbutton.setState(config_.staticAnimation)


func _on_satic_state(state: bool) -> void:
	config_.staticAnimation = state


func _on_vhs_state(state: bool) -> void:
	config_.vhs = state


func _on_save_pressed() -> void:
	config_.volume = volume
	Save.emit()


func _on_h_slider_value_changed(value: float) -> void:
	volume = value
