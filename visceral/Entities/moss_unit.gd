extends KinematicBody


var interactable = true
var item_id = "Algae"
var interact_label = "Press E to take algal mass"

var dead = false
var ichor = 8
var max_ichor = 8
var stress = 0

var nutrition = 1

#stress limit variable is threshold for max adjacent moss before penalty
var stress_limit = 4

#reproduction stuff
var will_bud = true
var budding = false

onready var rotation_point = $CentralNode
onready var grow_point = $CentralNode/GrowPoint
var grow_coords = Vector3()
#these two raycasts will monitor intersections and rotate so that slanted moss doesn't spawn through walls
onready var ground_collide = $CentralNode/GrowPoint/grow_ground_cast
onready var side_collide = $CentralNode/grow_side_cast

signal moss_bud


#for spawning in
var start_point = Vector3()
var drop_coords = Vector3()


#will allow nibbled moss to become more resilient
var trimmed = false

#model related states
var nascent = false
var light_green = false
var unhealthy = false
var damaged = false

var xs = 1
var ys = 1
var zs = 1

#game states
var neighbors = 0
var flower_neighbors = 0

var wet = false
var in_water = false

#for units that are out of water, if they are connected to units in water they will be healhtier
var connected_to_water = false

var rng = RandomNumberGenerator.new()

var grav_vec = Vector3()
var gravity = 1

onready var model = $MossModel
onready var neighbor_area = $neighbor_sensor

onready var bottom = $RayCast
onready var sticker = $sticker_cast
#normal vector
var angle = Vector3()

var spawned_in = false

var stuck = false
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_type()
	set_type()
	rand_size()
	set_size()
	var start_time = rng.randf_range(0.5,3)
	print('starting delay for algal metabolism is ', start_time)
	$random_start.set_wait_time(start_time)
	$random_start.start()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	stuck = false
	grav_vec = Vector3()
	var surface = sticker.get_collider()
	if surface != null:
		if surface.get_class() == "CSGCombiner":
			grav_vec.y = 0
			stuck = true
	if stuck == false:
		if not is_on_floor():
			lerp_angle(self.rotation.z, 0.0, 0.05)
			grav_vec.y -= gravity
	move_and_slide(grav_vec, Vector3.UP)


func take_damage(damage):
	ichor -= damage
	trimmed = true
	if ichor < max_ichor:
		damaged = true
		model.show_damage()
	if dead == false:
		if ichor <= 0:
			#die
			queue_free()
	
func rand_size():
	xs = rng.randf_range(0.8,1)
	zs = rng.randf_range(0.8,1)
	ys = rng.randf_range(0.5,2.5)
func set_size():
	$MossModel.scale = Vector3(xs, ys, zs)
	#print(scale)

func reparent():
	var new_parent = self.get_parent().get_parent()
	#for ensuring correct parent is one node up, should be plant controller
	#print(new_parent)
	get_parent().remove_child(self)
	new_parent.add_child(self)
	self.global_transform.origin = drop_coords

func use():
	var nearby = $player_sensor.get_overlapping_bodies()
	for n in nearby:
		if n.is_in_group('Player'):
			n.holding_item = true
			n.item_nutrition = self.nutrition
			n.item_id = self.item_id
			n.hud.message = interact_label
			n.item_max_ichor = max_ichor
			n.item_ichor = ichor
			n.item_stress = stress
			n.item_trimmed = trimmed
			n.item_nascent = nascent
			n.item_light_green = light_green
			n.item_unhealthy = unhealthy
			n.item_damaged = damaged
			if light_green == true:
				n.algae.mid_green()
			elif light_green == false:
				if nascent == false:
					n.algae.dark_green()
				elif nascent == true:
					n.algae.trans_green()
			if unhealthy == true:
				n.algae.brown()
			if damaged == true:
				n.algae.show_damage()
			elif damaged == false:
				n.algae.hide_damage()
			n.algae.visible = true
			queue_free()
func get_normal():
	angle = bottom.get_collision_normal()
	#print(angle)

func generate_type():
	var choice = rng.randi_range(0,3)
	if choice == 0:
		light_green = true
		nascent = false
	elif choice == 2:
		nascent = true
		light_green = false
	else:
		light_green = false
		nascent = false

