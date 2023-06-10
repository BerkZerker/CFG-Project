class_name Main extends Node

@onready var pauseButton := $VBoxContainer/MarginContainer/PauseButton

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_pause_button_pressed():
	paused = not paused
	get_tree().paused = paused
	if paused: 
		pauseButton.text = " Play "
	else:
		pauseButton.text = "Pause"
