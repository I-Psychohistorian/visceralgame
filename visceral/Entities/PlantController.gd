extends Spatial


onready var plant = preload("res://Entities/RandomFlower.tscn")
onready var pollen = preload("res://Entities/PollenBall.tscn")
onready var plantseed = preload("res://Assets/RigidSeed.tscn")

var pollen_point = Vector3()
var seed_point = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RigidSeed_sprout():
	pass # Replace with function body.
