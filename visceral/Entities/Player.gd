extends KinematicBody

var seeding = false

#game stats
var ichor = 60
var stamina = 60
var stamina_max = 0
var points = 0
var claws = 5

onready var hud = $centre/Camera/HUD
onready var animator = $centre/AnimationPlayer
onready var held_seed = $centre/Seed

onready var seedpod = preload("res://Assets/RigidSeed.tscn")

var pollenated = false
var pollen_gamete = []

var holding_item = false
var item_pollinated = false
var item_gamete = []
var item_nutrition = 0
var seed_coord = Vector3()
signal drop_seed

var dead = false
var cinematic_pause = false

#physics variables
var speed = 2.5
var gravity = 1
var jump = 0.5
var direction = Vector3()
var grav_vec = Vector3()

var mouse_sensitivity = 0.03 
onready var head = $centre
onready var fall_line = $GravCast
onready var pointer = $centre/Pointer

onready var clawpollen1 = $centre/Claw/Claw1Pollen
onready var clawpollen2 = $centre/Claw2/Claw2Pollen
var mouse_hide = false

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	toggle_mouse_mode()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_hud()
	interaction()
	direction = Vector3()
	
	if not is_on_floor():
		if not fall_line.is_colliding():
			grav_vec += Vector3.DOWN * gravity * delta
	else:
		grav_vec = -get_floor_normal() * gravity
	if dead == false:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			if stamina >= 10:
				grav_vec = Vector3.UP * jump
				stamina -= 10
		if Input.is_action_pressed("forward"):
			direction -= transform.basis.z
		elif Input.is_action_pressed("backward"):
			direction += transform.basis.z
		if Input.is_action_pressed("left"):
			direction -= transform.basis.x
		elif Input.is_action_pressed("right"):
			direction += transform.basis.x
		if Input.is_action_just_pressed("attack"):
			pass
		if Input.is_action_just_pressed("drop"):
			Right()
		if Input.is_action_just_pressed("eat"):
			Eat()
		if Input.is_action_just_pressed("interact"):
			pass
	if Input.is_action_just_pressed("hide_mouse"):
		toggle_mouse_mode()
	
	direction = direction.normalized()
	direction.y = grav_vec.y
	move_and_slide(direction*speed, Vector3.UP)

func update_hud():
	hud.ichor = ichor
	hud.stamina = stamina
	hud.points = points
	hud.claws = claws
	hud.holding = holding_item

func Left():
	pass
	#if not carrying seed, attack, if carrying seed, can't attack
func Right():
	if holding_item == true:
		holding_item = false
		animator.play("mandibledefault")
		var s = seedpod.instance()
		seed_coord = $centre/Pointer/DebugPointer.global_transform.origin
		self.add_child(s)
		s.global_transform.origin = seed_coord
		s.pollenated = item_pollinated
		s.alleles = item_gamete
		s.nutrition = item_nutrition
		if s.pollenated == true:
			s.get_pollenated()
		s.drop_coords = seed_coord
		s.scale = Vector3(0.15,0.15,0.15)
		s.reparent()
		#pollenation, nutrition, and gamete are needed as info
	#if not carrying seed, nothing, if carrying seed, drop it
func Eat():
	if holding_item == true:
		#eat sound
		holding_item = false
		#eat animation?
		animator.play("mandibledefault")
		ichor += item_nutrition
		
	#if carry seed, eat

func interaction():
	if pointer.is_colliding():
		var pointed_object = pointer.get_collider()
		if pointed_object.is_in_group("Interactable"):
			if pointed_object.interactable == true:
				if pointed_object.item_id == "Seed":
					hud.message = "E to take seed"
					hud.turn_on_interact_text()
					if Input.is_action_just_pressed("interact"):
						if holding_item == false:
							holding_item = true
							item_gamete = pointed_object.alleles
							item_pollinated = pointed_object.pollenated
							item_nutrition = pointed_object.nutrition
							print('Picked up seed, genes are: ', item_gamete, ' pollinated is: ', item_pollinated, ' nutrition is: ', item_nutrition)
							if item_pollinated == true:
								held_seed.show_pollen()
							elif item_pollinated == false:
								held_seed.hide_pollen()
							pointed_object.queue_free()
							animator.play("seedhold")
						elif holding_item == true:
							pass
							#can't take another seed
				elif pointed_object.item_id == "Plant":
					hud.message = "E to munch on plant"
					hud.turn_on_interact_text()
					if Input.is_action_just_pressed("interact"):
						stamina += pointed_object.nutrition
						ichor += pointed_object.nutrition
						pointed_object.release_seed()
						#munch sound?
		elif not pointed_object.is_in_group("Interactable"):
			hud.turn_off_interact_text()
	elif not pointer.is_colliding():
		hud.turn_off_interact_text()
	#e to interact/pickup


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-25), deg2rad(25))

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
		print(pollen_gamete[0])
		body.queue_free()


func _on_StaminaTimer_timeout():
	stamina_max = ichor
	if stamina < stamina_max:
		stamina += 1
