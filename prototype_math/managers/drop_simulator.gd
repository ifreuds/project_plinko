extends RefCounted
class_name DropSimulator

## Handles unit pathfinding and weighted routing through the board

# Goal tracking
var goal_counts: Array[int] = [0, 0, 0, 0, 0, 0, 0]  # 7 goal slots (0-6)

# Board manager reference
var board_mgr: BoardManager

func setup(board_manager: BoardManager):
	"""Initialize drop simulator with board manager reference"""
	board_mgr = board_manager

func reset_goal_counts():
	"""Reset goal counts to zero"""
	goal_counts = [0, 0, 0, 0, 0, 0, 0]

func get_goal_counts() -> Array[int]:
	return goal_counts

func drop_unit_silent(unit: Unit, starting_node: BoardNode):
	"""Simulate a single unit dropping WITHOUT path logging (for automated tests)"""
	unit.current_node = starting_node
	unit.add_to_path(starting_node.node_id)

	# Traverse floors 0 → 1 → 2 → 3
	while unit.current_node.floor_level < 3:
		var chosen_road = choose_next_road(unit.current_node, unit)
		chosen_road.increment_traffic()

		# Move to next node
		var next_node = chosen_road.to_node

		# Calculate probability for logging (but don't log it)
		var roads = unit.current_node.get_exit_roads()
		var weights = []
		for road in roads:
			weights.append(calculate_route_probability(road, unit.current_node, unit))
		var total_weight = 0.0
		for w in weights:
			total_weight += w
		var road_idx = roads.find(chosen_road)
		var probability = weights[road_idx] / total_weight if total_weight > 0 else 0.5

		# Determine direction (left or right)
		var direction = "L" if road_idx == 0 else "R"

		unit.add_to_path(next_node.node_id, direction, probability)
		unit.current_node = next_node

	# Unit has reached Floor 3, map to goal slot
	var goal_slot = map_node_to_goal(unit.current_node)
	goal_counts[goal_slot] += 1
	# NO path logging

func drop_unit(unit: Unit, starting_node: BoardNode, path_log: RichTextLabel):
	"""Simulate a single unit dropping through the board with path logging"""
	unit.current_node = starting_node
	unit.add_to_path(starting_node.node_id)

	# Traverse floors 0 → 1 → 2 → 3
	while unit.current_node.floor_level < 3:
		var chosen_road = choose_next_road(unit.current_node, unit)
		chosen_road.increment_traffic()

		# Move to next node
		var next_node = chosen_road.to_node

		# Calculate probability for logging
		var roads = unit.current_node.get_exit_roads()
		var weights = []
		for road in roads:
			weights.append(calculate_route_probability(road, unit.current_node, unit))
		var total_weight = 0.0
		for w in weights:
			total_weight += w
		var road_idx = roads.find(chosen_road)
		var probability = weights[road_idx] / total_weight if total_weight > 0 else 0.5

		# Determine direction (left or right)
		var direction = "L" if road_idx == 0 else "R"

		unit.add_to_path(next_node.node_id, direction, probability)
		unit.current_node = next_node

	# Unit has reached Floor 3, map to goal slot
	var goal_slot = map_node_to_goal(unit.current_node)
	goal_counts[goal_slot] += 1

	# Log path (only first 20 units to avoid overwhelming the UI)
	if unit.unit_id <= 20:
		path_log.append_text("Unit #%d: %s → [b]Goal %d[/b]\n" % [unit.unit_id, unit.get_path_summary(), goal_slot])
	elif unit.unit_id == 21:
		path_log.append_text("[i]... (showing first 20 units only) ...[/i]\n")

func calculate_route_probability(road: Road, from_node: BoardNode, unit: Unit) -> float:
	"""Calculate the final weight for a road choice"""
	var base = road.base_weight
	var node_mod = from_node.get_exit_modifier_for_road(road)
	var unit_pref = unit.get_preference_for_road(road)
	return base * node_mod * unit_pref

func choose_next_road(current_node: BoardNode, unit: Unit) -> Road:
	"""Use weighted random to choose which road the unit takes"""
	var roads = current_node.get_exit_roads()
	var weights = []

	for road in roads:
		weights.append(calculate_route_probability(road, current_node, unit))

	return weighted_random(roads, weights)

func weighted_random(items: Array, weights: Array):
	"""Weighted random selection - higher weight = more likely to be chosen"""
	var total = 0.0
	for w in weights:
		total += w

	var rand_val = randf() * total
	var cumulative = 0.0

	for i in range(items.size()):
		cumulative += weights[i]
		if rand_val <= cumulative:
			return items[i]

	return items[-1]  # Fallback to last item

func map_node_to_goal(final_node: BoardNode) -> int:
	"""Map a Floor 3 node to a goal slot (0-6)"""
	# Floor 3 has 6 nodes: M, N, O, P, Q, R
	# Goals have 7 slots: 0, 1, 2, 3, 4, 5, 6
	# Each node can route to 2 goal slots below it
	# M → 0 or 1
	# N → 1 or 2
	# O → 2 or 3
	# P → 3 or 4
	# Q → 4 or 5
	# R → 5 or 6

	var node_positions = ["M", "N", "O", "P", "Q", "R"]
	var idx = node_positions.find(final_node.node_id)

	if idx == -1:
		push_error("Invalid final node: %s" % final_node.node_id)
		return 3  # Fallback to center

	# Randomly choose left or right goal slot
	return idx + randi_range(0, 1)
