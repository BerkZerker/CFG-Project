@tool
class_name Lane extends TextureRect

@export var type : Types
@export var number : int

@onready var cardQueue : VBoxContainer = $CenterContainer/CardQueue

var touch_indexes : Array[int] = []
var card_indexes : Dictionary = {}
var hover : bool = false

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
	await get_tree().process_frame
	pivot_offset.x = size.x / 2.0
	pivot_offset.y = size.y / 2.0


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
				update_animation()
			# If a touch up happens inside the rect
			elif not event.pressed and touch_indexes.has(event.index):
				touch_indexes.erase(event.index)
				GameEvents.laneReleased.emit(event.position, event.index, number, type)
				update_animation()
				
	if event is InputEventScreenDrag:
		# If a finger is dragged into the rect.
		if get_global_rect().has_point(event.position) and not touch_indexes.has(event.index): 
			touch_indexes.append(event.index)
			GameEvents.laneEntered.emit(event.index, number, type)
			update_animation()
		# If a finger is dragged out of the rect.
		elif not get_global_rect().has_point(event.position) and touch_indexes.has(event.index):
			touch_indexes.erase(event.index)
			GameEvents.laneExited.emit(event.index, number, type)
			update_animation()


# FOR TESTING !
func add_card(card : Card) -> void:
	card.reparent(cardQueue)
	card.start_deploy_timer()
	

func update_animation() -> void:
	for t in touch_indexes: # t is an int touch index
		for c in card_indexes: # c is an int as well, with a Type 
			if t == c:
				if card_indexes[c] == type: # The card can be dropped in this lane.
					if not hover:
						hover = true
						$AnimationPlayer.play("entered")
	
	if hover and touch_indexes.size() == 0:
		hover = false
		$AnimationPlayer.play("exited")
	

func _on_card_pressed(index : int, lane_type : Types) -> void:
	if not card_indexes.has(index):
		card_indexes[index] = lane_type


func _on_card_released(index : int, lane_type : Types) -> void:
	if card_indexes.has(index):
		card_indexes.erase(index)
