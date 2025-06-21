extends VBoxContainer
@onready var posts: ItemList = $Container/posts
@onready var error: Label = $Container/ERROR

@export var groupName : String
@export var unread : int
@export var total : int

var index = 0
var groupList


func _ready() -> void:

	visible = false
	groupList = get_parent().get_parent().get_parent()
	posts.select(index)
	

func open():
	pass

func up():
	if posts.selectPrev():
		index -=1


func down():
	if posts.selectNext():
		index +=1


func left():
	if error.visible:
		error.visible = false
		posts.visible = true
	else:
		visible = false
		groupList.groupList.visible = true

func right():
	if !error.visible and index != posts.item_count-1:
		posts.visible = false
		error.visible = true

func Hash():
	pass

func star():
	pass
