extends CanvasLayer

@onready var ball_count_input = $Control/VBoxContainer/InputContainer/BallCountInput
@onready var drop_button = $Control/VBoxContainer/InputContainer/DropButton
@onready var reset_button = $Control/VBoxContainer/InputContainer/ResetButton
@onready var total_label = $Control/VBoxContainer/TotalLabel
@onready var stats_container = $Control/VBoxContainer/StatsContainer

func _ready():
	ball_count_input.text = "128"

func get_ball_count() -> int:
	return int(ball_count_input.text)

func update_statistics(slots, total_dropped, expected_counts):
	total_label.text = "Total Balls Dropped: %d" % total_dropped

	# Update each slot's statistics
	for i in range(min(slots.size(), stats_container.get_child_count())):
		var slot = slots[i]
		var stat_label = stats_container.get_child(i)

		var actual_count = slot.get_count()
		var expected = expected_counts[i]
		var actual_percent = (float(actual_count) / total_dropped * 100.0) if total_dropped > 0 else 0.0
		var expected_percent = (float(expected) / 128.0 * 100.0)

		stat_label.text = "Slot %d | Expected: %d/128 (%.1f%%) | Actual: %d (%.1f%%)" % [
			i, expected, expected_percent, actual_count, actual_percent
		]

		# Color code based on how many balls (heatmap)
		var intensity = clamp(float(actual_count) / (expected + 5), 0.0, 1.0)
		stat_label.modulate = Color(1.0, 1.0 - intensity * 0.5, 1.0 - intensity * 0.5)
