extends Node2D

@onready var ball_scene = preload("res://ball.tscn")
@onready var spawn_point = $SpawnPoint
@onready var ui = $UI
@onready var slots = $Slots.get_children()

var total_balls_dropped = 0
var balls_to_drop = 0
var drop_timer = 0.0
var base_drop_interval = 0.1  # Base time between ball drops
var drop_interval = 0.1  # Current time between ball drops (adjusted by speed)

# Expected probabilities for 7-row board
var expected_counts = [1, 7, 21, 35, 35, 21, 7, 1]  # Out of 128

func _ready():
	# Connect slot signals
	for slot in slots:
		slot.ball_scored.connect(_on_ball_scored)

	update_ui()

func _process(delta):
	if balls_to_drop > 0:
		drop_timer += delta
		if drop_timer >= drop_interval:
			drop_timer = 0.0
			spawn_ball()
			balls_to_drop -= 1

func spawn_ball():
	var ball = ball_scene.instantiate()
	ball.position = spawn_point.position
	add_child(ball)
	total_balls_dropped += 1

func _on_ball_scored(_slot_number):
	update_ui()

func start_drop_sequence(count: int):
	balls_to_drop = count
	drop_timer = 0.0

func reset_statistics():
	total_balls_dropped = 0
	for slot in slots:
		slot.reset_count()
	update_ui()

func update_ui():
	ui.update_statistics(slots, total_balls_dropped, expected_counts)

func _on_drop_button_pressed():
	var count = ui.get_ball_count()
	start_drop_sequence(count)

func _on_reset_button_pressed():
	reset_statistics()

func _on_speed_button_pressed(speed: float):
	# Don't change Engine.time_scale - it breaks physics at high speeds
	# Instead, spawn balls faster by reducing drop interval
	drop_interval = base_drop_interval / speed
	ui.update_speed_label(speed)
