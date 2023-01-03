extends Spatial


onready var bud = $bud
onready var p1 = $petal
onready var p2 = $petal2
onready var p3 = $petal3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func budding():
	bud.visible = true
	p1.visible = false
	p2.visible = false
	p3.visible = false
func flowering():
	bud.visible = false
	p1.visible = true
	p2.visible = true
	p3.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RandomFlower_startgrowth():
	budding()


func _on_RandomFlower_openflower():
	flowering()
