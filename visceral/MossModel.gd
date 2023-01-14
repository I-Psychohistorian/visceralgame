extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	invis_models()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func invis_models():
	$RegularTrans.visible = false
	$DeepGreen.visible = false
	$MidGreen.visible = false
	$Brown.visible = false

func trans_green():
	invis_models()
	$RegularTrans.visible = true

func dark_green():
	invis_models()
	$DeepGreen.visible = true

func mid_green():
	invis_models()
	$MidGreen.visible = true

func brown():
	invis_models()
	$Brown.visible = true
