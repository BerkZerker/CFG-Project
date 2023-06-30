extends Node

signal cardSelected
signal cardDropped(card : Card)
signal cardPressed(index : int, lane_type : Lane.Types)
signal cardReleased(index : int, lane_type : Lane.Types)
signal laneEntered(index : int, lane_no : int, lane_type : Lane.Types)
signal laneExited(index : int, lane_no : int, lane_type : Lane.Types)
signal lanePressed(position : Vector2, index : int, lane_no : int, lane_type : String)
signal laneReleased(position : Vector2, index :int, lane_no : int, lane_type : String)
