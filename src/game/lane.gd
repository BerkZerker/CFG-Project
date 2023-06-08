@tool

class_name Lane extends TextureRect

var touch_indexes: Dictionary = {}

signal entered(index)
signal exited(index)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


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
		if get_global_rect().has_point(event.position):
			# If a touch drag enters the rect
			if not touch_indexes.has(event.index): 
				touch_indexes[event.index] = true
				entered.emit(event.index)
				print('drag in')
		else:
			# If a touch drag exits the rect.
			if touch_indexes.has(event.index):
				touch_indexes.erase(event.index)
				exited.emit(event.index)
				print('drag out')
