extends KinematicBody

#interaction and background


#genetics

var rng = RandomNumberGenerator.new()

var meta_gene = []
var body_gene = []
var body_score = 0

#phenotype

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_random_genome():
	rand_metabolism()
	rand_metabolism()
	var body1 = rng.randi_range(0,4)
	for i in body1:
		body_gene.append('b')
	print(meta_gene, body_gene)

func rand_metabolism():
	var meta = rng.randi_range(1,2)
	if meta == 1:
		meta_gene.append('D')
	elif meta == 2:
		meta_gene.append('d')

func set_phenotype():
	pass

func handle_behaviors():
	pass
	
func movement():
	pass
	
func animations():
	pass
	
func take_damage(damage):
	pass
