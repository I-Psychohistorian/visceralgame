extends KinematicBody

#interaction and background


#genetics

var rng = RandomNumberGenerator.new()

var meta_gene = []
var body_gene = []
var body_score = 0

#phenotype
onready var model = $detrivoremodel

var normal_metabolism = false
signal set_pheno

var tail_types = ['Short', 'Long', 'Segmented', 'None']
var tail = ''

var wing_types = ['Normal', 'Bent', 'None']
var wings = ''

#stats
var crawl = 1
var jump_power = 1
var fly_thrust = 1

var ichor = 5

var lifespan = 30

#physics

var dead = false

var gravity = 3
var grav_vec = Vector3()
var movement = Vector3()

var water_gravity = 1

#states

var male = false
var pregnant = false
var newborn = false
var old = false

var hungry = false

var scared = false

var pred_seen = {}
var pred_location = Vector3()

var food_location = Vector3()
var mate_location = Vector3()

var jumps = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	generate_random_genome()
	set_phenotype()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_random_genome():
	rand_metabolism()
	rand_metabolism()
	var body1 = rng.randi_range(0,4)
	for i in body1:
		body_gene.append('t')
	print(meta_gene, body_gene)

func rand_metabolism():
	var meta = rng.randi_range(1,2)
	if meta == 1:
		meta_gene.append('D')
	elif meta == 2:
		meta_gene.append('l')

func set_phenotype():
	body_score = 0
	for i in meta_gene:
		if i == "D":
			normal_metabolism = true
			model.lightbody = false
	if normal_metabolism == false:
		model.lightbody = true
	for i in body_gene:
		if i == 't':
			body_score += 1
	if normal_metabolism == true:
		model.lightbody = false
	elif normal_metabolism == false:
		model.lightbody = true
	
	if body_score == 0:
		model.wings = 'None'
		model.tail = 'None'
		tail = 'None'
		wings = 'None'
		#no wings and no tail
	elif body_score == 1:
		model.wings = 'Normal'
		model.tail = 'Short'
		tail = 'Short'
		wings = 'Normal'
		#normal wings short tail
	elif body_score == 2:
		model.wings = 'Normal'
		model.tail = 'Long'
		tail = 'Long'
		wings = 'Normal'
		#normal wings long tail
	elif body_score == 3:
		if normal_metabolism == true:
			model.wings = 'Normal'
			wings = 'Normal'
		else:
			model.wings = 'Bent'
			wings = 'Bent'
		model.tail = 'Segmented'
		tail = 'Segmented'
	elif body_score >= 4:
		model.tail = 'Segmented'
		model.wings = 'Bent'
		wings = 'Bent'
		tail = 'Segmented'
	emit_signal("set_pheno")
	print(tail, wings)
	
func handle_behaviors():
	pass
	
func movement():
	pass
	
func animations():
	pass
	
func take_damage(damage):
	pass
