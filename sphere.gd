extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	add_constant_central_force(Vector3(0,0,10))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position.z < -5:
		queue_free()

func _on_timer_timeout():
	queue_free()