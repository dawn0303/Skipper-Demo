extends VBoxContainer
@onready var groupList: ItemList = $Container/groupList
@onready var all_groups: Control = $Container/allGroups
@onready var title: Label = $title

var newsgroups = []

var index = 0
var terminal


func _ready() -> void:
	newsgroups = all_groups.get_children()
	visible = false
	terminal = get_parent().get_parent()
	groupList.clear()
	for item in newsgroups:
		groupList.add_item(str(item.total) + "  " + item.groupName)

func open():
	groupList.select(index)

func up():
	if groupList.selectPrev():
		index -=1
	if !groupList.visible:
		newsgroups[index].up()


func down():
	if groupList.selectNext():
		index +=1
	if !groupList.visible:
		newsgroups[index].down()


func left():
	if !groupList.visible and !newsgroups[index].error.visible:
		title.text = """GROUP SELECTION (SOFEnews.su)
---------------------------------------------"""
		newsgroups[index].visible = false
		groupList.visible = true
	elif groupList.visible and !newsgroups[index].error.visible:
		get_parent().get_parent().goHome()
	else:
		newsgroups[index].left()

func right():
	if groupList.visible:
		title.text = "["+str(newsgroups[index].unread)+"/"+str(newsgroups[index].total)+" Unread    "+newsgroups[index].groupName +"\n---------------------------------------------"
		groupList.visible = false
		newsgroups[index].visible = true
	else:
		newsgroups[index].right()

func Hash():
	pass

func star():
	pass
