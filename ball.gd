extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# Add microscopic randomness to simulate real-world variations
	# This ensures each ball takes a unique path through pins
	var tiny_random = randf_range(-0.1, 0.1)
	linear_velocity = Vector2(tiny_random, 0)

	# Tiny rotation helps with pin collision variation
	angular_velocity = randf_range(-0.2, 0.2)

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
