extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_deleter_body_entered(body):
	if body.is_in_group('Player'):
		body.take_damage(9999)
	else:
		print(body, " fell through the world and was deleted")
		body.queue_free()
	


func _on_deleter2_body_entered(body):
	if body.is_in_group('Player'):
		body.take_damage(9999)
	else:
		print(body, " fell through the world and was deleted")
		body.queue_free()
