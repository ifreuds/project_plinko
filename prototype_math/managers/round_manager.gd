extends RefCounted
class_name RoundManager

## Manages round progression, scoring across rounds, and round state

# Round state
var current_round: int = 1
var cumulative_score: int = 0
var round_scores: Array[int] = []
var current_round_score: int = 0

func get_current_round() -> int:
	return current_round

func get_cumulative_score() -> int:
	return cumulative_score

func get_current_round_score() -> int:
	return current_round_score

func set_current_round_score(score: int):
	"""Set the score for the current round (before advancing)"""
	current_round_score = score

func advance_round():
	"""Move to the next round, adding current score to cumulative total"""
	# Add current round score to cumulative
	round_scores.append(current_round_score)
	cumulative_score += current_round_score

	# Advance round
	current_round += 1
	current_round_score = 0

	print("Advanced to Round %d (Cumulative: %d points)" % [current_round, cumulative_score])

func reset():
	"""Reset all round state back to initial values"""
	current_round = 1
	cumulative_score = 0
	round_scores.clear()
	current_round_score = 0
	print("Round state reset")

func get_round_info_text() -> String:
	"""Get formatted text for round info display"""
	return "Round %d | Cumulative Score: %d" % [current_round, cumulative_score]

func get_round_history() -> Array[int]:
	"""Get array of completed round scores"""
	return round_scores
