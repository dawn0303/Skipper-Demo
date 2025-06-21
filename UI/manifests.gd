extends VBoxContainer
@onready var List = $Container/ItemList
@onready var top = $Top
@onready var bottom = $Bottom
@onready var extra = $HBoxContainer/Extra
@onready var extra2 = $HBoxContainer/Extra2
var terminal

func _ready() -> void:
	visible = false


func open():
		match Globals.padMode:
			"manifest":
				openManifest()
				Globals.padMode="manifest"
			"depot":
				openDepotManifest()
				Globals.padMode="depot"

func up():
	if List.selectPrev():
		match Globals.padMode:
			"manifest":
				if Globals.cargo.size() > 0:
					top.text = "VALUE: "+ str(Globals.cargo[List.index].value)
					bottom.text = "DELIVER TO: "+ str(Globals.cargo[List.index].Destination.Name)
			"depot":
				if Globals.skipper.lastPad.outgoing.size() > 0:
					top.text = "VALUE: "+ str(Globals.skipper.lastPad.outgoing[List.index].value)
					bottom.text = "DELIVER TO: "+ str(Globals.skipper.lastPad.outgoing[List.index].Destination.Name)

func down():
	if List.selectNext():
		match Globals.padMode:
			"manifest":
				if Globals.cargo.size() > 0:
					top.text = "VALUE: "+ str(Globals.cargo[List.index].value)
					bottom.text = "DELIVER TO: "+ str(Globals.cargo[List.index].Destination.Name)
			"depot":
				if Globals.skipper.lastPad.outgoing.size() > 0:
					top.text = "VALUE: "+ str(Globals.skipper.lastPad.outgoing[List.index].value)
					bottom.text = "DELIVER TO: "+ str(Globals.skipper.lastPad.outgoing[List.index].Destination.Name)

func left():
	get_parent().get_parent().goHome();
	


func right():
	match Globals.padMode:
		"manifest":
			openDepotManifest()
			Globals.padMode="depot"
		"depot":
			openManifest()
			Globals.padMode="manifest"

func Hash():
	match Globals.padMode:
		"manifest":
			Globals.skipper.sellCargo(List.index)
		"depot":
			Globals.skipper.getCargo(List.index)

func openManifest():
	List.clear()
	List.index = 0
	top.text = "NO CARGO"
	bottom.text ="RETURN TO DEPOT"
	extra.text = "SHIP"
	extra2.text = "DEPOT>"
	if Globals.cargo.size() > 0:
		top.text = "VALUE: "+ str(Globals.cargo[List.index].value)
		bottom.text = "DELIVER TO: "+ str(Globals.cargo[List.index].Destination.Name)
	if Globals.cargo.size() == 0:
		return
	for item in Globals.cargo:
		List.add_item(item.Name)
	List.select(List.index)

func openDepotManifest():
	List.clear()
	List.index = 0
	top.text = "DEPOT EMPTY"
	bottom.text ="NEXT DELIVERY"
	extra.text = "DEPOT"
	extra2.text = "SHIP>"
	if Globals.skipper.lastPad.outgoing.size() > 0:
		top.text = "VALUE: "+ str(Globals.skipper.lastPad.outgoing[List.index].value)
		bottom.text = "DELIVER TO: "+ str(Globals.skipper.lastPad.outgoing[List.index].Destination.Name)
	if Globals.skipper.lastPad.outgoing.size() == 0:
		return
	for item in Globals.skipper.lastPad.outgoing:
		List.add_item(item.Name)
	List.select(List.index)
