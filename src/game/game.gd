class_name Main extends Node

var paused = false

#@onready var board := $VBoxContainer/Board
#@onready var hand := $VBoxContainer/Hand
#
#var selected_cards : Array[ActionCard] = []
#var player : PlayerCard


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
#	board.connect_signals(self)
#	hand.connect_signals(self)
#	player = player_scene.instantiate()
#	board.set_card(Vector2i(2, 2), player, self)

func _on_button_pressed() -> void:
	paused = not paused
	get_tree().paused = paused
	if paused: 
		$VBoxContainer/MarginContainer/Button.text = " Play "
	else:
		$VBoxContainer/MarginContainer/Button.text = "Pause"
