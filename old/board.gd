@tool

class_name Board extends Control

@export var WIDTH : int = 5
@export var HEIGHT : int = 5
@export var MARGIN : int = 10

var card_scene := preload("res://src/cards/objects/enviromment/enviromment_card.tscn")
var cards : Array = []
var touch_indexes : Dictionary = {}

signal on_board_entered(touch_index : int)
signal on_board_exited(touch_index : int)


func _ready() -> void:
	# Add the cards.
	for x in range(WIDTH):
		cards.append([])
		for y in range(HEIGHT):
			var card = card_scene.instantiate()
			card.board_position = Vector2i(x, y)
			cards[x].append(card)
			card.position.x = x * (card.size.x + MARGIN)
			card.position.y = y * (card.size.y + MARGIN)
			add_child(card)
	
	calculate_size()
			

# Calculates the board's size based on the number of cards & the margin.
func calculate_size() -> void:
	var card = card_scene.instantiate()
	custom_minimum_size.x = WIDTH * (card.size.x + MARGIN) - MARGIN
	custom_minimum_size.y = HEIGHT * (card.size.y + MARGIN) - MARGIN
	

# Called by the main node to connect the signals.
func connect_signals(node : Node) -> void:
	for x in range(WIDTH):
		for y in range(HEIGHT):
				cards[x][y].on_object_card_pressed.connect(node._on_object_card_pressed)
				cards[x][y].on_object_card_released.connect(node._on_object_card_released)


# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if get_rect().has_point(event.position):
			# If a touch down happens inside the rect
			if event.pressed and not touch_indexes.has(event.index): 
				touch_indexes[event.index] = true
				# Emit sig
			# If a touch up happens inside the rect
			elif not event.pressed and touch_indexes.has(event.index):
				touch_indexes.erase(event.index)
				# emit sig

	if event is InputEventScreenDrag:
		if get_rect().has_point(event.position):
			# If a touch drag enters the rect
			if not touch_indexes.has(event.index): 
				touch_indexes[event.index] = true
				on_board_entered.emit(event.index)
		else:
			# If a touch drag exits the rect.
			if touch_indexes.has(event.index):
				touch_indexes.erase(event.index)
				on_board_exited.emit(event.index)


func get_card(pos : Vector2i) -> ObjectCard:
	return cards[pos.x][pos.y]


func set_card(pos : Vector2i, card : ObjectCard, node : Node) -> void:
	var old_card = get_card(pos)
	card.board_position = pos
	card.position.x = pos.x * (card.size.x + MARGIN)
	card.position.y = pos.y * (card.size.y + MARGIN)
	cards[pos.x][pos.y] = card
	add_child(card)
	card.on_object_card_pressed.connect(node._on_object_card_pressed)
	card.on_object_card_released.connect(node._on_object_card_released)
	remove_child(old_card)
	#old_card.queue_free()
	

func move_card(card : ObjectCard, pos : Vector2i) -> void:
	pass


func is_on_board(pos: Vector2i):
	return pos.x >= 0 and pos.x < WIDTH and pos.y >= 0 and pos.y < HEIGHT


func highlight_valid_positions(player : PlayerCard, card : ActionCard) -> void:
	for pos in card.valid_positions:
		var card_pos =Vector2i(player.board_position.x + pos.x, player.board_position.y + pos.y)
		if is_on_board(card_pos):
			get_card(card_pos).highlight_on()
	
