extends KinematicBody

var dead = false
var hurt_wurm = false


var gravity = 5
var grav_vec = Vector3()
var direction = Vector3()
var speed = 1.5

var target_prey = Vector3()

var ichor = 20
var stress = 0
var damage = 5

var sound_type = 'plant'

var halted = false
var aggro = false
var hiding = true

var attack1 = false
var attack2 = false
var attack3 = false

onready var sight = $Sight
onready var too_close = $move_limit


onready var claw1range = $Clawunit/claw1zone
onready var anim1 = $Clawunit/ClawAnim

onready var claw2range = $Clawunit2/claw2zone
onready var anim2 = $Clawunit2/ClawAnim

onready var claw3range = $Clawunit3/claw3zone
onready var anim3 = $Clawunit3/ClawAnim

onready var spore = preload("res://Entities/PoisonSporeKinematic.tscn")
var spore_coord = Vector3()
onready var sporepoint = $Sporepoint

var rng = RandomNumberGenerator.new()

var can_spin = false
var spinning = false
var spin_degree = 0

var start_point = Vector3()

var size = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = Vector3(size, size, size)
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grav_vec = Vector3()
	if not is_on_floor():
		grav_vec.y -= gravity
	move_and_slide(grav_vec, Vector3.UP)
	aggro_and_hide()
	if dead == false:
		movement()
		strike()
	
func movement():
	if aggro == true:
		var target_direction = target_prey - self.global_transform.origin
		var near = too_close.get_overlapping_bodies()
		for n in near:
			if n.is_in_group("Prey"):
				if n.parasitized == false:
					$halt_timer.start()
					halted = true
					spinning = true
		if halted == false:
			move_and_slide(target_direction * speed, Vector3.UP)
		spin()

func reparent():
	var newparent = get_parent().get_parent()
	get_parent().remove_child(self)
	newparent.add_child(self)
	self.global_transform.origin = start_point

func spin():
	if can_spin == true:
		can_spin = false
		spinning = true
	if spinning == true:
		rotate_y(deg2rad(spin_degree))

func sporulate():
	var spore_num = rng.randi_range(2,4)
	for n in spore_num:
		spore_coord = sporepoint.global_transform.origin
		var s = spore.instance()
		var x = rng.randf_range(.8, 1)
		var y = rng.randf_range(.8, 1)
		var z = rng.randf_range(.8, 1)
		self.add_child(s)
		s.start_coord = spore_coord
		s.scale = Vector3(x, y, z)
		s.player_spawned = false
		s.reparent()




func take_damage(damage):
	#print('parasite took damage')
	#print(damage)
	ichor -= damage
	if ichor <= 0:
		if dead == false:
			dead = true
			sporulate()
			$deathtime.start()
			anim1.play("Pain")
			anim2.play("Pain")
			anim3.play("Pain")

func strike():
	var area1 = claw1range.get_overlapping_bodies()
	var area2 = claw2range.get_overlapping_bodies()
	var area3 = claw3range.get_overlapping_bodies()
	
	for n in area1:
		if attack1 == false:
			if n.is_in_group('Prey'):
				if n.parasitized == false:
					attack1 = true
					$attackdelay1.start()
					anim1.play("Attack")
				
	for n in area2:
		if attack2 == false:
			if n.is_in_group('Prey'):
				if n.parasitized == false:
					attack2 = true
					$attackdelay2.start()
					anim2.play("Attack")
				
	for n in area3:
		if attack3 == false:
			if n.is_in_group('Prey'):
				if n.parasitized == false:
					attack3 = true
					$attackdelay3.start()
					anim3.play("Attack")
				
