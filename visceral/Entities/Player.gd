extends KinematicBody

var seeding = false

#game stats
var ichor = 60
var stamina = 60
var stamina_max = 0
var points = 0
var claws = 5
var hunger = false
var death_type = "blank"

var action_cooldown = false
onready var cooldown_timer = $action_cooldown

onready var hud = $centre/Camera/HUD
onready var animator = $centre/AnimationPlayer
onready var held_seed = $centre/Seed

onready var seedpod = preload("res://Assets/RigidSeed.tscn")

var pollenated = false
var pollen_gamete = []

var holding_item = false
var item_id = "blank"
var item_pollinated = false
var item_gamete = []
var item_nutrition = 0
var seed_coord = Vector3()
signal drop_seed

var dead = false
var cinematic_pause = false

#physics variables
var speed = 2.0
var gravity = 1
var jump = 0.5
var jump_dash = false
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
	handle_death()
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
				if jump_dash == false:
					$Jump_speed_boost.start()
					jump_dash = true
					speed = 3.5
		if Input.is_action_pressed("forward"):
			direction -= transform.basis.z
		elif Input.is_action_pressed("backward"):
			direction += transform.basis.z
		if Input.is_action_pressed("left"):
			direction -= transform.basis.x
		elif Input.is_action_pressed("right"):
			direction += transform.basis.x
		if Input.is_action_just_pressed("attack"):
			if holding_item == false:
				if action_cooldown == false:
					action_cooldown = true
					cooldown_timer.start()
					var targets = $centre/attack_area.get_overlapping_bodies()
					print(targets)
					for target in targets:
						if target.is_in_group('Destructible'):
							target.take_damage(claws)
							if target.is_in_group('Plant'):
								eat_sounds()
							if target.is_in_group('Animal'):
								flesh_damage_sounds()

					animator.play("attack")
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
		hunger = false
		
	#if carry seed, eat

func handle_death():
	if ichor < 0:
		if dead == false:
			toggle_mouse_mode()
		dead = true
		print('you died')

func interaction():
	if pointer.is_colliding():
		var pointed_object = pointer.get_collider()
		if pointed_object.is_in_group("Interactable"):
			if pointed_object.interactable == true:
				hud.message = pointed_object.interact_label
				hud.turn_on_interact_text()
				if Input.is_action_just_pressed("interact"):
					if action_cooldown == false:
						action_cooldown = true
						cooldown_timer.start()
						if holding_item == false:
							pointed_object.use()
							if item_id == "Seed":
								if item_pollinated == true:
									held_seed.show_pollen()
								elif item_pollinated == false:
									held_seed.hide_pollen()
								animator.play("seedhold")
						elif holding_item == true:
							print('Picked up seed, genes are: ', item_gamete, ' pollinated is: ', item_pollinated, ' nutrition is: ', item_nutrition)
		elif not pointed_object.is_in_group("Interactable"):
			hud.turn_off_interact_text()
	elif not pointer.is_colliding():
		hud.turn_off_interact_text()
	#e to interact/pickup

func eat_sounds():
	pass

func hurt_sounds():
	pass
	
func flesh_damage_sounds():
	pass 

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


func _on_HungerTimer_timeout():
	if hunger == false:
		hunger = true
		#update hud to say hungry
		print('hungry')
	elif hunger == true:
		ichor -= 4
		print('starving')


func _on_Jump_speed_boost_timeout():
	jump_dash = false
	speed = 2.0


func _on_action_cooldown_timeout():
	action_cooldown = false



