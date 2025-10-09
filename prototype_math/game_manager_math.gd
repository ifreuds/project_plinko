extends Node2D

var ball_scene = preload("res://prototype_math/ball_math.tscn")
var slot_counts = [0, 0, 0, 0]  # 4 slots for 3-row board
var total_balls_dropped = 0
var balls_to_drop = 0
var drop_timer = 0.0
var drop_interval = 0.05  # Time between ball drops
var current_speed = 1.0

# Expected probabilities for 3-row board (binomial)
# Slot 0: 1/8 (12.5%), Slot 1: 3/8 (37.5%), Slot 2: 3/8 (37.5%), Slot 3: 1/8 (12.5%)
var expected_counts = [1, 3, 3, 1]  # Out of 8

# Pin modifier tracking
var pin_modifiers = {}  # Dictionary: pin_node -> {counter: int, total_spawned: int}

# Pin statistics tracking
var pin_hit_counts = {}  # Dictionary: pin_node -> int (total balls that hit this pin)
var show_pin_stats = false  # Toggle for showing pin statistics

@onready var ui = $UI
@onready var pin_visuals = $PinVisuals
@onready var slot_visual_labels = [$SlotVisuals/Slot0Count, $SlotVisuals/Slot1Count, $SlotVisuals/Slot2Count, $SlotVisuals/Slot3Count]

func _ready():
	# Build pin node reference array for balls to use
	var pin_nodes = []
	for child in pin_visuals.get_children():
		pin_nodes.append(child)
		# Initialize pin hit counter
		pin_hit_counts[child] = 0
		# Add statistics label to each pin (initially hidden)
		add_stats_label_to_pin(child)

	update_ui()

func _process(delta):
	if balls_to_drop > 0:
		drop_timer += delta
		if drop_timer >= drop_interval:
			drop_timer = 0.0
			spawn_ball()
			balls_to_drop -= 1

func spawn_ball(spawn_position: Vector2 = Vector2.ZERO, start_row: int = 0, start_pos: int = 0):
	var ball = ball_scene.instantiate()
	ball.set_animation_speed(current_speed)
	ball.landed_in_slot.connect(_on_ball_landed)
	ball.game_manager = self
	# Pass pin node references to ball
	ball.pin_node_refs = pin_visuals.get_children()

	# Set custom spawn position if provided, otherwise use spawn point
	if spawn_position != Vector2.ZERO:
		ball.position = spawn_position
		ball.spawn_at_custom_position = true
		ball.current_row = start_row
		ball.current_position_in_row = start_pos

	add_child(ball)
	total_balls_dropped += 1

func _on_ball_landed(slot_number: int):
	slot_counts[slot_number] += 1
	update_ui()
	update_slot_visual(slot_number, slot_counts[slot_number])

func start_drop_sequence(count: int):
	balls_to_drop = count

func reset_statistics():
	# Stop ongoing drops
	balls_to_drop = 0
	drop_timer = 0.0

	# Clear stats
	total_balls_dropped = 0
	slot_counts = [0, 0, 0, 0]

	# Reset pin modifiers
	for pin in pin_modifiers.keys():
		pin_modifiers[pin].counter = 0
		pin_modifiers[pin].total_spawned = 0
		update_pin_visual(pin)

	# Reset pin hit counts
	for pin in pin_hit_counts.keys():
		pin_hit_counts[pin] = 0
		update_pin_stats_visual(pin)

	# Reset slot visual counters
	for i in range(slot_visual_labels.size()):
		slot_visual_labels[i].text = "0"

	update_ui()

func update_ui():
	ui.update_statistics(slot_counts, total_balls_dropped, expected_counts)

func _on_drop_button_pressed():
	var count = ui.get_ball_count()
	start_drop_sequence(count)

func _on_reset_button_pressed():
	reset_statistics()

func _on_speed_button_pressed(speed: float):
	current_speed = speed
	ui.update_speed_label(speed)

func _on_drop_speed_changed(value: float):
	drop_interval = value
	ui.update_drop_speed_label(value)

func _on_toggle_stats_pressed():
	toggle_pin_stats()

func update_slot_visual(slot_number: int, count: int):
	if slot_number < slot_visual_labels.size():
		slot_visual_labels[slot_number].text = str(count)

