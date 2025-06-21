extends Node

var Tutorial : bool

var tutorialMode : String = ""

var throttleTest : bool
var throttledUp : bool
var throttledDown : bool

var stickTest : bool
var pitchedDown : bool
var pitchedUp : bool
var rolledLeft : bool
var rolledRight : bool

var pedalTest : bool
var yawedLeft : bool
var yawedRight : bool

var terminalUp : bool
var tabChange : bool
var pickUp : bool
var terminalDown : bool
var mapUp: bool

var cargo = []

var contacts = ["Roxy"]
var descriptions = {"Roxy" : """tha COOLEST grl
on tha moon! hmu
if u want cheap
scrap/repairz! 

(dont tell my
boss)
>:3"""}
var padMode = "manifest"
var skipper
