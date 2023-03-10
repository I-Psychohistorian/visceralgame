extends KinematicBody

var max_ichor = 15
var ichor = 10
var stress = 0
var hungry = false

var sound_type = "meat"

#for test hostile
var parasitized = false

var crested = true

#starting size for creature
var start_size = 0.3
#.3 by default
var hunger_num = 1

var direction = Vector3()
var grav_vec = Vector3()
var gravity = 6
var speed = 1
#how many times it needs to eat before having offspring
var offspring_counter = 0
var viable_offspring = 0
var fertile = true
var laying_egg = false
signal lay_egg
onready var egg_patch = $eggspace
onready var egg_point = Vector3()

var pollenated = false
var pollen_gamete = []

var can_climb = true

var moods = ["Idle", "Alert", "Searching", "Scared"]
var current_mood = "Idle"

var is_walking = true
var dead = false

var idle_x = 0
var idle_z = 0
#how long bug rotates randomly
var rotating = false
var rotate_direction = 1
var rotate_time = 0
onready var rotate_timer = $rotate_timer

var food_seen = false
var food_coords = Vector3()
var scared = false
var enemy_seen = false
var fear_coords = Vector3()
var cornered = false
var fear_boost = 0

var player_habituation_counter = 0
var player_friend = false

onready var animator = $Body/AnimationPlayer
onready var body_pollen = $Body/StuckPollen
onready var leg_pollen = $"Body/BugLeg1/CSGCylinder/1stJoint/CSGCylinder/LegPollen"
onready var crest = $Body/BodyShape/HeadBump
onready var climb_ray = $Climb_ray

onready var sight = $Sight_Distance
onready var touch = $Eat_distance
onready var close = $Fear_distance

onready var gib = preload("res://Entities/CrabGib.tscn")
onready var parasite = preload("res://Entities/CrabParasiteBeta.tscn")

var rng = RandomNumberGenerator.new()

var wet = false
var in_water = false

var hatched = false
var start_point = Vector3()

onready var climber = $edge_climber

#gibbing stuff
var carved = false
var gibbing = false
onready var w1 = $Body/BodyShape/Wound1
onready var w2 = $Body/BodyShape/Wound2
onready var w3 = $Body/BodyShape/Wound3
onready var w4 = $Body/BodyShape/Wound4

onready var infection = $Body/BodyShape/parasite

onready var crestlosstimer = $crestloss
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var phenotype = rng.randi_range(1,4)
	if phenotype == 4:
		crest.visible = false
		crested = false
	viable_offspring = rng.randi_range(3,6)
	#print(start_point)
	#print(moods[0])
	current_mood = moods[0]
	grow()
	animator.play_backwards("Death")
	#uncrested crabs are more parasite resistant

func reparent():
	var newparent = get_parent().get_parent()
	get_parent().remove_child(self)
	newparent.add_child(self)
	self.global_transform.origin = start_point
	connect("lay_egg", get_parent(), "spawn_crab")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grav_vec = Vector3()
	if dead == false:
		movement()
		handle_death() 
	if not climb_ray.is_colliding():
		if in_water == false:
			grav_vec.y -= gravity
		elif in_water == true:
			grav_vec.y -= (gravity/5)
	elif climb_ray.is_colliding():
		pass
	move_and_slide(grav_vec, Vector3.UP)
	handle_moods()

func gib():
	w1.visible = true
	w2.visible = true
	w3.visible = true
	w4.visible = true
	if carved == false:
		carved = true
	#sound?
	elif carved == true:
		if gibbing == false:
			gibbing = true
			var g = gib.instance()
			var m = gib.instance()
			var big = gib.instance()
			var up_coord = self.global_transform.origin
			up_coord.y += 0.1
			if parasitized == true:
				up_coord.y += 0.3
			self.add_child(g)
			g.drop_coords =  up_coord
			#scale?
			g.reparent()
			self.add_child(m)
			m.drop_coords = up_coord
			m.reparent()
			if start_size >= 0.4:
				self.add_child(big)
				big.drop_coords = up_coord
				big.reparent()
			#scale?
			if parasitized == true:
				up_coord.y -= 0.2
				var p = parasite.instance()
				self.add_child(p)
				var para_size = start_size - 0.1
				p.scale = Vector3(para_size, para_size, para_size)
				p.ichor += hunger_num
				p.start_point = up_coord
				p.reparent()
			$bodybreak_timer.start()
			#sound?
		

func grow():
	self.scale = Vector3(start_size, start_size, start_size)
	hunger_num += 1

