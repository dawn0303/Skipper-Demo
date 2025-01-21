extends ItemList
var ON : bool
signal state(state : bool)

func setState(state : bool):
	ON = state
	select(!ON)


func _on_item_selected(index: int) -> void:
	ON = !index
	print(ON)
	state.emit(ON)
