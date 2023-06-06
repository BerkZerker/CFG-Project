class_name Main extends Node

var paused = false

@onready var board := $VBoxContainer/Board
@onready var hand := $VBoxContainer/Hand

var player_scene := preload("res://src/cards/objects/entity/player/player_card.tscn")
var selected_cards : Array[ActionCard] = []
var player : PlayerCard


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board.connect_signals(self)
	hand.connect_signals(self)
	player = player_scene.instantiate()
	board.set_card(Vector2i(2, 2), player, self)


func _on_button_pressed() -> void:
	paused = not paused
	get_tree().paused = paused
	if paused: 
		$VBoxContainer/MarginContainer/Button.text = " Play "
	else:
		$VBoxContainer/MarginContainer/Button.text = "Pause"


func _on_action_card_selected(card : ActionCard) -> void:
	selected_cards.append(card)


func _on_action_card_dropped(card : ActionCard) -> void:
	selected_cards.erase(card)
	if card.is_snapped:
		var old_pos = card.board_position
		var old_card = board.get_card(old_pos)
		var player_pos = player.board_position
		board.set_card(player_pos, old_card, self)
		board.set_card(old_pos, player, self)
		

func _on_object_card_pressed(card : ObjectCard) -> void:
	for c in selected_cards:
		if c.touch_index == card.touch_index:
			c.snap_pos = card.global_position
			c.is_snapped = true
			c.board_position = card.board_position
			board.highlight_valid_positions(player, c)
	
	
func _on_object_card_released(card : ObjectCard) -> void:
	pass


func _on_board_entered(touch_index : int) -> void:
	pass


func _on_board_exited(touch_index : int) -> void:
	for c in selected_cards:
		if c.touch_index == touch_index:
			c.is_snapped = false
			
