extends KinematicBody

var nutrition = -5

var interactable = true
var item_id = "Spore"
var interact_label = "Press E to take parasitic spore"


var gravity = .5

var speed = .6

var x_speed = 0
var z_speed = 0
var y_speed = 0



var grav_vec = Vector3()
var impulse = Vector3()

var rotation_num = 0
var rng = RandomNumberGenerator.new()

var impulsed = true

var start_coord = Vector3()
var reparented = false

var wet = false
var in_water = false

onready var flingtime = $FlingTimer
var impulse_safety = true

var debug = false


var player_spawned = true
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	

func fling():
	set_impulse()
	impulsed = true
	$FlingTimer.start()

func use():
	var nearby = $player_sight.get_overlapping_bodies()
	for body in nearby:
		if body.is_in_group("Player"):
			body.holding_item = true
			body.item_nutrition = self.nutrition
			body.item_id = self.item_id
			body.hud.message = interact_label
			queue_free()


func set_impulse():
	rng.randomize()
	z_speed = rng.randf_range(1, 2)
	var z_flip = rng.randi_range(1,2)
	if z_flip == 2:
		z_speed = z_speed * -1
		
	x_speed = rng.randf_range(1, 2)
	var x_flip = rng.randi_range(1,2)
	if x_flip == 2:
		x_speed = x_speed * -1
		
	y_speed = rng.randf_range(2, 4)
	#rotation_num = rng.randi_range(0, 360)
	#print("z = ", z_speed, " x = ", x_speed, " rotate = ", rotation_num)
	#rotate_y(deg2rad(rotation_num))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	impulse = Vector3()
	if not is_on_ceiling() and not is_on_floor() and not is_on_wall():
		grav_vec.y -= gravity
	else:
		grav_vec = Vector3()
		if impulse_safety == false:
			impulsed = false
	if impulsed == true:
		impulse.y += y_speed
		impulse.z += z_speed
		impulse.x += x_speed
		#print(y_speed)
	impulse += grav_vec
		
	var direction = self.global_transform.origin - (self.global_transform.origin - impulse)
	#print('direction is ', direction, ' self is ', global_transform.origin, ' impulse is ', impulse)
	if debug == false:
		move_and_slide(direction * speed, Vector3.UP)

func reparent():
		var new_parent = self.get_parent().get_parent()
		#for ensuring correct parent is one node up, should be plant controller
		#print(new_parent)
		get_parent().remove_child(self)
		new_parent.add_child(self)
		self.global_transform.origin = start_coord
		if player_spawned == false:
			fling()
		#print(get_parent())
		

func _on_report_timeout():
	#print('gamete is ', gamete)
	pass


func _on_FlingTimer_timeout():
	impulse_safety = false


func _on_ReparentTimer_timeout():
	reparent()


func _on_debug_timeout():
	print(global_transform.origin)
	if debug == true:
		debug = false
	elif debug == false:
		debug = true
