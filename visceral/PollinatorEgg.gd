extends KinematicBody


onready var flowercrab = preload("res://Entities/FlowerBug.tscn")

#interact variables
var interactable = true
var item_id = "Egg"
var interact_label = "Press E to take egg"

#damage taking variable
var sound_type = "meat"

var gravity = 0
var grav_vec = Vector3()

var viable = true
var nutrition = 2
var ichor = 1
onready var hatchpoint = $HatchPoint
var spawn_coords = Vector3()

var drop_coords = Vector3()
var dead = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$Start_spawn.start()

func check_viable():
	if viable == false:
		$yolk.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on_floor():
		grav_vec.y -= gravity
	elif is_on_floor():
		grav_vec.y = 0
	move_and_slide(grav_vec * delta, Vector3.UP)

func use():
	var nearby = $player_detector.get_overlapping_bodies()
	for body in nearby:
		if body.is_in_group("Player"):
			body.holding_item = true
			body.item_nutrition = self.nutrition
			body.item_id = self.item_id
			body.hud.message = interact_label
			body.viability = viable
			queue_free()

func reparent():
	var new_parent = self.get_parent().get_parent()
	#for ensuring correct parent is one node up, should be plant controller
	#print(new_parent)
	get_parent().remove_child(self)
	new_parent.add_child(self)
	self.global_transform.origin = drop_coords

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


func _on_Start_spawn_timeout():
	gravity = 5
