extends KinematicBody


var ichor = 50
var stress = 0
var hungry = false
var dead = false

var sound_type = "meat"

var chlidren_nearby = false
var states = ['Lurking', 'Moving', 'Attacking', 'Turning', 'Birthing']
var current_state = 'Moving'

#movement
var gravity = 5
var grav_vec = Vector3()
var speed = 1 #1
#where target is spawned
var target_vec = Vector3()
var target_seen = false
#wurmyeet, yeets worm
var worm_yeet = Vector3()

var aggro = true

var quadrant = 0

var random_turn_set = false
var choice = 0


var rotate_degree = 0.03 #0.03
var immediate_look = false

export var moving_at_all = false

var moving_forward = false
var turning_left = false
var turning_right = false
var climbing = false


onready var carrot = $Carrot
onready var point = Vector3()

onready var last_seen = preload("res://Entities/signal emitters/Wurm_target.tscn")

#gaze stuff
onready var sense_range = $Sight
onready var nearby = $CloseRange
onready var tongue_target_area = $OptimalEat

onready var forward_gaze = $FacingAreas/Facing
onready var backwards_turn_line

var in_left = false
var in_right = false
var facing_target = false

var tongue_target = Vector3()

#wound shorthand
onready var w1 = $Body/Wound1
onready var w2 = $Body/Wound2
onready var w3 = $Body/Wound3
onready var w4 = $Body/Wound4
onready var w5 = $Body/Wound5
onready var tw6 = $Body/Tail/Wound6
onready var tw7 = $Body/Tail/Wound7
onready var tw8 = $Body/Tail/Wound8
onready var tw9 = $Body/Tail/Wound9
onready var tw10 = $Body/Tail/Wound10
onready var btw11 = $Body/Tail/juveniletail/CSGSphere/Wound11
onready var btw12 = $Body/Tail/juveniletail/CSGSphere/Wound12
onready var w13 = $Body/Wound13
onready var w14 =$Body/Wound14
# Called when the node enters the scene tree for the first time.

var rng = RandomNumberGenerator.new()

var debug = false
func _ready():
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	worm_yeet = Vector3(0, 0, 0)
	if dead == false:
		pass
		determine_rotation_quad()
		movement()
		#movement
		
	#gravity
	if not is_on_floor():
		worm_yeet.y -= gravity
	move_and_slide(worm_yeet, Vector3.UP)
		#print(self.global_transform.origin)
	
	
	#fixed yeeting problem, move and slide does not require global_transform by default for falling it is already implied


func movement():
	if current_state == 'Moving':
		if moving_at_all == true:
			if moving_forward == true:
				var move = Vector3()
				point = carrot.global_transform.origin
				move = point - self.global_transform.origin
				move_and_slide(move * speed, Vector3.UP)
			elif immediate_look == true:
				look_at(target_vec, Vector3.UP)
				print('looking snap')
				rotation.x = clamp(rotation.x, deg2rad(0), deg2rad(0))
				rotation.z = clamp(rotation.x, deg2rad(0), deg2rad(0))
				immediate_look = false
			elif turning_left == true:
				self.rotate_y(rotate_degree)
			elif turning_right == true:
				self.rotate_y(-rotate_degree)

			#print('movin')
	



func scan():
	var sight = sense_range.get_overlapping_bodies()
	if target_seen == false:
		for thing in sight:
			if thing.is_in_group('Parasite'):
				set_target(thing)
				target_seen = true
			elif thing.is_in_group('Prey'):
				set_target(thing)
				target_seen = true

func set_target(target):
	target_vec = target.global_transform.origin
	var l = last_seen.instance()
	self.add_child(l)
	l.drop_coords = target_vec
	l.reparent()

#left is really just counterclockwise and right is clockwise
#i made the mistake of naming them left early on and now am too lazy to change it

func set_turn_left():
	$GrossBodyAnimation.play("Left")
	turning_left = true
	turning_right = false
	moving_forward = false
	#print('counterclockwise')
	
func set_turn_right():
	$GrossBodyAnimation.play("Right")
	turning_left = false
	turning_right = true
	moving_forward = false
	#print('clockwise')

func determine_rotation_quad():
	if rad2deg(self.rotation.y) >= 0: 
		quadrant = 1

		if rad2deg(self.rotation.y) > 90:
			quadrant = 2

	elif rad2deg(self.rotation.y) < 0:
			quadrant = -2

			if rad2deg(self.rotation.y) < -90:
				quadrant = -1

	
	#godot rotation coords work in 180 to -180 not 360

func check_quads():
	print('rotation is ', String(rad2deg(self.rotation.y)))
	if quadrant == 1:
		print('fquad1')
	elif quadrant == 2:
		print('fquad2')
	elif quadrant == -2:
		print('fquad-2')
	elif quadrant == -1:
		print('fquad-1')