func set_type():
	if light_green == true:
		model.mid_green()
	elif light_green == false:
		if nascent == false:
			model.dark_green()
		elif nascent == true:
			model.trans_green()
	if unhealthy == true:
		model.brown()
	if damaged == true:
		model.show_damage()
	elif damaged == false:
		model.hide_damage()

func check_neighbors():
	neighbors = 0
	flower_neighbors = 0
	var nearby_plants = neighbor_area.get_overlapping_bodies()
	for p in nearby_plants:
		if p.is_in_group('Moss'):
			neighbors +=1
			if in_water == true:
				p.connected_to_water = true
		elif p.is_in_group('Flower'):
			flower_neighbors += 1
			p.stress += 1
			print('stressed nearby flowers')
	if neighbors >= stress_limit:
		print('stressed by ', String(neighbors - stress_limit + 1),  ' neighbor moss')
		stress += 1 + ((neighbors - stress_limit))
	if flower_neighbors > 0:
		stress += flower_neighbors
		print('stressed by neighboring flowers')
	#print(neighbors, ' moss bois adjacent. ', flower_neighbors, ' flower bois adjacent')




func begin_budding():
	var bud_check = true
	var rand_degree = rng.randi_range(-180,180)
	var turn_num = 5
	rotation_point.rotation.y = deg2rad(rand_degree)
	if bud_check == true:
		# loop executes 5 times, but will not rotate in z if the colliders stop colliding
		for n in turn_num:
			if ground_collide.is_colliding() or side_collide.is_colliding():
				rotation_point.rotate_z(deg2rad(15))
			elif not ground_collide.is_colliding() and not side_collide.is_colliding():

				bud_check = false
	if bud_check == false:
		#print('bud_check is false')
		budding = true 
		#moved budding = true down here so that the bud check does not create perpetually budded
		#units that cannot set grow_point
		if budding == true:
			grow_coords = grow_point.global_transform.origin
			#print(grow_coords, 'grow coords for spawned moss')
			
			emit_signal("moss_bud")
		else:
			#print('too many collisions, did not bud')
			budding = false
	rotation_point.rotation.z = 0

func set_controls():
	self.global_transform.origin = start_point
	#print(self.global_transform.origin, "is spawned moss start point")
	connect("moss_bud", get_parent(), "spawn_moss")



func _on_stress_tick_timeout():
	#want stress roll to be above stress number, it's a stress threshold
	var stress_roll = rng.randi_range(1,7)
	var stressmod = 5 - neighbors  - stress_roll
	if in_water == true:
		stressmod -= 3
	if in_water == false:
		if connected_to_water == true:
			stressmod -= 2
			print('not in water but connected to water!')
	if unhealthy == true:
		stressmod += 1
	stress += stressmod
	print('stress = ', stress , ' stress mod = ', stressmod, ' stress roll = ', stress_roll)
	if stress > 0:
		if unhealthy == true:
			#die
			queue_free()
		else:
			unhealthy = true
			max_ichor /= 2
			if ichor > max_ichor:
				ichor = max_ichor
			#print('moss got unhealthy')
	elif stress_roll > stress:
		#print('stress roll succeeded!')
		unhealthy = false
		if trimmed == true:
			max_ichor = 12
			nutrition = 2
		model.hide_damage()
		max_ichor = 8
		ichor = max_ichor
		damaged = false
	set_type()
	stress = 0
	if in_water == false:
		connected_to_water = false


#temp disabled
func _on_neighbor_timer_timeout():
	check_neighbors()


func _on_debugtime_timeout():
	get_normal()
	global_rotation = angle
	if spawned_in == false:
		connect("moss_bud", get_parent(), "spawn_moss")
		spawned_in = true
		print('connected non_spawned moss')
	#set_size()
	#self.global_rotation.z = angle.z
	#self.global_rotation.x = angle.x
	#self.global_rotation.y = angle.y


func _on_temp_bud_timeout():
	if will_bud == true:
		if unhealthy == false:
			var bud_choice = rng.randi_range(0,2)
			if bud_choice > 0:
				print('budding')
				begin_budding()
			elif bud_choice == 0:
				print('not budding')
			
		elif unhealthy == true:
			'not healthy enough to bud'


func _on_random_start_timeout():
	$stress_tick.start()
	$neighbor_timer.start()
	$temp_bud.start()
	print('moss metabolism started')
