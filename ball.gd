extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# Add very slight random horizontal velocity for initial variation
	var random_push = randf_range(-5, 5)
	linear_velocity = Vector2(random_push, 0)

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
