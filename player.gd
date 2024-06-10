extends CharacterBody3D

@export var speed = 5.0
@export var maxHealth = 5
@export var currentHealth = maxHealth
@onready var leftNearMiss = $MeshInstance3D/LeftNearMiss
@onready var rightNearMiss = $MeshInstance3D/RightNearMiss

signal healthChanged
signal nearMiss

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_collision()
	handle_near_miss()

func handle_movement():
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# We'll ignore up and down input, just using side to side
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()

func handle_collision():
	var collision = get_last_slide_collision()
	if collision:
		print("Collided with: ", collision.get_collider())
		collision.get_collider().queue_free()
		currentHealth -= 1
		healthChanged.emit()
		print("health: ",currentHealth)
		if currentHealth <= 0:
			get_tree().quit()

func handle_near_miss():
	if (leftNearMiss.is_colliding() or rightNearMiss.is_colliding()) and $NearMissTimer.time_left == 0:
		nearMiss.emit()
		$NearMissTimer.start()
		print("near miss")
