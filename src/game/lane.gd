@tool

class_name Lane extends VBoxContainer

@onready var cardDropArea := $CardDropArea
@onready var collisionShape := $CardDropArea/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Resize and reposition the collisionShape whenever the base node changes.
func _on_resized():
	collisionShape.shape.extents.x = get_rect().size.x / 2.0
	collisionShape.shape.extents.y = get_rect().size.y / 2.0
	cardDropArea.position.x += get_rect().size.x / 2.0
	cardDropArea.position.y += get_rect().size.y / 2.0
