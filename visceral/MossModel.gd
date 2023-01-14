extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var rng = RandomNumberGenerator.new()
onready var d1 = $cb/damage1
onready var d2 = $cb/damage2
onready var d3 = $cb/damage3
onready var d4 = $cb/damage4


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	invis_models()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#should generate up to 3??? will have to check
func show_damage():
	var slashes = rng.randi_range(1,3)
	print('slashes is ', slashes)
	for slash in slashes:
		var type = rng.randi_range(1,4)
		if type == 1:
			d1.visible = true
		elif type == 2:
			d2.visible = true
		elif type == 3:
			d3.visible = true
		elif type == 4:
			d4.visible = true

func hide_damage():
	d1.visible = false
	d2.visible = false
	d3.visible = false
	d4.visible = false

func invis_models():
	$cb/RegularTrans.visible = false
	$cb/DeepGreen.visible = false
	$cb/MidGreen.visible = false
	$cb/Brown.visible = false

func trans_green():
	invis_models()
	$cb/RegularTrans.visible = true

func dark_green():
	invis_models()
	$cb/DeepGreen.visible = true

func mid_green():
	invis_models()
	$cb/MidGreen.visible = true

func brown():
	invis_models()
	$cb/Brown.visible = true
