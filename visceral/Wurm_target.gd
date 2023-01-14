extends KinematicBody


var drop_coords = Vector3()

signal target_tick

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(drop_coords)
	#print('target found')
	#print(global_transform.origin)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func reparent():
	print(drop_coords)
	var new_parent = self.get_parent().get_parent()
	#for ensuring correct parent is one node up, should be plant controller
	#print(new_parent)
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_transform.origin = drop_coords
	#print(global_transform.origin)

func print_location():
	pass
	#print(self.global_transform.origin)

func _on_delet_timeout():
	queue_free()
