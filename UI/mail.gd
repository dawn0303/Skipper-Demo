extends VBoxContainer
@onready var mailList: ItemList = $Container/MailList
@onready var all_mail: Control = $Container/allMail
@onready var title: Label = $title
#@onready var rich_text_label: RichTextLabel = $Container/allMail/RichTextLabel
var mail = []
@onready var navigation: Label = $navigation

var index = 0
var terminal
var current_line = 0

func _ready() -> void:
	mail = all_mail.get_children()
	visible = false
	terminal = get_parent().get_parent()
	mailList.clear()
	for item in mail:
		mailList.add_item(item.fromShort + " - " + item.Title)

func open():
	mailList.select(index)

func up():
	if mailList.visible and mailList.selectPrev():
		index -=1
	if !mailList.visible and current_line != 0:
		mail[index].scroll_to_line(current_line-1)
		current_line-=1


func down():
	if mailList.visible and mailList.selectNext():
		index +=1
	if !mailList.visible and current_line < mail[index].get_line_count()-21:
		mail[index].scroll_to_line(current_line+1)
		current_line+=1


func left():
	if !mailList.visible:
		navigation.text = "<BACK                                   >READ"
		title.text = "\n                Network Mail"
		mail[index].visible = false
		mail[index].scroll_to_line(0)
		mailList.visible = true
		current_line = 0
	else:
		get_parent().get_parent().goHome()

func right():
	if mailList.visible:
		title.text = "FROM: " + mail[index].from + "\nTO: " + mail[index].to
		if mail[index].Title == "DELIVERY REQUEST":
			navigation.text = "<BACK                                 #ACCEPT"
		else:
			navigation.text = "<BACK                                         "
		mailList.visible = false
		mail[index].visible = true

func Hash():
	print("1")
	if mail[index].Title == "DELIVERY REQUEST" and !mailList.visible:
		print("2")
		mail[index].interact()

func star():
	pass
