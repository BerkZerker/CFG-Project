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
var hand_index : int = -1
var is_pressed : bool = false
var is_button_pressed : bool = false
var is_selected : bool = false
var target_pos : Vector2 = Vector2.ZERO
var original_pos : Vector2 = Vector2.ZERO
var current_lane : int = 0
var previous_lane : int = 0
var card_state : States = States.WAITING
var animation_tween : Tween
var processing : bool = false

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
	target_pos = global_position
	

func _process(delta) -> void:
	progressBar.value = readyTimer.time_left
	if card_state == States.WAITING or card_state == States.CARRYING or card_state == States.DROPPABLE:
		global_position = target_pos


# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if get_global_rect().has_point(event.position):
			if event.pressed and not is_pressed and card_state == States.WAITING:
				on_pressed(event)
			elif not event.pressed and is_pressed:
				on_released()
#		if get_rect().has_point(event.position) and event.pressed and not is_pressed and card_state == States.WAITING:
#			on_pressed(event)
#		elif get_rect().has_point(event.position) and not event.pressed and is_pressed:
#			on_released()

	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_index:
			if card_state == States.WAITING:
				card_state = States.CARRYING
			target_pos.x = event.position.x - (size.x / 2.0)
			target_pos.y = event.position.y - (size.y / 2.0)


func execute_action() -> void:
	queue_free()
	

func start_deploy_timer() -> void:
	card_state = States.ALIVE
	readyTimer.start()
	
	
func return_to_hand() -> void:
	card_state = States.WAITING
	var time = global_position.distance_to(original_pos) / 3300
	if animation_tween:
		animation_tween.kill()
	animation_tween = get_tree().create_tween()
	animation_tween.tween_property(self, "target_pos", original_pos, time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


# Is called when the card is selected.
func on_pressed(event : InputEvent) -> void:
	is_pressed = true
	processing = true
	touch_index = event.index
	target_pos = original_pos
#	target_pos.x = event.position.x - (size.x / 2.0)
#	target_pos.y = event.position.y - (size.y / 2.0)
	GameEvents.cardPressed.emit(touch_index, lane_type)
	GameEvents.cardSelected.emit()
	is_selected = true
	$AnimationPlayer.play("selected")

	
# Is called when the card is dropped.
func on_released() -> void:
	is_pressed = false
	GameEvents.cardReleased.emit(touch_index, lane_type)
	touch_index = -1
	if card_state == States.WAITING or card_state == States.CARRYING:
		return_to_hand()
	elif card_state == States.DROPPABLE:
		GameEvents.cardDropped.emit(self)
		

func _on_card_selected() -> void:
	if is_selected:
		is_selected = false
		$AnimationPlayer.play("deselected")


func _on_lane_entered(index : int, lane : int, type : Lane.Types) -> void:
	if touch_index == index and (card_state == States.CARRYING or card_state == States.DROPPABLE) and (lane_type == type or lane_type == Lane.Types.DEBUG):
		previous_lane = current_lane
		current_lane = lane
		card_state = States.DROPPABLE
		#GameEvents.addLaneHighlight.emit(current_lane)


func _on_lane_exited(index : int, lane : int, type : Lane.Types) -> void:
	if touch_index == index and current_lane == lane and (lane_type == type or lane_type == Lane.Types.DEBUG):
		card_state = States.CARRYING
		#GameEvents.subtractLaneHighlight.emit(current_lane)
		current_lane = 0
	elif previous_lane == lane:
		#GameEvents.subtractLaneHighlight.emit(previous_lane)
		pass


func _on_lane_pressed(pos : Vector2, index : int, lane : int, type : Lane.Types) -> void:
	if is_selected and card_state == States.WAITING and (lane_type == type or lane_type == Lane.Types.DEBUG):
		is_pressed = true
		is_button_pressed = true
		touch_index = index
		if animation_tween:
			animation_tween.kill()
		GameEvents.cardPressed.emit(touch_index, lane_type)
		target_pos.x = pos.x - (size.x / 2.0)
		target_pos.y = pos.y - (size.y / 2.0)
		previous_lane = current_lane
		current_lane = lane
		card_state = States.DROPPABLE
		#GameEvents.addLaneHighlight.emit(current_lane)


func _on_lane_released(pos : Vector2, index : int, lane : int, type : Lane.Types) -> void:
	if current_lane == lane:
		#GameEvents.subtractLaneHighlight.emit(lane)
		pass


func _on_touch_screen_button_pressed() -> void:
	is_button_pressed = true


func _on_touch_screen_button_released() -> void:
	is_button_pressed = false
	if not is_button_pressed and is_pressed:
		on_released()
