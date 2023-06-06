@tool

class_name Hand extends HBoxContainer

@export var SIZE: int = 4

var card_scene := preload("res://src/cards/card.tscn")
var cards: Array[ActionCard] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add the cards.
	for i in range(SIZE):
		var card = card_scene.instantiate()
		cards.append(card)
		add_child(card)


# Called by the main node to connect the signals.
func connect_signals(node: Node) -> void:
	for c in cards:
		c.on_action_card_selected.connect(node._on_action_card_selected)
		c.on_action_card_dropped.connect(node._on_action_card_dropped)
