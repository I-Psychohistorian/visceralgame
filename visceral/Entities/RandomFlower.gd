extends KinematicBody

var seeding = false
#for plant controller to check

var gravity = 4
var grav_vec = Vector3()


var flowered = false

var basic_type = false
var dry_type = false
var alt = false

var nutrition = 5
var seeds = 0
var ichor = 5

var sound_type = "vege"

var start_rotation = 0
var wilted = false
var dead = false

var rando_gene = true

var gene = []
#for generation of gametes
var seed_gamete = "Y"
var pollen_gamete = "X"
var rng = RandomNumberGenerator.new()

onready var baseflower = $BaseFlower
onready var dryflower = $DarkRedFlower
onready var purpleflower = $PurpleFlower
onready var yellowflower = $YellowFlower
onready var deadflower = $DeadFlower

#time it takes to grow
var grow_time = 0
onready var growth_timer = $GrowthTimer

#time it takes to wilt
var wilt_time = 0
onready var WiltTimer = $WiltTimer

#conditions
var fertile_soil = false
var wet = false
var in_water = false

var water = 0
var stress = 0
var second_chance = false

signal startgrowth
signal openflower
signal release_seeds

var seed1coord = Vector3()
var seed2coord = Vector3()
var seed3coord = Vector3()
var pollen_coord = Vector3()

var start_coord = Vector3()
onready var pollen_point = $PollenGenerationPoint
onready var pollen = preload("res://Entities/PollenBall.tscn")


#interact variables
var interactable = true
var item_id = "Plant"
var interact_label = "Press E to eat bud"

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(seed1coord)
	$StartTimer.start()

func genome():
	rng.randomize()
	var lele = rng.randi_range(1,3)
	if lele == 1:
		gene.append("A")
	elif lele == 2:
		gene.append("B")
	elif lele == 3:
		gene.append("C")
	print("current alleles are: ", gene)

func generate_plant():
	#for random rotation
	rng.randomize()
	start_rotation = rng.randi_range(0,-360)
	rotate_y(deg2rad(start_rotation))
	#for random blooming and wilting time
	grow_time = rng.randi_range(10,12) #30 and 60
	wilt_time = rng.randi_range(20,40) 
	#for random genome
	for allele in gene:
		if allele == "A":
			basic_type = true
		elif allele == "C":
			alt = true
		elif allele == "B":
			dry_type = true

	if basic_type == true:
		if alt == false:
			baseflower.visible = true
			nutrition = 5
			#grow_time and wilt_time is standard and moves at x1
		elif alt == true:
			purpleflower.visible = true
			nutrition = 10
			grow_time *= 1.5
			wilt_time *= 2
	if basic_type == false:
		if dry_type == true:
			if alt == false:
				dryflower.visible = true
				nutrition = 3
				grow_time *= 1.5
				wilt_time *= 2
			elif alt == true:
				yellowflower.visible = true
				nutrition = 8
				grow_time *= 2
				wilt_time *= 3
		else:
			deadflower.visible = true
			grow_time *=3
			wilted = true
			wilt_time *0.5
			nutrition = 1
	generate_gametes()
	
	#print("growth time is ", grow_time)
	growth_timer.set_wait_time(grow_time)
	growth_timer.start()
	emit_signal("startgrowth")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.

func generate_gametes():
	rng.randomize()
	var gametes = rng.randi_range(1,6)
	for allele in gene:
		if allele == "A":
			gametes += 2
		elif allele == "C":
			gametes -= 2
	#print("seedscore number is: ", gametes)
	if gametes >= 7:
		seeds = 3
	elif gametes >= 4:
		seeds = 2
		$Seed2.visible = false
	elif gametes >= 0:
		seeds = 1
		$Seed2.visible = false
		$Seed3.visible = false
	elif gametes < 0:
		seeds = 0
		$Seed.visible = false
		$Seed2.visible = false
		$Seed3.visible = false

func _process(delta):
	if in_water == true:
		gravity = -1
	elif in_water == false:
		gravity = 4
	grav_vec = Vector3()
	if not is_on_floor():
		grav_vec += Vector3.DOWN * gravity * delta
		move_and_slide(grav_vec, Vector3.UP)

func pollen_allele():
	var flip = rng.randi_range(0,1)
	pollen_gamete = gene[flip]
	#mutate
	var chance = rng.randi_range(1, 100)
	if chance == 1:
		print("Pollen Mutation!")
		if pollen_gamete == "A":
			pollen_gamete = "B"
			print('A shifted to B')
		elif pollen_gamete == "B":
			pollen_gamete = "C"
			print('B shifted to C')
		elif pollen_gamete == "C":
			pollen_gamete = "A"
			print('C shifted to A')
	#print("pollen allele is: ", pollen_gamete)


