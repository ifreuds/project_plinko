extends CanvasLayer

@onready var ball_count_input = $Control/VBoxContainer/InputContainer/BallCountInput
@onready var total_label = $Control/VBoxContainer/TotalLabel
@onready var stats_container = $Control/VBoxContainer/StatsContainer
@onready var current_speed_label = $Control/VBoxContainer/SpeedContainer/CurrentSpeedLabel
@onready var drop_speed_value_label = $Control/VBoxContainer/DropSpeedContainer/DropSpeedValueLabel
@onready var toggle_stats_button = $Control/VBoxContainer/InputContainer/ToggleStatsButton

func _ready():
	ball_count_input.text = "1000"

func get_ball_count() -> int:
	return int(ball_count_input.text)

func update_statistics(slot_counts, total_dropped, expected_counts):
	total_label.text = "Total Balls Dropped: %d" % total_dropped

	# Calculate expected counts scaled to actual sample size
	var total_expected = 0
	for count in expected_counts:
		total_expected += count

	# Update each slot's statistics
	for i in range(slot_counts.size()):
		var stat_label = stats_container.get_child(i)

		var actual_count = slot_counts[i]
		var expected_base = expected_counts[i]
		var expected_percent = (float(expected_base) / float(total_expected) * 100.0)
		var expected_scaled = int(float(expected_base) / float(total_expected) * total_dropped) if total_dropped > 0 else expected_base
		var actual_percent = (float(actual_count) / total_dropped * 100.0) if total_dropped > 0 else 0.0

		stat_label.text = "Slot %d | Expected: ~%d (%.1f%%) | Actual: %d (%.1f%%)" % [
			i, expected_scaled, expected_percent, actual_count, actual_percent
		]

		# Color code based on how many balls (heatmap)
		var intensity = clamp(float(actual_count) / (float(expected_scaled) + 10.0), 0.0, 1.0)
		stat_label.modulate = Color(1.0, 1.0 - intensity * 0.5, 1.0 - intensity * 0.5)

func update_speed_label(speed: float):
	current_speed_label.text = " [Current: %dx]" % int(speed)

func update_drop_speed_label(value: float):
	drop_speed_value_label.text = "%.2fs" % value

func update_stats_toggle_label(showing: bool):
	toggle_stats_button.text = "Hide Pin Stats" if showing else "Show Pin Stats"
