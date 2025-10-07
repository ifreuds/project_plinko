extends RigidBody2D

# Ball that drops through the Plinko board
# Removed when it enters a scoring slot

func _ready():
	# No initial push - let physics and pin collisions create randomness
	pass

func remove():
	# Use deferred call to avoid physics errors
	call_deferred("queue_free")
