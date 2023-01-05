extends CSGSphere


onready var room1 = preload("res://Terrain/rooms/LargeDrySky.tscn")

var choice_room = 'blank'
var rng = RandomNumberGenerator.new()
var active = false
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	if active == true:
		add_room()
		#random choice

func add_room():
	var choice = rng.randi_range(1,2)
	if choice > 0:
		choice_room = room1
	var r = choice_room.instance()
	self.add_child(r)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
