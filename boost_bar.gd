extends TextureProgressBar

@export var player: CharacterBody3D

func _physics_process(_delta):
	boosting()

func boosting():
	if player.isBoosting:
		value = player.boostTimer.time_left * 100 / player.maxBoost
	else:
		value = player.currentBoost * 100 / player.maxBoost
