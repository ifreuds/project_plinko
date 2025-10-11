extends RefCounted
class_name BoardManager

## Manages board structure: references to static nodes, roads, and goal slots

# Floor node references
var floor_0_nodes: Array[BoardNode] = []  # 3 nodes: A, B, C
var floor_1_nodes: Array[BoardNode] = []  # 4 nodes: D, E, F, G
var floor_2_nodes: Array[BoardNode] = []  # 5 nodes: H, I, J, K, L
var floor_3_nodes: Array[BoardNode] = []  # 6 nodes: M, N, O, P, Q, R

# All roads in the system
var all_roads: Array[Road] = []

# Reference to board node (static scene)
var board_node: Node2D

# Scoring manager reference for goal slot colors
var scoring_mgr: ScoringManager

# Store goal slot references for later updates
var goal_slot_labels: Array = []

func setup(board: Node2D, scoring_manager: ScoringManager):
	"""Initialize board manager with board node reference"""
	board_node = board
	scoring_mgr = scoring_manager

func reference_static_nodes():
	"""Reference existing nodes from the static scene instead of creating them"""

	# Floor 0 nodes
	floor_0_nodes = [
		board_node.get_node("NodeA"),
		board_node.get_node("NodeB"),
		board_node.get_node("NodeC")
	]

	# Floor 1 nodes
	floor_1_nodes = [
		board_node.get_node("NodeD"),
		board_node.get_node("NodeE"),
		board_node.get_node("NodeF"),
		board_node.get_node("NodeG")
	]

	# Floor 2 nodes
	floor_2_nodes = [
		board_node.get_node("NodeH"),
		board_node.get_node("NodeI"),
		board_node.get_node("NodeJ"),
		board_node.get_node("NodeK"),
		board_node.get_node("NodeL")
	]

	# Floor 3 nodes
	floor_3_nodes = [
		board_node.get_node("NodeM"),
		board_node.get_node("NodeN"),
		board_node.get_node("NodeO"),
		board_node.get_node("NodeP"),
		board_node.get_node("NodeQ"),
		board_node.get_node("NodeR")
	]

	# Reference all roads
	all_roads = [
		# Floor 0 → Floor 1
		board_node.get_node("RoadA_D"),
		board_node.get_node("RoadA_E"),
		board_node.get_node("RoadB_E"),
		board_node.get_node("RoadB_F"),
		board_node.get_node("RoadC_F"),
		board_node.get_node("RoadC_G"),
		# Floor 1 → Floor 2
		board_node.get_node("RoadD_H"),
		board_node.get_node("RoadD_I"),
		board_node.get_node("RoadE_I"),
		board_node.get_node("RoadE_J"),
		board_node.get_node("RoadF_J"),
		board_node.get_node("RoadF_K"),
		board_node.get_node("RoadG_K"),
		board_node.get_node("RoadG_L"),
		# Floor 2 → Floor 3
		board_node.get_node("RoadH_M"),
		board_node.get_node("RoadH_N"),
		board_node.get_node("RoadI_N"),
		board_node.get_node("RoadI_O"),
		board_node.get_node("RoadJ_O"),
		board_node.get_node("RoadJ_P"),
		board_node.get_node("RoadK_P"),
		board_node.get_node("RoadK_Q"),
		board_node.get_node("RoadL_Q"),
		board_node.get_node("RoadL_R")
	]

	# Link roads to nodes (needed for pathfinding)
	link_roads_to_nodes()

	# Setup goal slot colors based on multipliers
	setup_goal_slots()

	print("Board references complete: %d total nodes + 7 goal slots + %d roads" % [
		floor_0_nodes.size() + floor_1_nodes.size() + floor_2_nodes.size() + floor_3_nodes.size(),
		all_roads.size()
	])

