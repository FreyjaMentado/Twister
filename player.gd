extends CharacterBody3D

@export var speed = 5.0
@export var maxBoost = 5
@export var currentBoost = 0
@export var maxHealth = 5
@export var currentHealth = maxHealth
@onready var NearMissBox = $MeshInstance3D/NearMissBox
@onready var nearMissTimer = $NearMissTimer
@onready var boostTimer = $BoostTimer
@onready var collisionSFX = $Collision
@onready var maxSpeedSFX = preload("res://sfx/truckMaxSpeed.ogg")
@onready var accelSFX = preload("res://sfx/truck_accelerate.ogg")

var isBoosting = false
var isMaxSpeed = false

signal healthDecreased
signal healthIncreased
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
		if collision.get_collider().is_in_group("wrench"):
			currentHealth = min(currentHealth + 1, maxHealth)
			healthIncreased.emit()
		else:
			currentHealth -= 1
			healthDecreased.emit()
			collisionSFX.stream = load("res://sfx/box/wood-smash-1-170410.mp3")
			collisionSFX.play()
			$EngineSFX.set_volume_db(-6)
			$EngineSFX.stream = accelSFX
			isMaxSpeed = false
			$EngineSFX.play()
		collision.get_collider().queue_free()
		if currentHealth <= 0:
			SceneSwitcher.switch_scene("res://endScreen/score_menu.tscn")
		if currentBoost > 0:
			currentBoost = max(currentBoost - 2, 0)
		if isBoosting:
			isBoosting = false

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
	if NearMissBox.has_overlapping_bodies() and nearMissTimer.time_left == 0:
		if currentBoost < maxBoost:
			currentBoost = min(currentBoost + 1, maxBoost)
		if isBoosting:
			boostTimer.start(boostTimer.time_left + 1.0)  
		nearMissTimer.start()
		nearMiss.emit()

func _on_near_miss_box_area_entered(area):
	if area.is_in_group("tornado"):
		SceneSwitcher.switch_scene("res://endScreen/score_menu.tscn")

func _on_engine_sfx_finished():
	$EngineSFX.set_volume_db(min($EngineSFX.volume_db + 3, 6))
	if $EngineSFX.volume_db == 6:
		$EngineSFX.stream = maxSpeedSFX
		if !isMaxSpeed:
			$EngineSFX.play()
			isMaxSpeed = true
	else:
		$EngineSFX.play()
