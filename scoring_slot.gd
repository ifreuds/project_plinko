extends Area2D

signal ball_scored(slot_number)

@export var slot_number: int = 0
var ball_count: int = 0

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("remove"):
		ball_count += 1
		ball_scored.emit(slot_number)
		body.remove()

func reset_count():
	ball_count = 0

func get_count() -> int:
	return ball_count
