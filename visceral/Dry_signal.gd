extends Spatial


signal BB
signal BC
signal AA
signal AB
signal AC
signal CC


# Called when the node enters the scene tree for the first time.
func _ready():
	print('emitting')
	emit_signal("AA", "AB", "AC", "BB", "BC", "CC")
	print('emitted')



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
