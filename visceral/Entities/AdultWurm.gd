extends KinematicBody

var max_ichor = 50
var ichor = 50
var injured = false
var parasitized = false
#primarily for sounds, but also for give up
var hurt = false

var damage = 15
var stress = 0
var hungry = true
var killed_twice = false
var food_eaten = 0
var fertile = false
var dead = false

var sound_type = "meat"

var children_nearby = false
var states = ['Lurking', 'Moving', 'Attacking', 'Turning', 'Birthing']
var current_state = 'Lurking'

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
var hiding = true

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

var mouth_closed = true
var tongue_safety = true
var stab = false
var next_stab = true #capacity to stab again if stationary
var tongue_target = Vector3()
onready var tongue = $TongueCollide
onready var crab = $TongueCollide/Spike/CrabBody

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

# w1,w2,w3,w4,w5,tw6,tw7,tw8,tw9,tw10,btw11,btw12,w13,w14
onready var behind_tail = $WalkBehind
var retreat_time_set = false
var gaveup = false
var retreat_coords_temp = Vector3()

#will check collisions so that wurm can vomit babies
onready var birthray = $BirthCast

var rng = RandomNumberGenerator.new()

var debug = false
func _ready():
	rng.randomize()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	worm_yeet = Vector3(0, 0, 0)
	if dead == false:
		if aggro == true:
			if current_state != "Lurking":
				if retreat_time_set == false:
					retreat_time_set = true
					$Give_up.start()
		if target_seen == false:
			current_state = states[0]
		determine_rotation_quad()
		movement()
		if tongue_safety == false:
			tongue_aim()
		determine_aggro()
		
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
				#print('looking snap')
				rotation.x = clamp(rotation.x, deg2rad(0), deg2rad(0))
				rotation.z = clamp(rotation.x, deg2rad(0), deg2rad(0))
				immediate_look = false
			elif turning_left == true:
				self.rotate_y(rotate_degree)
			elif turning_right == true:
				self.rotate_y(-rotate_degree)
	elif current_state == 'Lurking':
		if mouth_closed == false:
			mouth_closed = true
			$MouthAnimation.play_backwards("Open")
			$TongueCollide/Spike/TongueAnimator.play("Hidden")
			#print('movin')
	

func show_injury():
	if injured == true:
		w1.visible = true
		w2.visible = true
		w3.visible = true
		w4.visible = true
		w5.visible = true
		tw6.visible = true
		tw7.visible = true
		tw8.visible = true
		tw9.visible = true
		tw10.visible = true
		btw11.visible = true
		btw12.visible = true
		w13.visible = true
		w14.visible = true
	elif injured == false:
		w1.visible = false
		w2.visible = false
		w3.visible = false
		w4.visible = false
		w5.visible = false
		tw6.visible = false
		tw7.visible = false
		tw8.visible = false
		tw9.visible = false
		tw10.visible = false
		btw11.visible = false
		btw12.visible = false
		w13.visible = false
		w14.visible = false

func scan():
	var sight = sense_range.get_overlapping_bodies()
	if target_seen == false:
		if gaveup == false:
			for thing in sight:
				if thing.is_in_group('Player') or thing.is_in_group('Parasite'):
					if thing.hurt_wurm == true:
						set_target(thing)
						target_seen = true
						print('prioritized threat')
				if thing.is_in_group('Parasite'):
					set_target(thing)
					target_seen = true
				elif thing.is_in_group('Prey'):
					if thing.dead == false:
						set_target(thing)
						target_seen = true
		if gaveup == true:
			set_target(retreat_coords_temp)
			target_seen = true

func set_target(target):
	if gaveup == false:
		target_vec = target.global_transform.origin
	elif gaveup == true:
		target_vec = retreat_coords_temp
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


func death():
	pass

func take_damage(damage):
	ichor -= damage
	aggro = true
	killed_twice = false
	current_state = "Moving"
	if ichor <= 40:
		injured = true
		show_injury()
	print('aggroed from damage!')
	hurt = true
	$HurtTimer.start()
	#sounds?
	#aggro towards source


func choose_move_action():
	#dir_chosen terminates loop to avoid confusion over multiple targets
	#print('choosing move action')
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
				#print('face quad= ', quadrant, ' targ quad= ', target_quadrant)
				
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
					#print('random turn reset')
					random_turn_set = false
				#dir_chosen = true
				#print('direction chosen')

				#if i.is_in_group('wurm_target'):
				var in_front = forward_gaze.get_overlapping_bodies()
				for b in in_front:
					if b.is_in_group('wurm_target'):
						moving_forward = true
						turning_left = false
						turning_right = false
						
						$GrossBodyAnimation.play("Forward")
						#print('in front of')
				dir_chosen = true
				#temp till I figure out having animations trigger the boolean toggle
				#moving_at_all = true
				#should work now given exported variable, thanks boris
	#print('forward is ', moving_forward, ', left is ', turning_left, ", right is ", turning_right)

func determine_aggro():
	if current_state == 'Lurking':
		aggro = false
		hiding = true
	elif current_state == 'Birthing':
		aggro = false
		hiding = false
	else:
		if killed_twice == false:
			aggro = true
		hiding = false
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

