@tool
class_name Lane extends TextureRect

@export var type : Types
@export var number : int

@onready var cardQueue : VBoxContainer = $CenterContainer/CardQueue

var touch_indexes : Array[int] = []
var card_indexes : Dictionary = {}
var highlight : int = 0

enum Types {
	NONE,
	PLAYER,
	ENEMY,
	DEBUG,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.cardPressed.connect(_on_card_pressed)
	GameEvents.cardReleased.connect(_on_card_released)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if get_global_rect().has_point(event.position):
			# If a touch down happens inside the rect
			if event.pressed and not touch_indexes.has(event.index): 
				touch_indexes.append(event.index)
				GameEvents.lanePressed.emit(event.position, event.index, number, type)
				if card_indexes.has(event.index):
					if card_indexes[event.index] == type:
						highlight += 1
						update_highlight()
			# If a touch up happens inside the rect
			elif not event.pressed and touch_indexes.has(event.index):
				touch_indexes.erase(event.index)
				GameEvents.laneReleased.emit(event.position, event.index, number, type)
				if not card_indexes.has(event.index):
					highlight_off()
				#if highlighted and card_indexes.size() == 0: # This needs to make sure there are 0 cards left.
					highlight_off()

	if event is InputEventScreenDrag:
		if get_global_rect().has_point(event.position) and not touch_indexes.has(event.index): 
			touch_indexes.append(event.index)
			GameEvents.laneEntered.emit(event.index, number, type)
			if card_indexes.has(event.index):
				if card_indexes[event.index] == type:
					highlight_on()
		elif not get_global_rect().has_point(event.position) and touch_indexes.has(event.index):
			touch_indexes.erase(event.index)
			GameEvents.laneExited.emit(event.index, number, type)



# FOR TESTING
func add_card(card : Card) -> void:
	card.reparent(cardQueue)
	card.start_deploy_timer()
	#cardQueue.add_child(card)


func highlight_on():
	modulate.a = 0.5


func highlight_off():)
	modulate.a = 1
	

func update_highlight():
	pass


func _on_card_pressed(index : int, lane_type : Types) -> void:
	if not card_indexes.has(index):
		card_indexes[index] = lane_type


func _on_card_released(index : int, lane_type : Types) -> void:
	if card_indexes.has(index):
		card_indexes.erase(index)
