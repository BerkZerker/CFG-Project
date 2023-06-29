@tool
class_name Hand extends Control

@export var SIZE : int
@export var MARGIN : int

var card_scene := preload("res://src/cards/card.tscn")
var cards: Array[Card] = []
var deck: Array[Card] = []
var touch_indexes : Array[int] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add the cards.
	for i in range(SIZE):
		new_card(i)		
#		card.position.x = x * (card.size.x + MARGIN)
#		card.position.y = y * (card.size.y + MARGIN)
#		add_child(card)
	
	calculate_size()
			

# Calculates the board's size based on the number of cards & the margin.
func calculate_size() -> void:
	var card = card_scene.instantiate()
	custom_minimum_size.x = SIZE * (card.size.x + MARGIN) - MARGIN
	custom_minimum_size.y = card.size.y
	card.queue_free()


# Adds a new card at the specified slot in the hand.
func new_card(index : int) -> void:
	var card = card_scene.instantiate()
	card.index_array = touch_indexes
	card.position.x = index * (card.size.x + MARGIN)
	card.card_state = card.States.WAITING
	card.hand_index = index
	cards.append(card)
	add_child(card)
