class_name Card extends Control

var touch_index : int = -1
var is_pressed : bool = false
var target_pos : Vector2 = Vector2.ZERO
var original_pos : Vector2 = Vector2.ZERO
var current_lane : Lane = null
var previous_lane : Lane = null
var card_state : States = States.DEAD

# Action-specific vars.
@export var health : int
@export var max_health : int
@export var deploy_lane : String 
@export var time : float

@onready var timer := $Timer
@onready var progressBar := $CenterContainer/TextureProgressBar

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
	timer.wait_time = time
	progressBar.max_value = time * 1000

func _process(delta) -> void:
	progressBar.value = timer.time_left * 1000
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
	print('card action executed')
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
	if card_state == States.DROPPABLE: # I'll wanna check with main that this is OK first...
		# And tell main that a card was played
		# THIS IS JUST AS A DEMO
		get_parent().new_card()
		get_parent().remove_card(self)
		# Add self to lane.
		current_lane.add_card(self)
		current_lane.highlight_off()
	elif card_state == States.CARRYING:
		card_state = States.WAITING
		# Reset card's position.
		global_position = original_pos


func lane_entered(index : int, lane : Lane) -> void:
	if touch_index == index: 
		# This is for an order-of-operations bug fix.
		previous_lane = current_lane
		current_lane = lane
		if (card_state == States.CARRYING or card_state == States.DROPPABLE) and (deploy_lane == lane.lane_type or deploy_lane == "debug"):
			card_state = States.DROPPABLE
			lane.highlight_on()


func lane_exited(index : int, lane : Lane) -> void:
	# DO NOT TOUCH THIS UNLESS ALL ELSE FAILS -
	if touch_index == index and (current_lane == lane or previous_lane == lane) and lane.touch_indexes.size() == 0 and (deploy_lane == lane.lane_type or deploy_lane == "debug"): 
		card_state = States.CARRYING
		lane.highlight_off()


