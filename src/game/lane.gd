@tool

class_name Lane extends TextureRect

@export var lane_type : String
@export var lane_no : int
@onready var cardQueue := $CenterContainer/CardQueue

var touch_indexes: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if get_global_rect().has_point(event.position):
			# If a touch down happens inside the rect
			if event.pressed and not touch_indexes.has(event.index): 
				touch_indexes[event.index] = true
				# Emit sig
			# If a touch up happens inside the rect
			elif not event.pressed and touch_indexes.has(event.index):
				touch_indexes.erase(event.index)
				# emit sig

	if event is InputEventScreenDrag:
		if get_global_rect().has_point(event.position) and not touch_indexes.has(event.index): 
			touch_indexes[event.index] = true
			get_tree().call_group("cards", "lane_entered", event.index, self)
		elif not get_global_rect().has_point(event.position) and touch_indexes.has(event.index):
			touch_indexes.erase(event.index)
			get_tree().call_group("cards", "lane_exited", event.index, self)


# FOR TESTING
func add_card(card : Card) -> void:
	cardQueue.add_child(card)
	card.card_state = card.States.ALIVE
	card.timer.start()


func highlight_on():
	modulate.a = 0.5


func highlight_off():
	modulate.a = 1
