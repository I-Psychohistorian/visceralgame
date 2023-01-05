extends KinematicBody


onready var flowercrab = preload("res://Entities/FlowerBug.tscn")

var viable = true
var nutrition = 2
var ichor = 1
onready var hatchpoint = $HatchPoint
var spawn_coords = Vector3()

var dead = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if viable == false:
		$yolk.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func take_damage(damage):
	ichor -= damage
	queue_free()

func _on_HatchTime_timeout():
	if viable == true:
		spawn_coords = hatchpoint.global_transform.origin
		$white.visible = false 
		$yolk.visible = false
		var c = flowercrab.instance()
		self.add_child(c)
		c.global_transform.origin = spawn_coords
		c.start_point = spawn_coords
		c.hatched = true
		c.start_size = 0.2
		c.ichor = 2
		c.hunger_num = 0
		c.reparent()
		dead = true
		$DespawnTimer.start()
		#hatch sound
		


func _on_DespawnTimer_timeout():
	pass
	queue_free()
