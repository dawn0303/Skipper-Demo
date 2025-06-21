extends Control
@onready var manifests: VBoxContainer = $VBoxContainer/manifests
@onready var home: VBoxContainer = $VBoxContainer/home
@onready var contacts: VBoxContainer = $VBoxContainer/Contacts
@onready var comms_page: Control = $"VBoxContainer/Comms page"
@onready var LoadAnim: AnimatedSprite2D = $AnimatedSprite2D
@onready var map: Control = $VBoxContainer/Map
@onready var usenet: VBoxContainer = $VBoxContainer/UseNet
@onready var mail: VBoxContainer = $VBoxContainer/Mail

var Active
var page={}

# Called when the node enters the scene tree for the first time.
func _ready():
	Active = home
	page["MANIFESTS"] = manifests
	page["CONTACTS"] = contacts
	page["MAP"] = map
	page["USENET"] = usenet
	page["MAIL"] = mail
	for item in page:
		if item != "HOME" or item != "COMMS":
			home.list.add_item(item)
	page["HOME"] = home
	page["COMMS"] = comms_page
		

func goHome():
	Active.visible = false
	Active=home
	home.open()
	LoadAnim.play_backwards("Load")
	Active.visible = true

func goTo(desiredPage:String, loadScreen = true):
	Active.visible = false
	Active=page[desiredPage]
	Active.open()
	if loadScreen:
		LoadAnim.play_backwards("Load")
	Active.visible = true
