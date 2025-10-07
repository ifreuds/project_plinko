extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# Add controlled random horizontal velocity
	# Agent recalculated: ±15 px/s ensures first pin hit (±50 caused skipping)
	var random_velocity = randf_range(-15.0, 15.0)
	linear_velocity = Vector2(random_velocity, 0)

	# Small rotation adds natural variation
	angular_velocity = randf_range(-0.2, 0.2)

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
