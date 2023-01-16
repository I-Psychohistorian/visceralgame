extends KinematicBody

var dead = false
var ichor = 8
var max_ichor = 8
var stress = 0

var nutrition = 1

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
#normal vector
var angle = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_type()
	set_type()
	rand_size()
	set_size()
	#may be redundant, will check later
	connect("moss_bud", get_parent(), "spawn_moss")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grav_vec = Vector3()
	if not is_on_floor():
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
		elif p.is_in_group('Flower'):
			flower_neighbors += 1
			p.stress += 1
	#print(neighbors, ' moss bois adjacent. ', flower_neighbors, ' flower bois adjacent')

func set_spawner_collisions(bud_check):
	if budding == true:
		if ground_collide.is_colliding() or side_collide.is_colliding():
			rotation_point.rotate_z(deg2rad(1))
			if rotation_point.rotation.z <= -1:
				print('rotated too far, no viable positions, stopped budding')
				bud_check = false
				budding = false
		else: 
			print('no spawn collisions! can bud')
			bud_check = false
	elif budding == false:
		rotation_point.rotation.z = 0
	

func begin_budding():
	budding = true
	var bud_check = true
	var rand_degree = rng.randi_range(-180,180)
	rotation_point.rotation.y = deg2rad(rand_degree)
	while bud_check == true:
		set_spawner_collisions(bud_check)
	if bud_check == false:
		print('bud_check is false')
		if budding == true:
			grow_coords = grow_point.global_transform.origin
			emit_signal("moss_bud")

func set_controls():
	self.global_transform.origin = start_point
	connect("moss_bud", get_parent(), "spawn_moss")



func _on_stress_tick_timeout():
	#want stress roll to be above stress number, it's a stress threshold
	var stress_roll = rng.randi_range(3,10)
	var stressmod = 5 - neighbors + flower_neighbors 
	if in_water == true:
		stressmod -= 5
	if in_water == false:
		if connected_to_water == true:
			stressmod -=4
	if unhealthy == true:
		stressmod += 1
	stress += stressmod
	print('stress = ', stress , ' stress mod = ', stressmod, ' stress roll = ', stress_roll)
	if stress_roll <= stress:
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
		ichor = max_ichor
		damaged = false
	set_type()
	stress = 0
	if neighbors >= 3:
		var local_stress = 1 + (neighbors - 3)
		var neighbor_moss = neighbor_area.get_overlapping_bodies()
		for moss in neighbor_moss:
			if moss.is_in_group('Moss'):
				stress += local_stress
		#signal for neighbors getting stressed
		#currently set at 3, will have to change this eventually


func _on_neighbor_timer_timeout():
	check_neighbors()


func _on_debugtime_timeout():
	get_normal()
	global_rotation = angle
	#set_size()
	#self.global_rotation.z = angle.z
	#self.global_rotation.x = angle.x
	#self.global_rotation.y = angle.y


func _on_temp_bud_timeout():
	if will_bud == true:
		begin_budding()
		print('began budding')
