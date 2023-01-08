extends Spatial


onready var plant = preload("res://Entities/RandomFlower.tscn")
onready var pollen = preload("res://Entities/PollenBall.tscn")
onready var plantseed = preload("res://Assets/RigidSeed.tscn")

var pollen_point = Vector3()
var seed_point = Vector3()

onready var crab = preload("res://Entities/FlowerBug.tscn")
onready var crabegg = preload("res://Entities/PollinatorEgg.tscn")

var crab_spawn_point = Vector3()

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func spawn_seeds():
	for child in self.get_children():
		if child.is_in_group("Plant"):
			if child.seeding == true:
				var seedscale = Vector3(0.15,0.15,0.15)
				var s = plantseed.instance()
				var s2 = plantseed.instance()
				var s3 = plantseed.instance()
				rng.randomize()
				if child.seeds >= 1:
					self.add_child(s)
					s.scale = seedscale
					s.drop_coords = child.seed1coord + Vector3(0,0.1,0)
					s.reorient()
					var choice = rng.randi_range(0,1)
					s.alleles.append(child.gene[choice])
					var mutation = rng.randi_range(1, 100)
					if mutation == 1:
						print('Seed mutation!')
						if s.alleles[0] == "A":
							s.alleles[0] == "B"
							print('A shifted to B')
						elif s.alleles[0] == "B":
							s.alleles[0] == "C"
							print('B shifted to C')
						elif s.alleles[0] == "C":
							s.alleles[0] == "B"
							print('C shifted to B')
					s.determine_nutrients()
				if child.seeds >= 2:
					self.add_child(s2)
					s2.scale = seedscale
					s2.drop_coords = child.seed2coord + Vector3(0,0.1,0)
					s2.reorient()
					var choice = rng.randi_range(0,1)
					s2.alleles.append(child.gene[choice])
					var mutation = rng.randi_range(1, 100)
					if mutation == 1:
						print('Seed mutation!')
						if s2.alleles[0] == "A":
							s2.alleles[0] == "B"
							print('A shifted to B')
						elif s2.alleles[0] == "B":
							s2.alleles[0] == "C"
							print('B shifted to C')
						elif s2.alleles[0] == "C":
							s2.alleles[0] == "B"
							print('C shifted to B')
					s2.determine_nutrients()
				if child.seeds >=3:
					self.add_child(s3)
					s3.scale = seedscale
					s3.drop_coords = child.seed2coord + Vector3(0,0.1,0)
					s3.reorient()
					var choice = rng.randi_range(0,1)
					s3.alleles.append(child.gene[choice])
					var mutation = rng.randi_range(1, 100)
					if mutation == 1:
						print('Seed mutation!')
						if s3.alleles[0] == "A":
							s3.alleles[0] == "B"
							print('A shifted to B')
						elif s3.alleles[0] == "B":
							s3.alleles[0] == "C"
							print('B shifted to C')
						elif s3.alleles[0] == "C":
							s3.alleles[0] == "B"
							print('C shifted to B')
					s3.determine_nutrients()
				child.seeding = false
				# child seeding set to false seems to have fixed the seed-splosion problem


func spawn_crab():
	var crabs = get_children()
	for crab in crabs:
		if crab.is_in_group('SmallBug'):
			if crab.laying_egg == true:
				crab_spawn_point = crab.egg_point
				var egg = crabegg.instance()
				add_child(egg)
				if crab.fertile == false:
					egg.viable = false
				if crab.crested == false:
					egg.parent_crestless = true
				egg.scale = Vector3(crab.start_size, crab.start_size, crab.start_size)
				egg.global_transform.origin = crab_spawn_point
				crab.laying_egg = false
				egg.check_viable()
				#print('egg created')
				

func _on_RigidSeed_sprout():
	pass # Replace with function body.


func _on_RandomFlower_release_seeds():
	spawn_seeds()


func _on_RandomFlower2_release_seeds():
	spawn_seeds()
