extends TextureProgressBar

@export var player: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player.healthChanged.connect(update)
	update()

func update():
	value = player.currentHealth * 100 / player.maxHealth