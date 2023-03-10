extends KinematicBody

#FOR FLIES
var nutrition = 1

var seeding = false

var gravity = 2

var x_speed = 2
var z_speed = 2
var y_speed = 5

var grav_vec = Vector3()
var impulse = Vector3()

var rotation_num = 0
var rng = RandomNumberGenerator.new()

var gamete = []
var impulsed = true

var start_coord = Vector3()
var reparented = false

var wet = false
var in_water = false
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	set_impulse()
	impulsed = true

func set_impulse():
	rng.randomize()
	z_speed = rng.randf_range(1, 1.5)
	var z_flip = rng.randi_range(1,2)
	if z_flip == 2:
		z_speed = z_speed * -1
		#print('z neg')
	x_speed = rng.randf_range(1, 1.5)
	var x_flip = rng.randi_range(1,2)
	if x_flip == 2:
		x_speed = x_speed * -1
		#print('x neg')
	y_speed = rng.randf_range(2.5, 3.0)
	rotation_num = rng.randi_range(0, 360)
	#print("z = ", z_speed, " y = ", y_speed, " rotate = ", rotation_num)
	rotate_y(deg2rad(rotation_num))

func decrease_impulse():
	if impulsed == true:
		if z_speed > 0:
			z_speed -= 0.1
		if x_speed > 0:
			x_speed -= 0.1
		if y_speed > 0:
			y_speed -= 0.1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	impulse = Vector3()
	if impulsed == true:
		if not is_on_floor():
			impulse.y -= gravity
		elif is_on_floor():
			y_speed = 0
			z_speed = 0
			x_speed = 0
			#gravity = 0
			impulsed = false
			if reparented == false:
				reparent()
				#print('reparented')
				reparented = true
		impulse.y += y_speed
		impulse.z += z_speed
		impulse.x += x_speed
		decrease_impulse()
	if in_water == true:
			impulse.y += 0.1
	move_and_slide(impulse, Vector3.UP)

func reparent():
		start_coord = self.global_transform.origin
		var new_parent = self.get_parent().get_parent().get_parent()
		#for ensuring correct parent is one node up, should be plant controller
		#print(new_parent)
		get_parent().remove_child(self)
		new_parent.add_child(self)
		#print(get_parent())
		self.global_transform.origin = start_coord

func _on_report_timeout():
	#print('gamete is ', gamete)
	if impulsed == true:
		impulsed = false
	elif impulsed == false:
		impulsed = true
