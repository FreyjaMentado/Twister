extends TextureProgressBar

@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player.nearMiss.connect(update)
	player.stopBoost.connect(update)

func update():
	value = player.currentBoost * 100 / player.maxBoost
