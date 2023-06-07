class_name Card extends MarginContainer

var touch_index : int = -1
var is_pressed : bool = false
var target_pos : Vector2

var health : int

@onready var timer := $Timer

enum State {
	SELECTED,
	CARRYING,
	DROPPED,
}


func _process(delta) -> void:
	if is_pressed:
		global_position = target_pos

# This handles if the card is selected, dragged, and dropped.
func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenTouch:
		if $TouchScreenButton.is_pressed() and not is_pressed:
			select(event)
		elif not $TouchScreenButton.is_pressed() and is_pressed:
			drop()

	elif event is InputEventScreenDrag:
		if is_pressed and event.index == touch_index:
			target_pos.x = event.position.x - size.x / 2.0
			target_pos.y = event.position.y - size.y / 2.0
			
				
# Is called when the card is selected.
func select(event : InputEvent) -> void:
	is_pressed = true
	touch_index = event.index
	target_pos.x = event.position.x - size.x / 2.0
	target_pos.y = event.position.y - size.y / 2.0
#	on_action_card_selected.emit(self)
#	#$AnimationPlayer.play("selected")
	
	
# Is called when the card is dropped.
func drop() -> void:
	is_pressed = false
	touch_index = -1
#	on_action_card_dropped.emit(self)
#	#$AnimationPlayer.play("dropped")
#	# JUST FOR TESTING
#	if is_snapped:
#		Input.vibrate_handheld(50)


func _on_area_2d_area_entered(area):
	print('entered')
