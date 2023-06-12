class_name Card extends Control

var touch_index : int = -1
var is_pressed : bool = false
var target_pos : Vector2 = Vector2.ZERO
var original_pos : Vector2 = Vector2.ZERO
var current_lane : int = 0
var card_state : States = States.DEAD

# Action-specific vars.
@export var health : int
@export var max_health : int
@export var lane_type : Lane.Types
@export var time : float
@export var energy : int

@onready var timer : Timer = $Timer
@onready var progressBar : TextureProgressBar = $CenterContainer/TextureProgressBar
@onready var cost : Label = $GUI/Cost

enum States {
	DEAD, # Not in play
	WAITING, # In the hand
	SELECTED, # Clicked on, but still in the hand
	CARRYING, # Being carried by the touch event
	DROPPABLE, # Is over a valid lane
	ALIVE, # Is alive & in a lane
	EXECUTING, # Is doing its action 
}


func _ready() -> void:
	GameEvents.laneEntered.connect(_on_lane_entered)
	GameEvents.laneExited.connect(_on_lane_exited)
	timer.wait_time = time
	progressBar.max_value = time
	cost.text = str(energy)

func _process(delta) -> void:
	progressBar.value = timer.time_left
	if is_pressed:
		global_position = target_pos

# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if $TouchScreenButton.is_pressed() and not is_pressed and card_state == States.WAITING:
			select(event)
		elif not $TouchScreenButton.is_pressed() and is_pressed:
			drop()

	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_index:
			if card_state == States.SELECTED:
				card_state = States.CARRYING
			target_pos.x = event.position.x - size.x / 2.0
			target_pos.y = event.position.y - size.y / 2.0


func execute_action() -> void:
	queue_free()
			
				
# Is called when the card is selected.
func select(event : InputEvent) -> void:
	is_pressed = true
	touch_index = event.index
	target_pos = global_position
	original_pos = global_position
	card_state = States.SELECTED
	
	
# Is called when the card is dropped.
func drop() -> void:
	is_pressed = false
	touch_index = -1
	if card_state == States.DROPPABLE:
		GameEvents.cardDropped.emit(self)
	elif card_state == States.CARRYING:
		return_to_hand()


func return_to_hand():
	card_state = States.WAITING
	global_position = original_pos


func _on_lane_entered(index : int, lane : int, type : Lane.Types) -> void:
	if touch_index == index and (card_state == States.CARRYING or card_state == States.DROPPABLE) and (lane_type == type or lane_type == Lane.Types.DEBUG):
		current_lane = lane
		card_state = States.DROPPABLE
		#GameEvents.laneHighlightOn.emit(current_lane)


func _on_lane_exited(index : int, lane : int, type : Lane.Types) -> void:
	if touch_index == index and current_lane == lane and (lane_type == type or lane_type == Lane.Types.DEBUG):
		current_lane = 0
		card_state = States.CARRYING
		#GameEvents.laneHighlightOff.emit(lane)
		
		