func movement():
	direction = Vector3()
	if ichor > 10:
		speed = 0.6
	elif ichor <= 10:
		speed = 0.4
	if in_water == true:
		speed += 0.4
	if current_mood == "Idle":
		if is_walking == true:
			direction.x += idle_x
			direction.z += idle_z
			rotate_body()
		elif is_walking == false:
			animator.play("Idle")
		move_and_slide(direction * speed, Vector3.UP)
	if current_mood == "Searching":
		var target_direction = food_coords - self.global_transform.origin
		move_and_slide(target_direction * (speed/2), Vector3.UP)
	if current_mood == "Scared":
		var run_direction = (fear_coords - self.global_transform.origin)*-1
		if cornered == false:
			move_and_slide(run_direction * ((speed/2) + fear_boost), Vector3.UP)
		elif cornered == true:
			run_direction.x += idle_x
			run_direction.y += idle_z
			run_direction = run_direction*-1
			move_and_slide(run_direction * speed, Vector3.UP)

func handle_moods():
	if scared == false:
		if hungry == true:
			if food_seen == true:
				current_mood = moods[2]
			elif food_seen == false:
				current_mood = moods[0]
		if offspring_counter >= 3:
			current_mood = moods[1]
			offspring_counter = 0
			#print('gave birth')
			ichor -= 3 
			#egg lay sound
			if laying_egg == false:
				animator.play("Alert")
			laying_egg = true
			self.global_transform.origin.y += 0.1
			if hunger_num > 2:
				self.global_transform.origin.y += 0.1
			egg_point = egg_patch.global_transform.origin
			$egg_timer.start()
			emit_signal("lay_egg")
			if fertile == true:
				viable_offspring -= 1
			if viable_offspring == 0:
				fertile = false
				print('ran out of viable eggs')
		if hungry == false:
			if laying_egg == false:
				current_mood = moods[0]
	elif scared == true:
		current_mood = moods[3]

func handle_animations():
	if dead == false:
		var walk_choice = rng.randi_range(1,6)
		if walk_choice < 5:
			is_walking = true
			if walk_choice <= 2:
				animator.play("Walk")
			elif walk_choice >= 3:
				animator.play("Walk2")
			elif walk_choice >= 5:
				if current_mood == "Idle":
					is_walking = false
				else:
					animator.play("Walk")
	

func handle_death():
	if ichor < 0:
		dead = true
		fertile = false
		animator.play("Death")
		climb_ray.enabled = false
		if parasitized == true:
			$Body/BodyShape/parasite.visible = true

func take_damage(damage):
	print('crab got hurt')
	ichor -= damage
	if parasitized == true:
		infection.visible = true
	if dead == true:
		gib()
	#hurt sound

func wash_pollen():
	#print('washed off pollen: ', pollen_gamete)
	pollen_gamete = []
	#print('current pollen is:' , pollen_gamete)
	pollenated = false
	leg_pollen.visible = false
	body_pollen.visible = false

func rotate_body():
	if rotating == true:
		self.rotate_y(deg2rad(rotate_direction))

func _on_hunger_timer_timeout():
	if hungry == false:
		if ichor > (19 + hunger_num):
			ichor = 19 + hunger_num
			start_size += 0.05
			grow()
		hungry = true
	elif hungry == true:
		ichor -= hunger_num*2
		pass
	if dead == false:
		if parasitized == true:
			if crested == false:
				ichor -= 1
				parasitized = false
				print('cleared parasite')
				$Body/BodyShape/parasite.visible = false
	if dead == true:
		gib()

func _on_idle_vector_timer_timeout():
	if dead == false:
		
		var choice = rng.randi_range(0,1)
		var rotate_integer = rng.randi_range(0,1)
		if rotate_integer == 1:
			rotate_direction = 1
		elif rotate_integer == 0:
			rotate_direction = -1
		if choice == 1:
			rotating = true
			rotate_time = rng.randi_range(1,6)
			rotate_timer.set_wait_time(rotate_time)
			rotate_timer.start()
		idle_x = rng.randi_range(-1,1)
		idle_z = rng.randi_range(-1,1)
		
		handle_animations()


func eat_nearby():
	var touching = touch.get_overlapping_bodies()
	var ate = false
	for i in touching:
		if ate == false:
			if i.is_in_group('Plant'):
				if hungry == true:
					ichor += i.nutrition
					i.release_seed()
					offspring_counter += 1
					hungry = false
					#eat sound
					$hunger_timer.start()
					ate = true
					ping_player()
			elif i.is_in_group('Moss'):
				if hungry == true:
					var eat_damage = rng.randi_range(6,9)
					i.take_damage(eat_damage)
					ichor += i.nutrition
					offspring_counter += 1
					hungry = false
					#eat sound
					$hunger_timer.start()
				ate = true
			elif i.is_in_group("Seed"):
				if hungry == true:
					ichor += i.nutrition
					i.queue_free()
					offspring_counter += 1
					hungry = false
					#eat sound
					$hunger_timer.start()
					ate = true
					ping_player()

