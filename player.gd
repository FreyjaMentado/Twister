extends CharacterBody3D

@export var speed = 5.0
@export var maxBoost = 5
@export var currentBoost = 0
@export var maxHealth = 5
@export var currentHealth = maxHealth
@onready var leftNearMiss = $MeshInstance3D/LeftNearMiss
@onready var rightNearMiss = $MeshInstance3D/RightNearMiss
@onready var nearMissTimer = $NearMissTimer
@onready var boostTimer = $BoostTimer

var isBoosting = false

signal healthChanged
signal nearMiss
signal startBoost
signal stopBoost

func _physics_process(_delta: float) -> void:
	handle_movement()
	handle_collision()
	handle_near_miss()
	handle_boost()

func handle_movement():
	var input_dir := Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	move_and_slide()

func handle_collision():
	var collision = get_last_slide_collision()
	if collision:
		collision.get_collider().queue_free()
		currentHealth -= 1
		if currentHealth <= 0:
			get_tree().quit()
		if currentBoost > 0:
			currentBoost = max(currentBoost - 2, 0)
		if isBoosting:
			isBoosting = false
		healthChanged.emit()

func handle_boost():
	if isBoosting:
		currentBoost = round(boostTimer.time_left)
	if Input.is_action_just_pressed("boost") and !isBoosting:
		if currentBoost > 0:
			boostTimer.wait_time = currentBoost
			boostTimer.start()
			isBoosting = true
			startBoost.emit()
	if (Input.is_action_just_released("boost") or boostTimer.time_left == 0) and isBoosting:
		isBoosting = false
		currentBoost = round(boostTimer.time_left)
		stopBoost.emit()

func handle_near_miss():
	if (leftNearMiss.is_colliding() or rightNearMiss.is_colliding()) and nearMissTimer.time_left == 0:
		if currentBoost < maxBoost:
			currentBoost += 1
		if isBoosting:
			boostTimer.start(boostTimer.time_left + 1.0)  
		nearMissTimer.start()
		nearMiss.emit()