func release_pollen():
	pollen_coord = $PollenGenerationPoint.global_transform.origin
	var release_chance = rng.randi_range(0,1)
	var pollen_num = rng.randi_range(2,6)
	if wilted == true:
		if release_chance == 0:
			print("too wilted, no pollen")
			pollen_num = 0
	#print("Pollen number is: ", pollen_num)
	
	for i in pollen_num:
		var p = pollen.instance()
		pollen_point.add_child(p)
		pollen_allele()
		p.gamete.append(pollen_gamete)
		#print('pollenburst')
		#number of pollen pieces
		
#dies + releases seeds
func release_seed():
	seed1coord = $Seed.global_transform.origin
	seed2coord =$Seed2.global_transform.origin 
	seed3coord = $Seed3.global_transform.origin 
	seeding = true
	$Seed.visible = false
	$Seed2.visible = false
	$Seed3.visible = false
	if dead == false:
		emit_signal("release_seeds")
	dead = true
	$Timer.start()

func use():
	var area = $interact_Area.get_overlapping_bodies()
	for body in area:
		if body.is_in_group('Player'):
			if dead == false:
				body.item_id = item_id
				body.stamina += nutrition
				body.ichor += nutrition
				body.hunger = false
				body.eat_sounds()
				release_seed()

func take_damage(damage):
	ichor -= damage
	print('plant ouch')
	if ichor <= 0:
		release_seed()

func _on_GrowthTimer_timeout():
	emit_signal("openflower")
	interact_label = "Press E to eat flower"
	#marks phenotypic difference between double CC flowers
	if basic_type == false and dry_type == false:
		$deadCCbloom.visible = true
	release_pollen()
	WiltTimer.set_wait_time(wilt_time)
	WiltTimer.start()
	


func _on_StartTimer_timeout():
	if rando_gene == false:
		var new_parent = self.get_parent().get_parent()
		#for ensuring correct parent is one node up, should be plant controller
		#print(new_parent)
		get_parent().remove_child(self)
		new_parent.add_child(self)
		#print(get_parent())
		self.global_transform.origin = start_coord
		#var plant_control = get_parent()
		#connect("release_seeds", plant_control, "spawn_seeds")
		global_rotation.x = 0
		global_rotation.z = 0
	elif rando_gene == true:
		genome()
		genome()
	var plant_control = get_parent()
	connect("release_seeds", plant_control, "spawn_seeds")
	generate_plant()


func _on_Timer_timeout():
	queue_free()


func _on_WiltTimer_timeout():
	handle_stress()
	if wilted == false:
		if second_chance == false:
			baseflower.visible = false
			purpleflower.visible = false
			yellowflower.visible = false
			dryflower.visible = false
			deadflower.visible = true
			nutrition -= 1
			#wilting
			var seed_loss = rng.randi_range(0,3)
			seeds -= seed_loss
			if seeds < 0:
				seeds = 0
			if seeds < 3:
				$Seed3.visible = false
			if seeds < 2:
				$Seed2.visible = false
			if seeds < 1:
				$Seed.visible = false
			print(seed_loss, " seeds lost from wilting")
		elif second_chance == true:
			print('healthy enough to avoid wilting')
			second_chance = false
			wilt_time += 30
			WiltTimer.set_wait_time(wilt_time)
			WiltTimer.start()
	elif wilted == true:
		release_seed()
		#die and release seeds



func _on_WetTimer_timeout():
	if wet == true:
		wet = false
		#water absorbed
		if dry_type == true:
			water += 1
		if alt == true:
			water -= 2
		if basic_type == true:
			water -= 1
	if in_water == true:
			wet = true

#stress accumulates over lifetime, upon wilt check if it is below zero the plant is healthy enough to
#restart wilt timer
#some genotypes handle water better than others, it can either add to or remove stress
func handle_stress():
	print("stress score: ", stress, ", water score: ", water)
	var stress_roll = rng.randi_range(5,10)
	var stress_calc = (water + stress) - stress_roll 
	print('stress calc is (want it to be less than 0): ', stress_calc)
	if stress_calc < 0:
		second_chance = true
		print('Lifespan extended')
	elif stress_roll >= 0:
		second_chance = false
		print('too stressed, wilting')
	water = 0

func _on_Stress_timer_timeout():
	for allele in gene:
		if allele == "A":
			stress += rng.randi_range(1,2)
		elif allele == "B":
			stress += rng.randi_range(0,1)
		elif allele == "C":
			stress += 0
		
