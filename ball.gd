extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# Add microscopic randomness to simulate real-world variations
	# This is critical for proper Galton board distribution
	var tiny_random = randf_range(-0.5, 0.5)
	linear_velocity = Vector2(tiny_random, 0)

	# Also add tiny rotation for extra chaos
	angular_velocity = randf_range(-0.1, 0.1)

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
