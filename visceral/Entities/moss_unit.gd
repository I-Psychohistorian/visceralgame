extends KinematicBody

var ichor = 6
var max_ichor = 6
var stress = 0

var nutrition = 1

#will allow nibbled moss to become more resilient
var trimmed = false

#model related states
var nascent = false
var light_green = false
var unhealthy = false
var damaged = false

#game states
var neighbors = 0
var flower_neighbors = 0

var wet = false
var in_water = false

#for units that are out of water, if they are connected to units in water they will be healhtier
var connected_to_water = false

var rng = RandomNumberGenerator.new()

onready var model = $MossModel
onready var neighbor_area = $neighbor_sensor
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_type():
	var choice = rng.randi_range(0,2)
	if choice == 0:
		light_green = true
	else:
		light_green = false

func set_type():
	if light_green == true:
		model.mid_green()
	elif light_green == false:
		model.dark_green()
	if unhealthy == true:
		model.brown()
	if damaged == true:
		model.show_damage()
	elif damaged == false:
		model.hide_damage()


#taken from pollencrab, will need to retool for plant controller to spawn in more
func reparent():
	var newparent = get_parent().get_parent()
	#get_parent().remove_child(self)
	#newparent.add_child(self)
	#self.global_transform.origin = start_point
	#connect("lay_egg", get_parent(), "spawn_crab")

func _on_stress_tick_timeout():
	pass # Replace with function body.
