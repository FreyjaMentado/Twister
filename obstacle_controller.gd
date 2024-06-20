extends Node3D

var projectile = preload("res://sphere.tscn")

func _on_obstacle_timer_timeout():
	var projCopy = projectile.instantiate()
	add_child(projCopy)
	var z = randi_range(55,65)
	var x = randi_range(-10,10)
	projCopy.apply_central_impulse(Vector3(x, 0, z))
	var time = randf_range(.2,1.5)
	$ObstacleTimer.start(time)
