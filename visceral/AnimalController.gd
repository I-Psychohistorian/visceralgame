extends Spatial


onready var crab = preload("res://Entities/FlowerBug.tscn")
onready var crabegg = preload("res://Entities/PollinatorEgg.tscn")

var crab_spawn_point = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawn_crab():
	var crabs = get_children()
	for crab in crabs:
		if crab.is_in_group('SmallBug'):
			if crab.laying_egg == true:
				crab_spawn_point = crab.egg_point
				var egg = crabegg.instance()
				add_child(egg)
				egg.scale = Vector3(crab.start_size, crab.start_size, crab.start_size)
				egg.global_transform.origin = crab_spawn_point
				print('egg created')
