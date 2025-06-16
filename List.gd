extends ItemList
var active = false
var index = 0
var pager
# Called when the node enters the scene tree for the first time.
func _ready():
	clear()
	pager = get_parent()

	
# Called every frame. 'delta' is the elapsed time since the previous frame.


func selectNext():
	if index == item_count-1:
		return false
	if item_count>index:
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
