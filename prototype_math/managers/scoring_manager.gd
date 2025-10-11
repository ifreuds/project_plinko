extends RefCounted
class_name ScoringManager

## Manages scoring calculations based on goal slot landings and multipliers

# Scoring constants
const BASE_POINTS_PER_UNIT: int = 10

# Goal multipliers [slot 0, 1, 2, 3, 4, 5, 6]
var goal_multipliers: Array[float] = [5.0, 0.0, 1.0, 2.0, 1.0, 0.0, 5.0]

func calculate_score(goal_counts: Array[int]) -> int:
	"""Calculate total score based on units in each goal slot and their multipliers"""
	var total_score = 0

	for i in range(7):
		var units = goal_counts[i]
		var multiplier = goal_multipliers[i]
		var slot_score = units * multiplier * BASE_POINTS_PER_UNIT
		total_score += int(slot_score)

	return total_score

func calculate_goal_score(goal_index: int, goal_counts: Array[int]) -> int:
	"""Calculate score for a single goal slot"""
	if goal_index < 0 or goal_index >= 7:
		return 0

	var units = goal_counts[goal_index]
	var multiplier = goal_multipliers[goal_index]
	return int(units * multiplier * BASE_POINTS_PER_UNIT)

func get_multiplier(goal_index: int) -> float:
	"""Get the multiplier for a specific goal slot"""
	if goal_index < 0 or goal_index >= 7:
		return 0.0
	return goal_multipliers[goal_index]

func get_multiplier_color(goal_index: int) -> Color:
	"""Get color object for a goal slot based on multiplier value"""
	var mult = get_multiplier(goal_index)
	if mult == 5.0:
		return Color(0, 1, 0.5, 1)  # Green/lime - Jackpot
	elif mult == 0.0:
		return Color(0.9, 0.1, 0.1, 1)  # Red - Bust
	elif mult == 2.0:
		return Color(1, 0.8, 0, 1)  # Yellow/gold - Good value
	else:  # 1x
		return Color(0.7, 0.6, 0.3, 1)  # Tan/gold - Safe

func get_multiplier_color_name(goal_index: int) -> String:
	"""Get color name string for BBCode formatting"""
	var mult = get_multiplier(goal_index)
	if mult == 5.0:
		return "lime"  # Jackpot
	elif mult == 0.0:
		return "red"  # Bust
	elif mult == 2.0:
		return "yellow"  # Good value
	else:  # 1x
		return "white"  # Safe
