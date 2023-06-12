class_name Arena extends VBoxContainer

@onready var enemyZone : HBoxContainer = $EnemyZone
@onready var playerZone : HBoxContainer = $PlayerZone

var lanes : Array[Lane] = []

func _ready() -> void:
	lanes.append_array(enemyZone.get_children())
	lanes.append_array(playerZone.get_children())

func add_card(card : Card) -> void:
	for lane in lanes:
		if card.current_lane == lane.number:
			lane.add_card(card)
