extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var mist = $skymist

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	mist.rotate_y(deg2rad(2))


func _on_deleter_body_entered(body):
	body.queue_free()
