extends RigidBody


var pollenated = false
var alleles = []
var standard_start = true

signal sprout
onready var plant = preload("res://Entities/RandomFlower.tscn")
var sprout_location = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	if standard_start == true:
		alleles = ["A"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func die():
	queue_free()

func _on_Timer_timeout():
	self.sleeping = true
	sprout_location = self.global_transform.origin
	MODE_STATIC
	$CollisionShape.disabled = true
	var p = plant.instance()
	add_child(p)
	p.start_coord = sprout_location + Vector3(0, 0.2, 0)
	p.global_rotation.x = 0
	p.global_rotation.z = 0
	p.scale = Vector3(1,1,1)
	p.gene = alleles
	p.rando_gene = false
	print(p.gene)
	emit_signal("sprout")
	#$Deleter.start()


func _on_polination_area_body_entered(body):
	if pollenated == false:
		if body.is_in_group("Pollen"):
			alleles.append(body.gamete[0])
			print("genome is now: ", alleles)
			pollenated == true
			$pollenated.visible = true
			$Timer.start()
		elif body.is_in_group("Player"):
			if body.pollenated == true:
				alleles.append(body.pollen_gamete[0])
				pollenated == true
				body.wash_pollen()
				print("seed alleles are: ", alleles)
				$pollenated.visible = true
				$Timer.start()
		


func _on_Deleter_timeout():
	queue_free()
