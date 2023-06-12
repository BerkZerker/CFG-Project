extends Node

signal cardDropped(card : Card)
signal laneEntered(index : int, lane_no : int, lane_type : Lane.Types)
signal laneExited(index : int, lane_no : int, lane_type : Lane.Types)
#signal lanePressed(index : int, lane_no : int, lane_type : String)
#signal laneReleased(index : int, lane_no : int, lane_type : String)
