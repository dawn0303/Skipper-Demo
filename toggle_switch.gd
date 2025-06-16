extends ItemList
var ON : bool
signal state(state : bool)

func setState(State : bool):
	ON = State
	select(!ON)


func _on_item_selected(index: int) -> void:
	ON = !index
	print(ON)
	state.emit(ON)
