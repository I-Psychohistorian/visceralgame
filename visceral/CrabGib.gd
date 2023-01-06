extends RigidBody


var interactable = true
var item_id = 'Crabmeat'
var interact_label = 'Press E to take meat chunk'

var nutrition = 3

var gib_id = 'none'

var wet = false
var in_water = false

var left_water = false

onready var gib1 = $CrabGib1
onready var gib2 = $Crabgib2

onready var drop_coords = Vector3()

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	self.scale = Vector3(0.3,0.3,0.3)
	if gib_id == 'none':
		choose_gib()
	elif gib_id == 'gib1':
		gib1.visible = true
		gib2.visible = false
	elif gib_id == 'gib2':
		gib1.visible = false
		gib2.visible = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_water == true:
		if left_water == true:
			gravity_scale = -0.01
		else:
			gravity_scale = -0.1
	elif in_water == false:
		if left_water == false:
			gravity_scale = 0.01
			left_water = true
		elif left_water == true:
			gravity_scale = 1
			left_water = false

func use():
	var nearby = $Area.get_overlapping_bodies()
	for body in nearby:
		if body.is_in_group("Player"):
			body.holding_item = true
			body.item_nutrition = self.nutrition
			body.item_id = self.item_id
			body.gib_id = gib_id
			body.hud.message = interact_label
			queue_free()

func reparent():
	var new_parent = self.get_parent().get_parent()
	#for ensuring correct parent is one node up, should be plant controller
	#print(new_parent)
	get_parent().remove_child(self)
	new_parent.add_child(self)
	self.global_transform.origin = drop_coords


func choose_gib():
	var choice = rng.randi_range(0, 1)
	if choice == 1:
		gib1.visible = true
		gib2.visible = false
		gib_id = 'gib1'
	elif choice == 0:
		gib1.visible = false
		gib2.visible = true
		gib_id = 'gib2'
