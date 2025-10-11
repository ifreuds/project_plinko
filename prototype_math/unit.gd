extends Node
class_name Unit

## Represents a unit that travels through the Plinko board
## Units make weighted decisions at each node to choose which road to take

var unit_id: int = 0
var current_node: BoardNode = null
var path_history: Array[String] = []  # Track nodes visited: ["A", "D", "H", "M"]
var path_details: Array[String] = []  # Track full details: ["A → D(L,58%)", "D → H(R,42%)"]

func _init(id: int):
	unit_id = id

func get_preference_for_road(_road: Road) -> float:
	# For Phase 2a: no preferences, always return 1.0
	# Phase 2b will add unit types like "Scout" (prefers risky) or "Tank" (prefers safe)
	return 1.0

func add_to_path(node_id_str: String, chosen_direction: String = "", probability: float = 0.0) -> void:
	path_history.append(node_id_str)
	if chosen_direction != "":
		path_details.append("%s → %s(%s,%.1f%%)" % [
			path_history[path_history.size() - 2] if path_history.size() > 1 else "START",
			node_id_str,
			chosen_direction,
			probability * 100
		])

func get_path_summary() -> String:
	return " → ".join(path_history)

func get_path_details() -> String:
	return " | ".join(path_details)
