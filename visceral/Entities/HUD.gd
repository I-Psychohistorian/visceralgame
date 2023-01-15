extends CanvasLayer


var ichor = 0
var stamina = 0
var points = 0
var claws = 0

var holding = false
var message = "nothing"
var death_message = "You are dead!"

var hunger_message = "Not hungry"
var interact_viewable = false

onready var interact_text = $Centre/Interact
onready var flavor_text = $Centre/Text

onready var health_text = $HUD_info/Ichor
onready var stamina_text = $HUD_info/Stamina
onready var misc_text = $HUD_info/Misc
onready var hunger_text = $HUD_info/Hunger

onready var notif =$Notification/Notification_label
var notif_on = true # does nothing yet
var notif_n = ' '
onready var notif_int = $Notification/Number
var notif_text = 'notification'

onready var menu = $Menu
var menu_seen = false



# Called when the node enters the scene tree for the first time.
func _ready():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	#pass # Replace with function body.

func toggle_menu():
	if menu_seen == false:
		menu_seen = true
		menu.show()
	elif menu_seen == true:
		menu_seen = false
		menu.hide()


func notif_ping():
	notif_int.text = notif_n
	notif.text = notif_text
	notif.show()
	notif_int.show()
	$notif_time.start()

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
	hunger_text.text = hunger_message


func _on_Exit_pressed():
	get_tree().quit()


func _on_notif_time_timeout():
	notif.hide()
	notif_int.hide()
	notif_n = ' '


func _on_Restart_pressed():
	get_tree().change_scene("res://Levels/DemoLevel.tscn")
