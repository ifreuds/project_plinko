extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# Add controlled random horizontal velocity
	# Agent recalculated: ±60 px/s for proper binomial spread
	# (Previous ±15 was too conservative, caused center compression)
	var random_velocity = randf_range(-60.0, 60.0)
	linear_velocity = Vector2(random_velocity, 0)

	# Small rotation adds natural variation
	angular_velocity = randf_range(-0.2, 0.2)

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