func leg_anim():
	var leg_move = rng.randi_range(1,6)
	if leg_move == 1:
		$legs/Clawunit/ClawAnim.play("Pain")
	if leg_move == 2:
		$legs/Clawunit2/ClawAnim.play("Pain")
	if leg_move == 3:
		$legs/Clawunit3/ClawAnim.play("Pain")
	if leg_move == 4:
		$legs/Clawunit/ClawAnim.play_backwards("Pain")
	if leg_move == 5:
		$legs/Clawunit2/ClawAnim.play_backwards("Pain")
	if leg_move == 6:
		$legs/Clawunit3/ClawAnim.play_backwards("Pain")
		
func leg_stop():
	$legs/Clawunit/ClawAnim.stop()
	$legs/Clawunit2/ClawAnim.stop()
	$legs/Clawunit3/ClawAnim.stop()
	
func _on_pokebox_body_entered(body):
	#print(body)
	if attack1 == true:
		if not body.is_in_group("Parasite"):
			if body.is_in_group('Destructible'):
				body.take_damage(damage)
				if body.is_in_group("SmallBug"):
					if body.parasitized == false:
						body.parasitized = true
						print('parasitized!')
				if body.is_in_group('Predator'):
					hurt_wurm == true


func _on_pokebox2_body_entered(body):
	#print(body)
	if attack2 == true:
		if not body.is_in_group("Parasite"):
			if body.is_in_group('Destructible'):
				body.take_damage(damage)
				if body.is_in_group("SmallBug"):
					if body.parasitized == false:
						body.parasitized = true
						print('parasitized!')
				if body.is_in_group('Predator'):
					hurt_wurm == true
						


func _on_pokebox3_body_entered(body):
	#print(body)
	if attack3 == true:
		if not body.is_in_group("Parasite"):
			if body.is_in_group('Destructible'):
				if body.is_in_group("SmallBug"):
					if body.parasitized == false:
						body.parasitized = true
						print('parasitized!')
				if body.is_in_group('Predator'):
					hurt_wurm == true

func aggro_and_hide():
	var things_in_sight = sight.get_overlapping_bodies()
	for thing in things_in_sight:
		if thing.is_in_group('Prey'):
			if thing.parasitized == false:
				if aggro == false:
					hiding = false
					aggro = true
					target_prey = thing.global_transform.origin
				

func _on_Sight_body_entered(body):
	pass


func _on_Sight_body_exited(body):
	var things_in_sight = sight.get_overlapping_bodies()
	for thing in things_in_sight:
		if thing.is_in_group('Prey'):
			if thing.parasitized == false:
				if aggro == false:
					hiding = false
					aggro = true
					target_prey = thing.global_transform.origin
	#re aggro since chase range larger than initial trigger


func _on_spin_cooldown_timeout():
	var choice = rng.randi_range(0,1)
	if choice == 0:
		spin_degree = -1
	if choice == 1:
		spin_degree = 1
	can_spin = true


func _on_spin_time_timeout():
	spinning = false


func _on_halt_timer_timeout():
	halted = false
	spinning = false


func _on_attackdelay1_timeout():
	attack1 = false


func _on_attackdelay2_timeout():
	attack2 = false


func _on_attackdelay3_timeout():
	attack3 = false


func _on_Legtime_timeout():
	if aggro == true:
		leg_anim()
		leg_anim()


func _on_Aggro_out_body_exited(body):
	if body.is_in_group('Prey'):
		aggro = false
		hiding = true
		var things_in_sight = sight.get_overlapping_bodies()
		for thing in things_in_sight:
			if thing.is_in_group('Prey'):
				if thing.parasitized == false:
					aggro = true
					hiding = false


func _on_move_limit_body_exited(body):
	halted = false
	var things_in_sight = sight.get_overlapping_bodies()
	for thing in things_in_sight:
		if thing.is_in_group('Prey'):
			if thing.parasitized == false:
				if aggro == false:
					hiding = false
					aggro = true
					target_prey = thing.global_transform.origin


func _on_deathtime_timeout():
	queue_free()


func _on_DecayTimer_timeout():
	if aggro == true:
		take_damage(2)
		print('parasite decay')


func _on_Timer_timeout():
	hurt_wurm = false
