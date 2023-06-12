@tool

class_name Lane extends TextureRect

@export var type : Types
@export var number : int

@onready var cardQueue : VBoxContainer = $CenterContainer/CardQueue

var touch_indexes: Dictionary = {}

enum Types {
	NONE,
	PLAYER,
	ENEMY,
	DEBUG,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#GameEvents.laneHighlightOn.connect(highlight_on)
	#GameEvents.laneHighlightOff.connect(highlight_off)


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
			GameEvents.laneEntered.emit(event.index, number, type)
		elif not get_global_rect().has_point(event.position) and touch_indexes.has(event.index):
			touch_indexes.erase(event.index)
			GameEvents.laneExited.emit(event.index, number, type)


# FOR TESTING
func add_card(card : Card) -> void:
	card.reparent(cardQueue)
	card.card_state = card.States.ALIVE
	card.timer.start()


func highlight_on(lane_no : int):
	if number == lane_no:
		modulate.a = 0.5


func highlight_off(lane_no : int):
	if number == lane_no:
		modulate.a = 1