func link_roads_to_nodes():
	"""Connect roads to their source/destination nodes for pathfinding"""
	# Floor 0 → Floor 1
	_link_road(all_roads[0], floor_0_nodes[0], floor_1_nodes[0])  # A → D
	_link_road(all_roads[1], floor_0_nodes[0], floor_1_nodes[1])  # A → E
	_link_road(all_roads[2], floor_0_nodes[1], floor_1_nodes[1])  # B → E
	_link_road(all_roads[3], floor_0_nodes[1], floor_1_nodes[2])  # B → F
	_link_road(all_roads[4], floor_0_nodes[2], floor_1_nodes[2])  # C → F
	_link_road(all_roads[5], floor_0_nodes[2], floor_1_nodes[3])  # C → G

	# Floor 1 → Floor 2
	_link_road(all_roads[6], floor_1_nodes[0], floor_2_nodes[0])   # D → H
	_link_road(all_roads[7], floor_1_nodes[0], floor_2_nodes[1])   # D → I
	_link_road(all_roads[8], floor_1_nodes[1], floor_2_nodes[1])   # E → I
	_link_road(all_roads[9], floor_1_nodes[1], floor_2_nodes[2])   # E → J
	_link_road(all_roads[10], floor_1_nodes[2], floor_2_nodes[2])  # F → J
	_link_road(all_roads[11], floor_1_nodes[2], floor_2_nodes[3])  # F → K
	_link_road(all_roads[12], floor_1_nodes[3], floor_2_nodes[3])  # G → K
	_link_road(all_roads[13], floor_1_nodes[3], floor_2_nodes[4])  # G → L

	# Floor 2 → Floor 3
	_link_road(all_roads[14], floor_2_nodes[0], floor_3_nodes[0])  # H → M
	_link_road(all_roads[15], floor_2_nodes[0], floor_3_nodes[1])  # H → N
	_link_road(all_roads[16], floor_2_nodes[1], floor_3_nodes[1])  # I → N
	_link_road(all_roads[17], floor_2_nodes[1], floor_3_nodes[2])  # I → O
	_link_road(all_roads[18], floor_2_nodes[2], floor_3_nodes[2])  # J → O
	_link_road(all_roads[19], floor_2_nodes[2], floor_3_nodes[3])  # J → P
	_link_road(all_roads[20], floor_2_nodes[3], floor_3_nodes[3])  # K → P
	_link_road(all_roads[21], floor_2_nodes[3], floor_3_nodes[4])  # K → Q
	_link_road(all_roads[22], floor_2_nodes[4], floor_3_nodes[4])  # L → Q
	_link_road(all_roads[23], floor_2_nodes[4], floor_3_nodes[5])  # L → R

func _link_road(road: Road, from: BoardNode, to: BoardNode):
	"""Helper to link a road to its from/to nodes"""
	road.from_node = from
	road.to_node = to
	from.add_exit_road(road)

func reset_road_traffic():
	"""Reset traffic counters on all roads"""
	for road in all_roads:
		road.reset_traffic()

func reset_all_weights():
	"""Reset all road weights to default 50"""
	for road in all_roads:
		road.base_weight = 50.0
		road.default_color = Color(0.5, 0.5, 0.5, 0.8)
		road.width = 2.0
	print("All road weights reset to 50.0")

func get_road_by_index(index: int) -> Road:
	"""Get a road by its index in the all_roads array"""
	if index >= 0 and index < all_roads.size():
		return all_roads[index]
	return null

func get_all_roads() -> Array[Road]:
	return all_roads

func get_floor_0_nodes() -> Array[BoardNode]:
	return floor_0_nodes

func get_floor_1_nodes() -> Array[BoardNode]:
	return floor_1_nodes

func get_floor_2_nodes() -> Array[BoardNode]:
	return floor_2_nodes

func get_floor_3_nodes() -> Array[BoardNode]:
	return floor_3_nodes

func setup_goal_slots():
	"""Reference goal slots and apply initial colors based on multipliers"""
	for i in range(7):
		var goal_slot = board_node.get_node("Goal%d" % i)
		var mult_label = goal_slot.get_node("MultLabel")

		# Get multiplier and color from scoring manager
		var multiplier = scoring_mgr.goal_multipliers[i]
		var color = scoring_mgr.get_multiplier_color(i)

		# Update goal slot color
		goal_slot.color = color

		# Update multiplier label text
		mult_label.text = "%.1fx" % multiplier

func update_goal_multipliers():
	"""Refresh goal slot multiplier labels (called after upgrades)"""
	for i in range(7):
		var goal_slot = board_node.get_node("Goal%d" % i)
		var mult_label = goal_slot.get_node("MultLabel")

		# Get updated multiplier and color from scoring manager
		var multiplier = scoring_mgr.goal_multipliers[i]
		var color = scoring_mgr.get_multiplier_color(i)

		# Update goal slot color
		goal_slot.color = color

		# Update multiplier label text
		mult_label.text = "%.1fx" % multiplier
