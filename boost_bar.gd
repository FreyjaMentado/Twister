extends TextureProgressBar

@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player.nearMiss.connect(update)
	player.stopBoost.connect(update)
	player.healthDecreased.connect(update)

func update():
	value = player.currentBoost * 100 / player.maxBoost

func _physics_process(_delta):
	boosting()

func boosting():
	if player.isBoosting:
		value = player.boostTimer.time_left * 100 / player.maxBoost
