extends RigidBody

var seeding = false

var pollenated = false
var alleles = []
var standard_start = false
var nutrition = 0

var interactable = true
var item_id = "Seed"

var rng = RandomNumberGenerator.new()
var grow_time = 0
onready var sprout_timer = $Timer

signal sprout
onready var plant = preload("res://Entities/RandomFlower.tscn")
var sprout_location = Vector3()
var drop_coords = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.global_transform.origin)
	rng.randomize()
	grow_time = rng.randi_range(5, 10)
	if standard_start == true:
		alleles = ["A"]

	#reparent
func determine_nutrients():
	for allele in alleles:
		if allele == "A":
			nutrition += 3
		elif allele == "B":
			nutrition += 2
		elif allele == "C":
			nutrition += 1

func reparent():
	var new_parent = self.get_parent().get_parent()
	#for ensuring correct parent is one node up, should be plant controller
	#print(new_parent)
	get_parent().remove_child(self)
	new_parent.add_child(self)
	self.global_transform.origin = drop_coords

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reorient():
	global_transform.origin = drop_coords

func get_pollenated():
	for allele in alleles:
		if allele == "A":
			pass
		elif allele == "B":
			grow_time += 4
		elif allele == "C":
			grow_time += 5
		$pollenated.visible = true
		sprout_timer.set_wait_time(grow_time)
		sprout_timer.start()

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
			pollenated = true
			$pollenated.visible = true
			for allele in alleles:
				if allele == "A":
					pass
				elif allele == "B":
					grow_time += 4
				elif allele == "C":
					grow_time += 5
			sprout_timer.set_wait_time(grow_time)
			sprout_timer.start()
		elif body.is_in_group("Player"):
			if body.pollenated == true:
				alleles.append(body.pollen_gamete[0])
				pollenated = true
				body.wash_pollen()
				print("seed alleles are: ", alleles)
				$pollenated.visible = true
				for allele in alleles:
					if allele == "A":
						pass
					elif allele == "B":
						grow_time += 4
					elif allele == "C":
						grow_time += 5
				sprout_timer.set_wait_time(grow_time)
				sprout_timer.start()
		


func _on_Deleter_timeout():
	queue_free()
