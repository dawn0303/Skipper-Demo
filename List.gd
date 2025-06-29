extends ItemList
var active = false
var index = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass#clear()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.


func selectNext():
	if index == item_count-1:
		return false
	if item_count>index and is_item_selectable(index+1):
		select(index+1)
		index+=1
		ensure_current_is_visible ( )
		return true

func selectPrev():
	if item_count == 0:
		return
	if index == 0:
		select(0)
		return false
	select(index-1)
	index-=1
	ensure_current_is_visible ( )
	return true
