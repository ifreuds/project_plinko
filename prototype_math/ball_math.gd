extends Node2D

signal landed_in_slot(slot_number)

var current_row = 0
var current_position_in_row = 0  # 0 = leftmost position in row
var max_rows = 3
var animation_speed = 1.0  # Can be increased for speedup
var game_manager = null
var spawn_at_custom_position = false  # Flag for spawning at pin

# Pin positions for 3-row board
var pin_positions = [
	[Vector2(300, 100)],  # Row 0: 1 pin
	[Vector2(250, 200), Vector2(350, 200)],  # Row 1: 2 pins
	[Vector2(200, 300), Vector2(300, 300), Vector2(400, 300)]  # Row 2: 3 pins
]

# Slot positions (4 slots)
var slot_positions = [
	Vector2(150, 400),  # Slot 0
	Vector2(250, 400),  # Slot 1
	Vector2(350, 400),  # Slot 2
	Vector2(450, 400)   # Slot 3
]

# References to actual pin nodes for modifier tracking
var pin_node_refs = []

func _ready():
	# If spawned at custom position (from modified pin), start from there
	if not spawn_at_custom_position:
		position = Vector2(300, 20)
	# Otherwise position and current_row/current_position_in_row are already set by spawn_ball()

	move_to_next_pin()

func move_to_next_pin():
	if current_row >= max_rows:
		# Reached bottom, move to slot
		move_to_slot()
		return

	# Get target pin position
	var target_pos = pin_positions[current_row][current_position_in_row]

	# Animate to pin
	var tween = create_tween()
	var duration = 0.3 / animation_speed
	tween.tween_property(self, "position", target_pos, duration)
	tween.finished.connect(_on_reached_pin)

func _on_reached_pin():
	# Notify game manager - track all pin hits
	if game_manager and pin_node_refs.size() > 0:
		var pin_index = get_pin_index_from_position(current_row, current_position_in_row)
		if pin_index < pin_node_refs.size():
			var pin_node = pin_node_refs[pin_index]
			game_manager.notify_ball_hit_pin(pin_node, current_row, current_position_in_row)

	# Make 50/50 decision: go left or right
	var go_left = randf() < 0.5

	# Calculate position in next row
	current_row += 1
	if go_left:
		current_position_in_row = current_position_in_row  # Stay at same index (go left)
	else:
		current_position_in_row = current_position_in_row + 1  # Move right

	# Move to next pin
	move_to_next_pin()

func get_pin_index_from_position(row: int, pos_in_row: int) -> int:
	# Convert row and position to flat array index
	# Row 0: index 0
	# Row 1: index 1-2
	# Row 2: index 3-5
	var index = 0
	for r in range(row):
		index += r + 1  # Each row has row+1 pins
	index += pos_in_row
	return index

func move_to_slot():
	# Final slot is determined by current_position_in_row
	var slot_number = current_position_in_row
	var target_pos = slot_positions[slot_number]

	# Animate to slot
	var tween = create_tween()
	var duration = 0.3 / animation_speed
	tween.tween_property(self, "position", target_pos, duration)
	tween.finished.connect(func(): _on_reached_slot(slot_number))

func _on_reached_slot(slot_number: int):
	landed_in_slot.emit(slot_number)
	queue_free()

func set_animation_speed(speed: float):
	animation_speed = speed
