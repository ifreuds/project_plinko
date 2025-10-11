extends Sprite2D
class_name BoardNode

## Represents a node (land) on the Plinko board
## Each node can have multiple exit roads leading to nodes on the floor below

@export var floor_level: int = 0  # 0 = top floor, 3 = final floor before goals
@export var node_id: String = ""  # A, B, C, D, etc.

var exit_roads: Array[Road] = []  # Roads leaving this node

func _ready():
	# Visual setup
	centered = true

	# Add label showing node ID
	var label = Label.new()
	label.text = node_id
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Position label to cover sprite area (adjust based on your sprite size)
	label.position = Vector2(-25, -25)  # Assuming ~50px sprite after scaling
	label.size = Vector2(50, 50)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))  # White text
	add_child(label)

func get_exit_modifier_for_road(_road: Road) -> float:
	# For Phase 2a: no modifiers, always return 1.0
	# Phase 2b will add node effects like "Magnet" or "Repulsor"
	return 1.0

func add_exit_road(road: Road) -> void:
	exit_roads.append(road)

func get_exit_roads() -> Array[Road]:
	return exit_roads
