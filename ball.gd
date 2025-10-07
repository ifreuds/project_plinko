extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# Add meaningful random horizontal velocity to break symmetry
	# Agent calculated: ±50 pixels/s needed for proper 50/50 distribution
	var random_velocity = randf_range(-50.0, 50.0)
	linear_velocity = Vector2(random_velocity, 0)

	# Small rotation adds natural variation
	angular_velocity = randf_range(-0.2, 0.2)

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
