@tool

class_name ObjectCard extends Card

var board_position : Vector2i

signal on_object_card_pressed(card : ObjectCard)
signal on_object_card_released(card : ObjectCard)


func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if $TouchScreenButton.is_pressed() and not is_pressed:
			press(event)
		elif not $TouchScreenButton.is_pressed() and is_pressed:
			release()


func press(event : InputEvent) -> void:
	is_pressed = true
	touch_index = event.index
	on_object_card_pressed.emit(self)
	#$AnimationPlayer.play("pressed")
	
	
func release() -> void:
	is_pressed = false
	on_object_card_released.emit(self)
	touch_index = -1
	#$AnimationPlayer.play("released")


func highlight_on() -> void:
	$AnimationPlayer.play("highlight_on")
	

func highlight_off() -> void:
	$AnimationPlayer.play("highlight_off")
	
