extends KinematicBody

#game stats
var ichor = 10
var claws = 5

var pollenated = false
var pollen_gamete = []
var holding_item = false
var item = []
var item_gamete = []

var dead = false
var cinematic_pause = false

#physics variables
var speed = 3
var gravity = 1
var jump = 0.5
var direction = Vector3()
var grav_vec = Vector3()

var mouse_sensitivity = 0.03 
onready var head = $centre
onready var fall_line = $GravCast

onready var clawpollen1 = $centre/Claw/Claw1Pollen
onready var clawpollen2 = $centre/Claw2/Claw2Pollen
var mouse_hide = false

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	toggle_mouse_mode()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	direction = Vector3()
	
	if not is_on_floor():
		if not fall_line.is_colliding():
			grav_vec += Vector3.DOWN * gravity * delta
	else:
		grav_vec = -get_floor_normal() * gravity
	if Input.is_action_just_pressed("jump") and is_on_floor():
		grav_vec = Vector3.UP * jump
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	elif Input.is_action_pressed("backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
	if Input.is_action_just_pressed("hide_mouse"):
		toggle_mouse_mode()
	
	direction = direction.normalized()
	direction.y = grav_vec.y
	move_and_slide(direction*speed, Vector3.UP)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func wash_pollen():
	print('washed off pollen: ', pollen_gamete)
	pollen_gamete = []
	print('current pollen is:' , pollen_gamete)
	clawpollen1.visible = false
	clawpollen2.visible = false
	pollenated = false

func toggle_mouse_mode():
	if mouse_hide == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouse_hide = true
	elif mouse_hide == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_hide = false


func _on_PollenTouch_body_entered(body):
	if body.is_in_group("Pollen"):
		pollenated = true
		pollen_gamete = body.gamete
		rng.randomize()
		var arm = rng.randi_range(1,2)
		if arm == 1:
			clawpollen1.visible = true
		elif arm == 2:
			clawpollen2.visible = true
		print("Current pollen allele on player is: ", pollen_gamete)
		body.queue_free()
