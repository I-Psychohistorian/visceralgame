extends KinematicBody


var ichor = 50
var stress = 0
var hungry = false

var sound_type = "meat"

var chlidren_nearby = false
var states = ['Lurking', 'Wandering', 'Attacking', 'Turning', 'Birthing']


#wound shorthand
onready var w1 = $Body/Wound1
onready var w2 = $Body/Wound2
onready var w3 = $Body/Wound3
onready var w4 = $Body/Wound4
onready var w5 = $Body/Wound5
onready var tw6 = $Body/Tail/Wound6
onready var tw7 = $Body/Tail/Wound7
onready var tw8 = $Body/Tail/Wound8
onready var tw9 = $Body/Tail/Wound9
onready var tw10 = $Body/Tail/Wound10
onready var btw11 = $Body/Tail/juveniletail/CSGSphere/Wound11
onready var btw12 = $Body/Tail/juveniletail/CSGSphere/Wound12
onready var w13 = $Body/Wound13
onready var w14 =$Body/Wound14
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
