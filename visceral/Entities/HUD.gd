extends CanvasLayer


var ichor = 0
var stamina = 0
var points = 0
var claws = 0

var holding = false
var message = "nothing"
var death_message = "You are dead!"

var interact_viewable = false

onready var interact_text = $Centre/Interact
onready var flavor_text = $Centre/Text

onready var health_text = $HUD_info/Ichor
onready var stamina_text = $HUD_info/Stamina
onready var misc_text = $HUD_info/Misc
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func turn_on_interact_text():
	interact_text.show()
	interact_viewable = true

		
func turn_off_interact_text():
	interact_text.hide()
	interact_viewable = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_text.text = "Ichor: " + String(ichor)
	stamina_text.text = "Stamina: " + String(stamina)
	interact_text.text = String(message)
