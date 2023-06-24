extends Node

signal cardDropped(card : Card)
signal cardSelected
signal laneEntered(index : int, lane_no : int, lane_type : Lane.Types)
signal laneExited(index : int, lane_no : int, lane_type : Lane.Types)
signal lanePressed(position : Vector2, index : int, lane_no : int, lane_type : String)
signal laneReleased(position : Vector2, index :int, lane_no : int, lane_type : String)
signal addLaneHighlight(lane_no : int)
signal subtractLaneHighlight(lane_no : int)
