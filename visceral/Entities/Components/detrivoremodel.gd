extends Spatial


onready var Dbody = $BodyDark
onready var lbody = $BodyLight
onready var short_tail = $ShortTail
onready var long_tail = $LongTail
onready var seg_tail = $SegmentedTail
onready var normal_wings = $normalwings
onready var folded_wings = $foldedwings
onready var pilus = $matingpilus
onready var side_eggs = $eggs

var lightbody = false
var wing_kinds = ['Normal','Bent','None']
var wings = ''
var tail_kinds = ['Short','Long','Segmented','None']
var tail = ''

var male = false
var eggs = false


var super = false

#movement

export var jumping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#blank_models()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func blank_models():
	Dbody.visible = false
	lbody.visible = false
	short_tail.visible = false
	long_tail.visible = false
	seg_tail.visible = false
	normal_wings.visible = false
	folded_wings.visible = false
	pilus.visible = false
	side_eggs.visible = false

func set_phenotype():
	#body
	if lightbody == false:
		Dbody.visible = true
	elif lightbody == true:
		lbody.visible = true
	#tail
	if tail == 'Short':
		short_tail.visible = true
	elif tail == 'Long':
		long_tail.visible = true
	elif tail == 'Segmented':
		seg_tail.visible = true
	elif tail == 'None':
		pass
	#wings
	if wings == 'Normal':
		normal_wings.visible = true
	elif wings == 'Bent':
		folded_wings.visible = true
	elif wings == 'None':
		pass
	#super
	if super == true:
		folded_wings.visible = true
		normal_wings.visible = true
		Dbody.visible = true
		lbody.visible = true
		seg_tail.visible = true

func toggle_male():
	if male == false:
		male = true
		pilus.visible = true
	elif male == true:
		male = false
		pilus.visible = false

func toggle_pregnant():
	if eggs == false:
		eggs = true
		side_eggs.visible = true
	elif eggs == true:
		eggs = false
		side_eggs.visible = false

func squash():
	$TailAnim.play("RESET")
	$WingAnim.play("RESET")
	$WingAnim.play("dead")

func crawl():
	$TailAnim.play("RESET")
	if super == true:
		pass #super animations later
	elif tail == 'Short':
		$TailAnim.play("ShortCrawl")
	elif tail == 'Long':
		$TailAnim.play("LongCrawl")
	elif tail == 'Segmented':
		$TailAnim.play("SegCrawl")

func idle():
	$TailAnim.play("RESET")
	$WingAnim.play("RESET")
	if super == true:
		pass #super animations later
	elif wings == 'Normal':
		$WingAnim.play("IdleWing")
	elif wings == 'Bent':
		$WingAnim.play("IdleBent")

func fly():
	$WingAnim.play("RESET")
	if super == true:
		pass #super animations later
	elif wings == 'Normal':
		$WingAnim.play("NormalFly")
	elif wings == 'Bent':
		$WingAnim.play("BentFly")


func _on_PondFly_set_pheno():
	blank_models()
	set_phenotype()
