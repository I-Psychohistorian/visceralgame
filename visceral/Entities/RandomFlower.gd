extends KinematicBody


var gravity = 5
var grav_vec = Vector3()


var flowered = false

var basic_type = false
var dry_type = false
var alt = false

var nutrition = 5
var seeds = 0

var start_rotation = 0
var wilted = false
var dead = false

var gene = []
var rng = RandomNumberGenerator.new()

onready var baseflower = $BaseFlower
onready var dryflower = $DarkRedFlower
onready var purpleflower = $PurpleFlower
onready var yellowflower = $YellowFlower
onready var deadflower = $DeadFlower

signal startgrowth
signal openflower

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_plant()

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
	#for random genome
	genome()
	genome()
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
		elif alt == true:
			purpleflower.visible = true
			nutrition = 10
	if basic_type == false:
		if dry_type == true:
			if alt == false:
				dryflower.visible = true
				nutrition = 3
			elif alt == true:
				yellowflower.visible = true
				nutrition = 8
		else:
			deadflower.visible = true
			wilted = true
			nutrition = 1
	generate_gametes()
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
	print("seedscore number is: ", gametes)
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
	grav_vec = Vector3()
	if not is_on_floor():
		grav_vec += Vector3.DOWN * gravity * delta
		move_and_slide(grav_vec, Vector3.UP)


func _on_GrowthTimer_timeout():
	emit_signal("openflower")
	
