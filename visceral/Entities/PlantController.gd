extends Spatial


onready var plant = preload("res://Entities/RandomFlower.tscn")
onready var pollen = preload("res://Entities/PollenBall.tscn")
onready var plantseed = preload("res://Assets/RigidSeed.tscn")

var pollen_point = Vector3()
var seed_point = Vector3()

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func spawn_seeds():
	for child in self.get_children():
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
				s.determine_nutrients()
			if child.seeds >= 2:
				self.add_child(s2)
				s2.scale = seedscale
				s2.drop_coords = child.seed2coord + Vector3(0,0.1,0)
				s2.reorient()
				var choice = rng.randi_range(0,1)
				s2.alleles.append(child.gene[choice])
				s2.determine_nutrients()
			if child.seeds >=3:
				self.add_child(s3)
				s3.scale = seedscale
				s3.drop_coords = child.seed2coord + Vector3(0,0.1,0)
				s3.reorient()
				var choice = rng.randi_range(0,1)
				s3.alleles.append(child.gene[choice])
				s3.determine_nutrients()


func _on_RigidSeed_sprout():
	pass # Replace with function body.


func _on_RandomFlower_release_seeds():
	spawn_seeds()


func _on_RandomFlower2_release_seeds():
	spawn_seeds()
