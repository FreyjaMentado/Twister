extends CanvasLayer

@onready var animator: AnimationPlayer = $ColorRect/AnimationPlayer
@onready var resume_button: Button = find_child("ResumeButton")
@onready var quit_button: Button = find_child("QuitButton")

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			unpause()
		else:
			pause()

func unpause():
	animator.play("Unpause")
	get_tree().paused = false

func pause():
	animator.play("Pause")
	get_tree().paused = true

func _on_quit_button_pressed():
	get_tree().quit()
