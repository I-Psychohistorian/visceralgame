extends KinematicBody

var gravity = 6
var grav_vec = Vector3()

#interact variables
var interactable = true
var item_id = "Rock"
var interact_label = "Press E to pick up rock"

var falling = false

var drop_coords = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = Vector3(0.8, 0.8, 0.8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on_floor():
		falling = true
		grav_vec.y -= gravity
	elif is_on_floor():
		falling = false
		grav_vec.y = 0
	move_and_slide(grav_vec * gravity * delta, Vector3.UP)

func use():
	var nearby = $Area.get_overlapping_bodies()
	for body in nearby:
		if body.is_in_group("Player"):
			body.holding_item = true
			body.item_id = self.item_id
			body.hud.message = interact_label
			queue_free()

func reparent():
	var new_parent = self.get_parent().get_parent()
	#for ensuring correct parent is one node up, should be plant controller
	#print(new_parent)
	get_parent().remove_child(self)
	new_parent.add_child(self)
	self.global_transform.origin = drop_coords


func _on_hurtzone_body_entered(body):
	if falling == true:
		if body.is_in_group('Destructible'):
				body.take_damage(10)
				print('rock crush!')
		if body.is_in_group('Spore'):
			body.queue_free()
			print('crushed spore')
