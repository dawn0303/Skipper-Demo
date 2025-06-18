extends VBoxContainer
@onready var list: ItemList = $Container/ItemList
var index = 0

func _ready() -> void:
	visible = false

func open():
	list.select(index)

func up():
	if list.selectPrev():
		index -=1

func down():
	if list.selectNext():
		index +=1

func left():
	pass

func right():
	get_parent().get_parent().goTo(list.get_item_text(index))
	

func Hash():
	pass

func star():
	pass
