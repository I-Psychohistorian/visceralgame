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
var speed = 1
#where target is spawned
var target_vec = Vector3()
var target_seen = false
#wurmyeet, yeets worm
var worm_yeet = Vector3()

var aggro = true

var rotate_degree = 0.03

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

var debug = false
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	worm_yeet = Vector3(0, 0, 0)
	if dead == false:
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
			elif turning_left == true:
				self.rotate_y(rotate_degree)
			elif turning_right == true:
				self.rotate_y(-rotate_degree)
			print('movin')
	



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
	
func choose_move_action():
	#dir_chosen terminates loop to avoid confusion over multiple targets
	var dir_chosen = false
	var sight = sense_range.get_overlapping_bodies()
	for i in sight:
		if i.is_in_group("wurm_target"):
			#i.print_location()
			if dir_chosen == false:
				var t_calc = self.global_transform.origin.x - i.global_transform.origin.x
				print('t_calc is ', t_calc)
				if i.global_transform.origin.x == 0:
					dir_chosen = true
					print('target is at 0')
				elif t_calc <= 0:
					moving_forward = false
					turning_left = true
					turning_right = false
					dir_chosen = true
					$GrossBodyAnimation.play("Left")
				elif t_calc > 0:
					moving_forward = false
					turning_right = true
					turning_left = false
					dir_chosen = true
					$GrossBodyAnimation.play("Right")
				if i.is_in_group('wurm_target'):
					var in_front = forward_gaze.get_overlapping_bodies()
					for b in in_front:
						if b.is_in_group('wurm_target'):
							moving_forward = true
							turning_left = false
							turning_right = false
							dir_chosen = true
							$GrossBodyAnimation.play("Forward")
				#temp till I figure out having animations trigger the boolean toggle
				#moving_at_all = true
				#should work now given exported variable
	print('forward is ', moving_forward, ', left is ', turning_left, ", right is ", turning_right)

func clear_move():
	$GrossBodyAnimation.play("IdlePose")
	moving_at_all = false

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
			print('target aquired, moving')


func _on_Back_body_exited(body):
	#will swap to current_state "Moving"
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
