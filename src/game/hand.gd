@tool

class_name Hand extends HBoxContainer

@export var SIZE: int = 4

var card_scene := preload("res://src/cards/card.tscn")
var cards: Array[Card] = []
var deck: Array[Card] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add the cards.
	for i in range(SIZE):
		new_card()


# JUST FOR TESTING.
func new_card():
	var card = card_scene.instantiate()
	card.card_state = card.States.WAITING
	cards.append(card)
	add_child(card)
