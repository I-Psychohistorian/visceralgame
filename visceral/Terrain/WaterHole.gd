extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_WaterHole_body_entered(body):
	if body.is_in_group("Player"):
		body.wash_pollen()
	if body.is_in_group("SmallBug"):
		body.wash_pollen()
	if body.is_in_group("Buoyant"):
		body.in_water = true
		body.wet = true


func _on_WaterEffectTimer_timeout():
	var bodies = self.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Buoyant"):
			pass



func _on_WaterHole_body_exited(body):
	if body.is_in_group("Buoyant"):
		body.in_water = false