func tongue_aim():
	if next_stab == true:
		if killed_twice == false:
			$StabTimer.start()
			stab = true
			crab.visible = false
		elif killed_twice == true:
			next_stab = false
	var targets = tongue_target_area.get_overlapping_bodies()
	var target_found = false
	if target_found == false:
		for target in targets:
			if target.is_in_group('Prey') or target.is_in_group('Parasite'):
				if target.dead == false:
					target_found = true
					tongue_target = target.global_transform.origin
					$TongueCollide/Spike/TongueAnimator.play("Pulse")
	tongue.look_at(tongue_target, Vector3.UP)
	if tongue.rotation.x <= deg2rad(-20):
		tongue.rotation.x = deg2rad(-20)
	elif tongue.rotation.x >= deg2rad(20):
		tongue.rotation.x = deg2rad(20)
	if tongue.rotation.y <= deg2rad(-20):
		tongue.rotation.y = deg2rad(-20)
	elif tongue.rotation.y >= deg2rad(20):
		tongue.rotation.y = deg2rad(20)
	var ty = (tongue.rotation.x / 2)
	#print(ty)
	tongue.translation.y = ty
	var tx = (tongue.rotation.y / - 2)
	#print(tx)
	tongue.translation.x = tx
	if stab == false:
		tongue.translation.z += 0.1
		if tongue.translation.z >= 0:
			tongue.translation.z = 0
	elif stab == true:
		tongue.translation.z -= 0.1
		if tongue.translation.z <= -1.4:
			tongue.translation.z = -1.4
	if tongue.translation.z == 0:
		crab.visible = false
		$TongueCollide/Spike/TongueAnimator.play("Hidden")
	
func _on_scan_delay_timeout():
	clear_move()
	target_seen = false
	scan()
	var near_zone = nearby.get_overlapping_bodies()
	var targets_near = false
	#retracts tongue if nothing is nearby
	if targets_near == false:
		for i in near_zone:
			if i.is_in_group('Prey'):
				if i.dead == false:
					targets_near = true
			if i.is_in_group('Parasite'):
				targets_near = true
	if targets_near == false:
		stab = false

	if current_state == "Attacking":
		var in_eat_range = false
		var mouthzone = tongue_target_area.get_overlapping_bodies()
		if in_eat_range == false:
			for t in mouthzone:
				if t.is_in_group('Prey'):
					if t.dead == false:
						in_eat_range = true
		if in_eat_range == false:
			current_state = "Moving"
			next_stab = false
			#print('scan stopped attacking')
	if target_seen == false:
		hiding = true
		tongue_safety = true
		if mouth_closed == false:
			mouth_closed = true
			$MouthAnimation.play_backwards("Open")
	$scan_delay/movechoose.start()
	


func _on_OptimalEat_body_entered(body):
	if body.is_in_group('Prey') or body.is_in_group('Parasite'):
		if body.dead == false:
			current_state = states[2]
			$GrossBodyAnimation.play("IdlePose")
			tongue_target = body.global_transform.origin
			if aggro == true:
				if mouth_closed == true:
					mouth_closed = false
					$MouthAnimation.play("Open")
				tongue_safety = false
				stab = true
				next_stab = false
				$StabTimer.start()



func _on_Sight_body_entered(body):
	pass
	#print(body)


func _on_movechoose_timeout():
	if current_state == "Moving":
		if aggro == true:
			choose_move_action()
			#print('movechoose timer check')
			
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
	#print(current_state)


func _on_stab_zone_body_entered(body):
	var choice = rng.randi_range(0,1)
	if tongue_safety == false:
		if body.is_in_group('Destructible'):
			body.take_damage(damage)
			$Give_up.start()
			#should restart timer
			print('reset giveup')
		if hungry == true:
			if body.is_in_group('SmallBug'):
				body.dead = true
				hungry = false
				food_eaten += 5
				#maybe make it more if the crab was big?
				$Hunger_time.start()
				body.queue_free()
				crab.visible = true
		if hungry == false:
			if body.is_in_group('SmallBug'):
				if killed_twice == false:
					if body.dead == true:
						killed_twice = true
		$StabTimer.start()


func _on_OptimalEat_body_exited(body):
	pass


func _on_StabTimer_timeout():
	stab = false
	next_stab = false
	$StabCooldown.start()



func _on_CloseRange_body_entered(body):
	if body.is_in_group('Prey'):
		if body.dead == false:
			current_state = states[1]
			if mouth_closed == true:
				if killed_twice == false:
					$MouthAnimation.play("Open")
					mouth_closed = false


func _on_StabCooldown_timeout():
	next_stab = true
	stab = false


func _on_Sight_body_exited(body):
	if body.is_in_group('Player'):
		print('player exited sight')


func _on_Hunger_time_timeout():
	if hungry == false:
		ichor += 5
		print('regenerated')
		if ichor >= 40:
			injured = false
	elif hungry == true:
		stress += 5
	show_injury()
	hungry = true
	killed_twice = false


func _on_Give_up_timeout():
	if hurt == false:
		retreat_coords_temp = behind_tail.global_transform.origin
		set_target(behind_tail)
		print('retreat set')
		gaveup = true
		$Idle.start()

#will allow for hunger tick to harm, may change this later
func _on_Stress_timeout():
	if stress > ichor:
		stress = 0
		ichor -= 4


func _on_Idle_timeout():
	retreat_time_set = false
	if hurt == false:
		current_state = 'Lurking'
		tongue_safety = true
	gaveup = false
	print('reset gaveup')



func _on_HurtTimer_timeout():
	hurt = false
