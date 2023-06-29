class_name Main extends Node

@onready var pauseButton : Button = $VBoxContainer/MarginContainer/PauseButton
@onready var arena : Arena = $VBoxContainer/Arena
@onready var hand : Hand = $VBoxContainer/Hand
@onready var energyBar : ProgressBar = $VBoxContainer/EnergyBar
@onready var energyTimer : Timer = $EnergyTimer
@onready var matchTimer : Timer = $GameTimer
@onready var matchTime : Label = $VBoxContainer/MarginContainer/MatchTime

@export var MAX_ENERGY : int
@export var MATCH_TIME : int
@export var ENERGY_TIME : float

var paused : bool = false
var energy : int = 0
var time_left : int = MATCH_TIME


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameEvents.cardDropped.connect(_on_card_dropped)
	energyBar.max_value = MAX_ENERGY
	energyTimer.wait_time = ENERGY_TIME
	matchTimer.wait_time = MATCH_TIME
	start_new_game()
	

func _process(delta) -> void:
	# Update the energy bar and match time UI
	energyBar.value = energy + (1 - (energyTimer.time_left / energyTimer.wait_time))
	var mins = int(matchTimer.time_left) / 60
	var secs = int(matchTimer.time_left) % 60
	if secs < 10:
		secs = "0" + str(secs)
	matchTime.text = str(mins) + ":" + str(secs)

func _on_pause_button_pressed() -> void:
	paused = not paused
	get_tree().paused = paused
	if paused: 
		pauseButton.text = " Play "
	else:
		pauseButton.text = "Pause"


func _on_card_dropped(card : Card) -> void:
	if energy - card.energy_cost >= 0:
		energy -= card.energy_cost
		var i = card.hand_index
		arena.add_card(card)
		hand.new_card(i)
	else:
		card.return_to_hand()


func _on_energy_timer_timeout() -> void:
	energy += 1
	if energy > MAX_ENERGY:
		energy = MAX_ENERGY
	energyTimer.start()
	

func start_new_game() -> void:
	matchTimer.start()
	energyTimer.start()


func _on_game_timer_timeout() -> void:
	print('game over!')
	paused = true
	get_tree().paused = paused
