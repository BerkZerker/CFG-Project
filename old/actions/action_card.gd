@tool

class_name ActionCard extends Card

var original_position : Vector2
var target_pos : Vector2
var snap_pos : Vector2
var is_snapped : bool = false
var board_position : Vector2i
var valid_positions : Array[Vector2i]
var affected_positions : Array[Vector2i]

signal on_action_card_selected(card : ActionCard)
signal on_action_card_dropped(card : ActionCard)


func _process(delta) -> void:
	if is_pressed:
		global_position = target_pos

# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if $TouchScreenButton.is_pressed() and not is_pressed:
			select(event)
			if not is_snapped:
				target_pos.x = event.position.x - size.x / 2.0
				target_pos.y = event.position.y - size.y / 2.0
		elif not $TouchScreenButton.is_pressed() and is_pressed:
			drop()

	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_index:
			if is_snapped:
				target_pos = snap_pos
			else:
				target_pos.x = event.position.x - size.x / 2.0
				target_pos.y = event.position.y - size.y / 2.0
			
				
# Is called when the card is selected.
func select(event : InputEvent) -> void:
	is_pressed = true
	touch_index = event.index
	on_action_card_selected.emit(self)
	#$AnimationPlayer.play("selected")
	
	
# Is called when the card is dropped.
func drop() -> void:
	is_pressed = false
	touch_index = -1
	on_action_card_dropped.emit(self)
	#$AnimationPlayer.play("dropped")
	# JUST FOR TESTING
	if is_snapped:
		Input.vibrate_handheld(50)