func ping_player():
	var sight_radius = sight.get_overlapping_bodies()
	for body in sight_radius:
		if body.is_in_group('Player'):
			player_habituation_counter += 1

func _on_rotate_timer_timeout():
	rotating = false


func _on_Fear_distance_body_entered(body):
	if body.is_in_group('Predator'):
		if body.hiding == true:
			pass
		elif body.is_in_group("Player"):
			if player_friend == true:
				pass
			elif player_friend == false:
				scared = true
				fear_coords = body.global_transform.origin
				handle_animations()
		elif body.hiding == false:
			scared = true
			fear_coords = body.global_transform.origin
			handle_animations()

func _on_Eat_distance_body_entered(body):
	if body.is_in_group("Pollen"):
		if pollenated == false:
			pollen_gamete = body.gamete
			pollenated = true
			body.queue_free()
			body_pollen.visible = true
			leg_pollen.visible = true
	if body.is_in_group("Spore"):
		if parasitized == false:
			parasitized = true
			body.queue_free()
	if current_mood == "Searching":
		if body.is_in_group("Plant"):
			if hungry == true:
				ichor += body.nutrition
				body.release_seed()
				offspring_counter += 1
				hungry = false
				#eat sound
				$hunger_timer.start()
				ping_player()
		elif body.is_in_group('Moss'):
			if hungry == true:
				var eat_damage = rng.randi_range(6,9)
				body.take_damage(eat_damage)
				ichor += body.nutrition
				offspring_counter += 1
				hungry = false
				#eat sound
				$hunger_timer.start()
				ping_player()
		elif body.is_in_group("Seed"):
			if hungry == true:
				ichor += body.nutrition
				body.queue_free()
				offspring_counter += 1
				hungry = false
				# eat sound
				$hunger_timer.start()
				ping_player()


#this ticks on food and enemy location
func _on_search_timer_timeout():
	if hatched == false:
		connect("lay_egg", get_parent(), "spawn_crab")
	if current_mood == "Searching":
		eat_nearby()
	if player_habituation_counter >= 3:
		print('Pollen Crab habituated to player!')
		player_habituation_counter = 0
		player_friend = true
	#print(current_mood)
	food_seen = false
	var nearby_entities = sight.get_overlapping_bodies()
	for food in nearby_entities:
		if food_seen == false:
			if food.is_in_group("Plant"):
				if food.wilted == false:
					food_coords = food.global_transform.origin
					food_seen = true
			elif food.is_in_group("Moss"):
				food_coords = food.global_transform.origin
				food_seen = true
			elif food.is_in_group("Seed"):
				food_coords = food.global_transform.origin
				food_seen = true
			elif food.is_in_group("Plant"):
				if food.wilted == true:
					food_coords = food.global_transform.origin
					food_seen = true
	var fear_radius = close.get_overlapping_bodies()
	for i in fear_radius:
		if enemy_seen == false:
			if i.is_in_group("Predator"):
				if i.hiding == false:
					if player_friend == true:
						if i.is_in_group('Player'):
							pass
						else:
							fear_coords = i.global_transform.origin
							enemy_seen = true
							scared = true
							handle_animations()
					elif player_friend == false:
						fear_coords = i.global_transform.origin
						enemy_seen = true
						scared = true
						handle_animations()
	if enemy_seen == false:
		scared = false
	enemy_seen = false
	cornered = false



func _on_egg_timer_timeout():
	#laying_egg = false
	animator.play_backwards("Alert")


func _on_doublefear_body_entered(body):
	if body.is_in_group('Predator'):
		if current_mood == "Scared":
			fear_boost = 0.1


func _on_doublefear_body_exited(body):
	if body.is_in_group('Predator'):
		fear_boost = 0


func _on_gib_timer_timeout():
	pass # Replace with function body.


func _on_bodybreak_timer_timeout():
	queue_free()

#stops walking into walls
func _on_wall_detector_body_entered(body):
	can_climb = false
	if current_mood == "Scared":
		if body.is_in_group("Pollen"):
			cornered = false
		else:
			cornered = true
			#print('cornered')
	#print('bump')
	if current_mood == "Idle":
		is_walking = false


func _on_wall_detector_body_exited(body):
	pass


func _on_crestloss_timeout():
	print('because parent was crestless, child became crestless')
	crest.visible = false
	crested = false
