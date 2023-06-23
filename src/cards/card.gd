@tool
class_name Card extends Control

# Action-specific vars.
@export var health : int
@export var max_health : int
@export var lane_type : Lane.Types
@export var ready_time : float
@export var energy_cost : int

# Gameplay-specific vars.
@onready var readyTimer : Timer = $ReadyTimer
@onready var progressBar : TextureProgressBar = $CenterContainer/TextureProgressBar
@onready var costLabel : Label = $GUI/Cost

var touch_index : int = -1
var hand_reference : Hand = null
var hand_index : int = -1
var is_pressed : bool = false
var is_selected : bool = false
var target_pos : Vector2 = Vector2.ZERO
var original_pos : Vector2 = Vector2.ZERO
var current_lane : int = 0
var card_state : States = States.WAITING

enum States {
	DEAD, # Not in play
	WAITING, # In the hand
	CARRYING, # Being carried by the touch event
	DROPPABLE, # Is over a valid lane
	ALIVE, # Is alive & in a lane
	EXECUTING, # Is doing its action 
}


func _ready() -> void:
	GameEvents.laneEntered.connect(_on_lane_entered)
	GameEvents.laneExited.connect(_on_lane_exited)
	GameEvents.lanePressed.connect(_on_lane_pressed)
	GameEvents.laneReleased.connect(_on_lane_released)
	GameEvents.cardSelected.connect(_on_card_selected)
	
	readyTimer.wait_time = ready_time
	progressBar.max_value = ready_time
	costLabel.text = str(energy_cost)
	
	await get_tree().process_frame
	original_pos = global_position
	

func _process(delta) -> void:
	progressBar.value = readyTimer.time_left
	if is_pressed:
		global_position = target_pos
		

# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if $TouchScreenButton.is_pressed() and not is_pressed and card_state == States.WAITING and not hand_reference.touch_indexes.has(event.index):
			on_pressed(event)
		elif not $TouchScreenButton.is_pressed() and is_pressed:
			on_released()

	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_index:
			if card_state == States.WAITING:
				card_state = States.CARRYING
			target_pos.x = event.position.x - size.x / 2.0
			target_pos.y = event.position.y - size.y / 2.0


func execute_action() -> void:
	queue_free()
	

func start_deploy_timer() -> void:
	card_state = States.ALIVE
	readyTimer.start()
	
	
func return_to_hand():
	card_state = States.WAITING
	global_position = original_pos


# Is called when the card is selected.
func on_pressed(event : InputEvent) -> void:
	is_pressed = true
	touch_index = event.index
	hand_reference.touch_indexes.append(touch_index)
	target_pos = original_pos
	GameEvents.cardSelected.emit()
	is_selected = true
	# FOR TESTING
	$AnimationPlayer.stop()
	$AnimationPlayer.play("selected")
	

# Is called when the card is dropped.
func on_released() -> void:
	is_pressed = false
	hand_reference.touch_indexes.erase(touch_index)
	touch_index = -1
	if card_state == States.WAITING or card_state == States.CARRYING:
		return_to_hand()
	elif card_state == States.DROPPABLE:
		GameEvents.cardDropped.emit(self)
		

func _on_card_selected() -> void:
	if is_selected:
		is_selected = false
		# FOR TESTING
		$AnimationPlayer.stop()
		$AnimationPlayer.play("deselected")


func _on_lane_entered(index : int, lane : int, type : Lane.Types) -> void:
	if touch_index == index and (card_state == States.CARRYING or card_state == States.DROPPABLE) and (lane_type == type or lane_type == Lane.Types.DEBUG):
		current_lane = lane
		card_state = States.DROPPABLE
		#GameEvents.laneHighlightOn.emit(current_lane)


func _on_lane_exited(index : int, lane : int, type : Lane.Types) -> void:
	if touch_index == index and current_lane == lane and (lane_type == type or lane_type == Lane.Types.DEBUG):
		# This if statement might still be buggy
		current_lane = 0
		card_state = States.CARRYING
		#GameEvents.laneHighlightOff.emit(lane)


func _on_lane_pressed(pos : Vector2, index : int, lane : int, type : Lane.Types) -> void:
	if is_selected and card_state == States.WAITING:
		is_pressed = true
		touch_index = index
		hand_reference.touch_indexes.append(touch_index)
		target_pos.x = pos.x - size.x / 2.0
		target_pos.y = pos.y - size.y / 2.0
		current_lane = lane
		card_state = States.DROPPABLE


func _on_lane_released(pos : Vector2, index : int, lane : int, type : Lane.Types) -> void:
	pass