func get_abs(num):
	if num < 0:
		num * -1
	elif num > 0:
		pass
	return

func choose_move_action():
	#dir_chosen terminates loop to avoid confusion over multiple targets
	var dir_chosen = false
	var sight = sense_range.get_overlapping_bodies()
	for i in sight:
		if i.is_in_group("wurm_target"):
			#i.print_location()
			if dir_chosen == false:
				var t_calc_x =  i.global_transform.origin.x - self.global_transform.origin.x
				var t_calc_z =  i.global_transform.origin.z - self.global_transform.origin.z
				var target_quadrant = 0
				#print("x, z ", t_calc_x, t_calc_z)
				#print('t_calc', ' x = ', t_calc_x, ' z = ', t_calc_z)
				if i.global_transform.origin.x == 0:
					dir_chosen = true
					print('target is at 0')
				elif t_calc_x <= 0:
					if t_calc_z <=0:
						target_quadrant = 1
						#0 to 90 deg
					elif t_calc_z > 0:
						target_quadrant = 2
						#91 to 180 deg
				elif t_calc_x > 0:
					if t_calc_z > 0:
						target_quadrant = -1
						#180 to 270 deg
					elif t_calc_z <= 0:
						target_quadrant = -2
						#270 to 360 deg
				print('face quad= ', quadrant, ' targ quad= ', target_quadrant)
				
				if quadrant + target_quadrant == 0:
					if random_turn_set == false:
						choice = rng.randi_range(0,1)
						random_turn_set = true
					if choice == 1:
						set_turn_left()
					elif choice == 0:
						set_turn_right()
					#print('opposing quadrants')
				elif quadrant == target_quadrant:
					#print('same quadrant')
					$GrossBodyAnimation.play("Forward")
					moving_forward = false
					immediate_look = true
				elif quadrant == 1:
					if quadrant > target_quadrant:
						set_turn_left()
					elif quadrant < target_quadrant: 
						set_turn_right()
					#print('adjacent quadrant')
				elif quadrant == 2:
					if target_quadrant > 0:
						set_turn_right()
					elif target_quadrant < 0:
						set_turn_left()
					#print('adjacent quadrant')
				elif quadrant == -1:
					if target_quadrant > 0:
						set_turn_right()
					elif target_quadrant < 0:
						set_turn_left()
					#print('adjacent quadrant')
				elif quadrant == -2:
					if target_quadrant > 0:
						set_turn_left()
					elif target_quadrant < 0:
						set_turn_right()
					#print('adjacent quadrant')
				if quadrant + target_quadrant != 0:
					print('random turn reset')
					random_turn_set = false
				dir_chosen = true

				if i.is_in_group('wurm_target'):
					var in_front = forward_gaze.get_overlapping_bodies()
					for b in in_front:
						if b.is_in_group('wurm_target'):
							moving_forward = true
							turning_left = false
							turning_right = false
							dir_chosen = true
							$GrossBodyAnimation.play("Forward")
							print('in front of')
				#temp till I figure out having animations trigger the boolean toggle
				#moving_at_all = true
				#should work now given exported variable, thanks boris
	#print('forward is ', moving_forward, ', left is ', turning_left, ", right is ", turning_right)

func clear_move():
	$GrossBodyAnimation.play("IdlePose")
	moving_at_all = false
	immediate_look = false

func toggle_moving():
	if moving_at_all == false:
		moving_at_all = true
	elif moving_at_all == true:
		moving_at_all = false
	print('movement toggled ', moving_at_all)

func _on_scan_delay_timeout():
	clear_move()
	target_seen = false
	scan()
	$scan_delay/movechoose.start()


func _on_OptimalEat_body_entered(body):
	pass # Replace with function body.




func _on_Sight_body_entered(body):
	pass
	#print(body)


func _on_movechoose_timeout():
	if current_state == "Moving":
		choose_move_action()

#keeps wurm from spinning endlessly
func _on_Facing_body_entered(body):
	#will swap to current_state "Moving
	if current_state == "Moving":
		if body.is_in_group('wurm_target'):
			turning_right = false
			turning_left = false
			moving_forward = true
			$GrossBodyAnimation.play("Forward")
			#print('target aquired, moving')


func _on_Back_body_exited(body):
	#will swap to current_state "Moving"
	#set to not monitering as turning calculations have been modified
	if current_state == "Moving":
		if body.is_in_group('wurm_target'):
			if turning_right == true:
				turning_right = false
				turning_left = true
				$GrossBodyAnimation.play("Left")
			elif turning_left == false:
				turning_right = true
				turning_left = false
				$GrossBodyAnimation.play("Right")
			print('turning flipped')
			


func _on_Debug_timeout():
	if debug == false:
		debug = true
	elif debug == true:
		debug = false
	#print(worm_yeet)
	#check_quads()
	#checks current facing quadrant
