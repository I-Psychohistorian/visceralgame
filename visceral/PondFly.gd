extends KinematicBody

#interaction and background


#genetics

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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
