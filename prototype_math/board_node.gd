extends ColorRect
class_name BoardNode

## Represents a node (land) on the Plinko board
## Each node can have multiple exit roads leading to nodes on the floor below

@export var floor_level: int = 0  # 0 = top floor, 3 = final floor before goals
@export var node_id: String = ""  # A, B, C, D, etc.

var exit_roads: Array[Road] = []  # Roads leaving this node

func _ready():
	# Visual setup
	size = Vector2(50, 50)
	color = Color(0.2, 0.4, 0.8, 1.0)  # Blue rectangle

	# Add label showing node ID
	var label = Label.new()
	label.text = node_id
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = size
	add_child(label)

func get_exit_modifier_for_road(road: Road) -> float:
	# For Phase 2a: no modifiers, always return 1.0
	# Phase 2b will add node effects like "Magnet" or "Repulsor"
	return 1.0

func add_exit_road(road: Road) -> void:
	exit_roads.append(road)

func get_exit_roads() -> Array[Road]:
	return exit_roads
