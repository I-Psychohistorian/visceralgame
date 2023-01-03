extends KinematicBody


var budded = false
var flowered = false

var basic_type = false
var dry_type = false
var alt = false

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
	print("number is: ", lele)
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
		elif alt == true:
			purpleflower.visible = true
	if basic_type == false:
		if dry_type == true:
			if alt == false:
				dryflower.visible = true
			elif alt == true:
				yellowflower.visible = true
		else:
			deadflower.visible = true
			wilted = true
	emit_signal("startgrowth")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_GrowthTimer_timeout():
	emit_signal("openflower")