func add_modifier_to_pin(pin_node: Node2D):
	print("Adding modifier to pin: ", pin_node.name)
	if pin_node not in pin_modifiers:
		pin_modifiers[pin_node] = {
			"counter": 0,
			"total_spawned": 0
		}
		# Add visual elements to pin - needs to counter the pin's 0.05 scale
		var counter_label = Label.new()
		counter_label.name = "CounterLabel"
		counter_label.position = Vector2(-400, 200)  # Below pin (accounting for pin scale)
		counter_label.scale = Vector2(20, 20)  # Scale up to counter pin's 0.05 scale
		counter_label.add_theme_font_size_override("font_size", 12)
		counter_label.add_theme_color_override("font_color", Color(1, 1, 1))
		counter_label.text = "0/4"
		pin_node.add_child(counter_label)

		var spawned_label = Label.new()
		spawned_label.name = "SpawnedLabel"
		spawned_label.position = Vector2(300, -400)  # Top right of pin
		spawned_label.scale = Vector2(16, 16)
		spawned_label.add_theme_font_size_override("font_size", 10)
		spawned_label.add_theme_color_override("font_color", Color(0, 1, 0))
		spawned_label.text = "+0"
		pin_node.add_child(spawned_label)

		# Change pin color to indicate modifier
		pin_node.modulate = Color(0.2, 1, 0.5)  # Growing green color
		print("Modifier added successfully to ", pin_node.name)
	else:
		print("Pin already has modifier")

func remove_modifier_from_pin(pin_node: Node2D):
	if pin_node in pin_modifiers:
		pin_modifiers.erase(pin_node)
		# Remove visual elements
		if pin_node.has_node("CounterLabel"):
			pin_node.get_node("CounterLabel").queue_free()
		if pin_node.has_node("SpawnedLabel"):
			pin_node.get_node("SpawnedLabel").queue_free()
		# Reset color
		pin_node.modulate = Color(0.9063318, 0.7977378, 0.58383155, 1)

func update_pin_visual(pin_node: Node2D):
	if pin_node in pin_modifiers:
		var data = pin_modifiers[pin_node]
		if pin_node.has_node("CounterLabel"):
			pin_node.get_node("CounterLabel").text = "%d/4" % data.counter
		if pin_node.has_node("SpawnedLabel"):
			pin_node.get_node("SpawnedLabel").text = "+%d" % data.total_spawned

func add_stats_label_to_pin(pin_node: Node2D):
	# Add statistics counter label (initially hidden)
	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.position = Vector2(-300, -200)  # Top left of pin
	stats_label.scale = Vector2(16, 16)
	stats_label.add_theme_font_size_override("font_size", 10)
	stats_label.add_theme_color_override("font_color", Color(1, 1, 0))  # Yellow
	stats_label.text = "0"
	stats_label.visible = show_pin_stats
	pin_node.add_child(stats_label)

func update_pin_stats_visual(pin_node: Node2D):
	if pin_node.has_node("StatsLabel"):
		var count = pin_hit_counts[pin_node] if pin_node in pin_hit_counts else 0
		pin_node.get_node("StatsLabel").text = str(count)

func toggle_pin_stats():
	show_pin_stats = !show_pin_stats
	# Update visibility of all pin stats labels
	for pin in pin_visuals.get_children():
		if pin.has_node("StatsLabel"):
			pin.get_node("StatsLabel").visible = show_pin_stats
	ui.update_stats_toggle_label(show_pin_stats)

func notify_ball_hit_pin(pin_node: Node2D, current_ball_row: int, current_ball_pos: int):
	# Track hit count for statistics
	if pin_node in pin_hit_counts:
		pin_hit_counts[pin_node] += 1
		update_pin_stats_visual(pin_node)

	# Handle modifier if present
	if pin_node in pin_modifiers:
		var data = pin_modifiers[pin_node]
		data.counter += 1
		print("Ball hit modified pin ", pin_node.name, " counter: ", data.counter)

		if data.counter >= 4:
			# Spawn extra ball - make 50/50 decision for which direction it goes
			var go_left = randf() < 0.5
			var next_row = current_ball_row + 1
			var next_pos = current_ball_pos if go_left else current_ball_pos + 1

			print("Spawning extra ball: row ", next_row, " pos ", next_pos, " (", "left" if go_left else "right", ")")

			# Spawn ball at this pin's location, but starting from next row
			# The ball will move to the next pin and count normally
			spawn_ball(pin_node.global_position, next_row, next_pos)
			data.total_spawned += 1
			data.counter = 0
			print("Spawned extra ball! Total spawned: ", data.total_spawned)

		update_pin_visual(pin_node)
