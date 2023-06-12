class_name Main extends Node

@onready var pauseButton : Button = $VBoxContainer/MarginContainer/PauseButton
@onready var arena : Arena = $VBoxContainer/Arena
@onready var hand : Hand = $VBoxContainer/Hand
@onready var energyBar : ProgressBar = $VBoxContainer/EnergyBar
@onready var energyTimer : Timer = $EnergyTimer

@export var MAX_ENERGY : int

var paused : bool = false
var energy : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.cardDropped.connect(_on_card_dropped)
	energyBar.max_value = MAX_ENERGY
	energyTimer.start()
	

func _process(delta) -> void:
	energyBar.value = energy + (1 - (energyTimer.time_left / energyTimer.wait_time))


func _on_pause_button_pressed() -> void:
	paused = not paused
	get_tree().paused = paused
	if paused: 
		pauseButton.text = " Play "
	else:
		pauseButton.text = "Pause"


func _on_card_dropped(card : Card) -> void:
	if energy - card.energy >= 0:
		energy -= card.energy
		arena.add_card(card)
		hand.new_card()
	else:
		card.return_to_hand()


func _on_energy_timer_timeout():
	energy += 1
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	energyTimer.start()
