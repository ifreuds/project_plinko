extends Line2D
class_name Road

## Represents a path between two nodes on adjacent floors
## Contains base_weight which determines probability of units traveling this road

@export var base_weight: float = 50.0  # Default 50/50 split
var from_node: BoardNode = null
var to_node: BoardNode = null

var traffic_count: int = 0  # Track how many units traveled this road (for visualization)

func _ready():
	default_color = Color(0.5, 0.5, 0.5, 0.8)  # Gray line
	width = 2.0

func setup(start_node: BoardNode, end_node: BoardNode) -> void:
	from_node = start_node
	to_node = end_node

	# Set line points from start to end node centers
	# Line2D points are in local coordinates, so we use absolute positions
	var start_pos = start_node.position + start_node.size / 2
	var end_pos = end_node.position + end_node.size / 2

	# Clear existing points and add new ones
	clear_points()
	add_point(start_pos)
	add_point(end_pos)

func increment_traffic() -> void:
	traffic_count += 1
	# Update visual based on traffic (scaled for ~100 units total)
	# With 100 units split across ~30 roads, expect 3-5 units per road average
	if traffic_count >= 10:
		default_color = Color(0.0, 1.0, 0.0, 0.9)  # Green for heavy traffic
		width = 5.0
	elif traffic_count >= 5:
		default_color = Color(1.0, 1.0, 0.0, 0.9)  # Yellow for medium traffic
		width = 3.5
	elif traffic_count >= 1:
		default_color = Color(1.0, 0.5, 0.0, 0.8)  # Orange for light traffic
		width = 2.5
	else:
		default_color = Color(0.5, 0.5, 0.5, 0.6)  # Gray for no traffic yet
		width = 2.0

func reset_traffic() -> void:
	traffic_count = 0
	default_color = Color(0.5, 0.5, 0.5, 0.8)
	width = 2.0
