extends Node2D

## Game Manager for Prototype 2a
## Handles board setup, unit assignment, weight calculation, and drop simulation

# Floor node references
var floor_0_nodes: Array[BoardNode] = []  # 3 nodes: A, B, C
var floor_1_nodes: Array[BoardNode] = []  # 4 nodes: D, E, F, G
var floor_2_nodes: Array[BoardNode] = []  # 5 nodes: H, I, J, K, L
var floor_3_nodes: Array[BoardNode] = []  # 6 nodes: M, N, O, P, Q, R

# All roads in the system
var all_roads: Array[Road] = []

# Goal tracking
var goal_counts: Array[int] = [0, 0, 0, 0, 0, 0, 0]  # 7 goal slots (0-6)

# UI References (matched to scene structure)
@onready var drop_button: Button = $UI/Panel/VBoxContainer/ButtonContainer/DropButton
@onready var reset_button: Button = $UI/Panel/VBoxContainer/ButtonContainer/ResetButton
@onready var node_a_input: SpinBox = $UI/Panel/VBoxContainer/NodeAContainer/SpinBox
@onready var node_b_input: SpinBox = $UI/Panel/VBoxContainer/NodeBContainer/SpinBox
@onready var node_c_input: SpinBox = $UI/Panel/VBoxContainer/NodeCContainer/SpinBox
@onready var total_label: Label = $UI/Panel/VBoxContainer/TotalLabel
@onready var results_label: RichTextLabel = $UI/Panel/VBoxContainer/ResultsLabel
@onready var path_log: RichTextLabel = $UI/Panel/VBoxContainer/ScrollContainer/PathLog

# Weight testing UI
@onready var road_dropdown: OptionButton = $UI/Panel/VBoxContainer/RoadSelectContainer/RoadDropdown
@onready var weight_slider: HSlider = $UI/Panel/VBoxContainer/WeightSliderContainer/WeightSlider
@onready var weight_value_label: Label = $UI/Panel/VBoxContainer/WeightSliderContainer/WeightValue
@onready var apply_weight_button: Button = $UI/Panel/VBoxContainer/WeightButtonContainer/ApplyWeightButton
@onready var reset_weights_button: Button = $UI/Panel/VBoxContainer/WeightButtonContainer/ResetWeightsButton

func _ready():
	setup_board()
	setup_roads()
	setup_ui()

func setup_board():
	"""Create all board nodes with proper positioning"""
	var start_x = 100
	var start_y = 50
	var floor_spacing_y = 120
	var node_spacing_x = 80

	# Floor 0: 3 nodes (A, B, C)
	var floor_0_ids = ["A", "B", "C"]
	var floor_0_x_offset = start_x + node_spacing_x * 2  # Center the 3 nodes
	for i in range(3):
		var node = BoardNode.new()
		node.floor_level = 0
		node.node_id = floor_0_ids[i]
		node.position = Vector2(floor_0_x_offset + i * node_spacing_x, start_y)
		add_child(node)
		floor_0_nodes.append(node)

	# Floor 1: 4 nodes (D, E, F, G)
	var floor_1_ids = ["D", "E", "F", "G"]
	var floor_1_x_offset = start_x + node_spacing_x * 1.5  # Offset for staggering
	for i in range(4):
		var node = BoardNode.new()
		node.floor_level = 1
		node.node_id = floor_1_ids[i]
		node.position = Vector2(floor_1_x_offset + i * node_spacing_x, start_y + floor_spacing_y)
		add_child(node)
		floor_1_nodes.append(node)

	# Floor 2: 5 nodes (H, I, J, K, L)
	var floor_2_ids = ["H", "I", "J", "K", "L"]
	var floor_2_x_offset = start_x + node_spacing_x  # Further offset
	for i in range(5):
		var node = BoardNode.new()
		node.floor_level = 2
		node.node_id = floor_2_ids[i]
		node.position = Vector2(floor_2_x_offset + i * node_spacing_x, start_y + floor_spacing_y * 2)
		add_child(node)
		floor_2_nodes.append(node)

	# Floor 3: 6 nodes (M, N, O, P, Q, R)
	var floor_3_ids = ["M", "N", "O", "P", "Q", "R"]
	var floor_3_x_offset = start_x + node_spacing_x * 0.5  # Final offset
	for i in range(6):
		var node = BoardNode.new()
		node.floor_level = 3
		node.node_id = floor_3_ids[i]
		node.position = Vector2(floor_3_x_offset + i * node_spacing_x, start_y + floor_spacing_y * 3)
		add_child(node)
		floor_3_nodes.append(node)

	# Goal slots (Floor 4): 7 visual slots (0-6)
	var goal_y = start_y + floor_spacing_y * 4
	for i in range(7):
		var goal = ColorRect.new()
		goal.size = Vector2(50, 50)
		goal.position = Vector2(start_x + i * node_spacing_x, goal_y)
		goal.color = Color(0.8, 0.6, 0.2, 1.0)  # Gold/yellow for goals

		# Add goal number label
		var label = Label.new()
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = goal.size
		label.add_theme_font_size_override("font_size", 20)
		goal.add_child(label)

		add_child(goal)

	print("Board setup complete: %d total nodes + 7 goal slots" % (floor_0_nodes.size() + floor_1_nodes.size() + floor_2_nodes.size() + floor_3_nodes.size()))

func setup_roads():
	"""Create roads connecting nodes between adjacent floors"""
	# Floor 0 → Floor 1
	# Each Floor 0 node connects to 2 Floor 1 nodes
	# A → D, E
	# B → E, F
	# C → F, G
	create_road(floor_0_nodes[0], floor_1_nodes[0])  # A → D
	create_road(floor_0_nodes[0], floor_1_nodes[1])  # A → E
	create_road(floor_0_nodes[1], floor_1_nodes[1])  # B → E
	create_road(floor_0_nodes[1], floor_1_nodes[2])  # B → F
	create_road(floor_0_nodes[2], floor_1_nodes[2])  # C → F
	create_road(floor_0_nodes[2], floor_1_nodes[3])  # C → G

	# Floor 1 → Floor 2
	# D → H, I
	# E → I, J
	# F → J, K
	# G → K, L
	create_road(floor_1_nodes[0], floor_2_nodes[0])  # D → H
	create_road(floor_1_nodes[0], floor_2_nodes[1])  # D → I
	create_road(floor_1_nodes[1], floor_2_nodes[1])  # E → I
	create_road(floor_1_nodes[1], floor_2_nodes[2])  # E → J
	create_road(floor_1_nodes[2], floor_2_nodes[2])  # F → J
	create_road(floor_1_nodes[2], floor_2_nodes[3])  # F → K
	create_road(floor_1_nodes[3], floor_2_nodes[3])  # G → K
	create_road(floor_1_nodes[3], floor_2_nodes[4])  # G → L

	# Floor 2 → Floor 3
	# H → M, N
	# I → N, O
	# J → O, P
	# K → P, Q
	# L → Q, R
	create_road(floor_2_nodes[0], floor_3_nodes[0])  # H → M
	create_road(floor_2_nodes[0], floor_3_nodes[1])  # H → N
	create_road(floor_2_nodes[1], floor_3_nodes[1])  # I → N
	create_road(floor_2_nodes[1], floor_3_nodes[2])  # I → O
	create_road(floor_2_nodes[2], floor_3_nodes[2])  # J → O
	create_road(floor_2_nodes[2], floor_3_nodes[3])  # J → P
	create_road(floor_2_nodes[3], floor_3_nodes[3])  # K → P
	create_road(floor_2_nodes[3], floor_3_nodes[4])  # K → Q
	create_road(floor_2_nodes[4], floor_3_nodes[4])  # L → Q
	create_road(floor_2_nodes[4], floor_3_nodes[5])  # L → R

	print("Roads setup complete: %d total roads" % all_roads.size())

func create_road(from: BoardNode, to: BoardNode) -> Road:
	"""Helper to create and configure a road"""
	var road = Road.new()
	road.setup(from, to)
	add_child(road)
	from.add_exit_road(road)
	all_roads.append(road)
	return road

func setup_ui():
	"""Configure UI elements and connect signals"""
	# Set initial values
	node_a_input.value = 30
	node_b_input.value = 40
	node_c_input.value = 30

	# Connect signals
	drop_button.pressed.connect(_on_drop_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	node_a_input.value_changed.connect(_on_unit_assignment_changed)
	node_b_input.value_changed.connect(_on_unit_assignment_changed)
	node_c_input.value_changed.connect(_on_unit_assignment_changed)

	# Weight testing signals
	road_dropdown.item_selected.connect(_on_road_selected)
	weight_slider.value_changed.connect(_on_weight_slider_changed)
	apply_weight_button.pressed.connect(_on_apply_weight_pressed)
	reset_weights_button.pressed.connect(_on_reset_weights_pressed)

	_update_total_label()
	_populate_road_dropdown()

func _on_unit_assignment_changed(_value):
	"""Update UI when unit assignment changes"""
	_update_total_label()

func _update_total_label():
	"""Update the total units label and validate assignment"""
	var total = int(node_a_input.value) + int(node_b_input.value) + int(node_c_input.value)
	total_label.text = "Total: %d units" % total

	# Validation - just check that total is reasonable (1-300)
	var is_valid = total >= 1 and total <= 300

	drop_button.disabled = not is_valid

	if not is_valid:
		total_label.add_theme_color_override("font_color", Color.RED)
	else:
		total_label.add_theme_color_override("font_color", Color.GREEN)

func _on_drop_pressed():
	"""Handle drop button press - simulate unit drops"""
	print("\n=== STARTING DROP ===")

	# Reset goal counts
	goal_counts = [0, 0, 0, 0, 0, 0, 0]

	# Reset road traffic
	for road in all_roads:
		road.reset_traffic()

	# Clear path log
	path_log.clear()
	path_log.append_text("[b]=== DROP LOG ===[/b]\n\n")

	# Get unit assignments
	var assignments = [
		int(node_a_input.value),
		int(node_b_input.value),
		int(node_c_input.value)
	]

	var unit_counter = 1

	# Drop units from each starting node
	for node_idx in range(3):
		var num_units = assignments[node_idx]
		var starting_node = floor_0_nodes[node_idx]

		for i in range(num_units):
			var unit = Unit.new(unit_counter)
			drop_unit(unit, starting_node)
			unit_counter += 1

	# Display results
	display_results()

func drop_unit(unit: Unit, starting_node: BoardNode):
	"""Simulate a single unit dropping through the board"""
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

func display_results():
	"""Display goal distribution statistics with expected vs actual"""
	var total_units = 0
	for count in goal_counts:
		total_units += count

	# Calculate expected distribution based on current weights
	var expected_probs = calculate_expected_distribution()

	var result_text = "\n[b]=== GOAL DISTRIBUTION ===[/b]\n"
	result_text += "(%d units dropped)\n\n" % total_units
	result_text += "[color=gray]Goal | Actual | Expected | Diff[/color]\n"

	for i in range(7):
		var count = goal_counts[i]
		var actual_percent = (float(count) / total_units * 100.0) if total_units > 0 else 0.0
		var expected_percent = expected_probs[i] * 100.0
		var diff = actual_percent - expected_percent
		var bar = _create_bar(actual_percent)

		var diff_color = "green" if abs(diff) < 2.0 else ("yellow" if abs(diff) < 5.0 else "red")
		result_text += "  %d  | %5.1f%% | %5.1f%% | [color=%s]%+.1f%%[/color] %s\n" % [
			i, actual_percent, expected_percent, diff_color, diff, bar
		]

	# Calculate center vs edge distribution
	var center = goal_counts[3] + goal_counts[4]
	var center_percent = (float(center) / total_units * 100.0) if total_units > 0 else 0.0
	var expected_center = (expected_probs[3] + expected_probs[4]) * 100.0
	result_text += "\nCenter (3+4): %.1f%% actual vs %.1f%% expected\n" % [center_percent, expected_center]

	results_label.text = result_text
	print(result_text)

func _create_bar(percent: float) -> String:
	"""Create ASCII bar chart"""
	var bar_length = int(percent / 5.0)  # Each block = 5%
	var bar = ""
	for i in range(bar_length):
		bar += "■"
	for i in range(20 - bar_length):
		bar += "░"
	return "[%s]" % bar

func _on_reset_pressed():
	"""Reset all statistics and UI"""
	goal_counts = [0, 0, 0, 0, 0, 0, 0]
	for road in all_roads:
		road.reset_traffic()
	path_log.clear()
	results_label.text = ""
	print("Reset complete")

# Weight testing functions
func _populate_road_dropdown():
	"""Fill dropdown with all road options"""
	road_dropdown.clear()

	for i in range(all_roads.size()):
		var road = all_roads[i]
		var road_name = "%s → %s" % [road.from_node.node_id, road.to_node.node_id]
		road_dropdown.add_item(road_name, i)

	# Select first road
	if all_roads.size() > 0:
		road_dropdown.select(0)
		_on_road_selected(0)

func _on_road_selected(index: int):
	"""Update slider when a different road is selected"""
	if index >= 0 and index < all_roads.size():
		var selected_road = all_roads[index]
		weight_slider.value = selected_road.base_weight
		weight_value_label.text = str(int(selected_road.base_weight))

func _on_weight_slider_changed(value: float):
	"""Update label when slider moves"""
	weight_value_label.text = str(int(value))

func _on_apply_weight_pressed():
	"""Apply the selected weight to the selected road"""
	var selected_index = road_dropdown.selected
	if selected_index >= 0 and selected_index < all_roads.size():
		var selected_road = all_roads[selected_index]
		var new_weight = weight_slider.value

		selected_road.base_weight = new_weight

		# Visual feedback - highlight modified roads
		if new_weight != 50.0:
			selected_road.default_color = Color(1.0, 0.0, 1.0, 0.9)  # Magenta for modified
			selected_road.width = 4.0
		else:
			selected_road.default_color = Color(0.5, 0.5, 0.5, 0.8)  # Gray for default
			selected_road.width = 2.0

		print("Applied weight %.0f to road: %s → %s" % [new_weight, selected_road.from_node.node_id, selected_road.to_node.node_id])

func _on_reset_weights_pressed():
	"""Reset all road weights to default 50"""
	for road in all_roads:
		road.base_weight = 50.0
		road.default_color = Color(0.5, 0.5, 0.5, 0.8)
		road.width = 2.0

	# Update slider to show current road's weight
	var selected_index = road_dropdown.selected
	if selected_index >= 0 and selected_index < all_roads.size():
		_on_road_selected(selected_index)

	print("All road weights reset to 50.0")

func calculate_expected_distribution() -> Array[float]:
	"""Calculate expected probability for each goal based on current road weights"""
	# We'll track probability distribution at each floor
	# Start with unit assignment from Floor 0
	var total_assigned = node_a_input.value + node_b_input.value + node_c_input.value

	# Floor 0 probabilities (where units start)
	var floor_0_probs = [
		node_a_input.value / float(total_assigned),  # Node A
		node_b_input.value / float(total_assigned),  # Node B
		node_c_input.value / float(total_assigned)   # Node C
	]

	# Floor 1 probabilities (4 nodes: D, E, F, G)
	var floor_1_probs = [0.0, 0.0, 0.0, 0.0]

	# From A: can go to D or E
	var a_exits = floor_0_nodes[0].get_exit_roads()
	var a_weights = []
	for road in a_exits:
		a_weights.append(road.base_weight)
	var a_total = a_weights[0] + a_weights[1]
	floor_1_probs[0] += floor_0_probs[0] * (a_weights[0] / a_total)  # A → D
	floor_1_probs[1] += floor_0_probs[0] * (a_weights[1] / a_total)  # A → E

	# From B: can go to E or F
	var b_exits = floor_0_nodes[1].get_exit_roads()
	var b_weights = []
	for road in b_exits:
		b_weights.append(road.base_weight)
	var b_total = b_weights[0] + b_weights[1]
	floor_1_probs[1] += floor_0_probs[1] * (b_weights[0] / b_total)  # B → E
	floor_1_probs[2] += floor_0_probs[1] * (b_weights[1] / b_total)  # B → F

	# From C: can go to F or G
	var c_exits = floor_0_nodes[2].get_exit_roads()
	var c_weights = []
	for road in c_exits:
		c_weights.append(road.base_weight)
	var c_total = c_weights[0] + c_weights[1]
	floor_1_probs[2] += floor_0_probs[2] * (c_weights[0] / c_total)  # C → F
	floor_1_probs[3] += floor_0_probs[2] * (c_weights[1] / c_total)  # C → G

	# Floor 2 probabilities (5 nodes: H, I, J, K, L)
	var floor_2_probs = [0.0, 0.0, 0.0, 0.0, 0.0]
	for i in range(4):  # For each Floor 1 node
		var exits = floor_1_nodes[i].get_exit_roads()
		var weights = []
		for road in exits:
			weights.append(road.base_weight)
		var total = weights[0] + weights[1]

		# Each Floor 1 node connects to 2 Floor 2 nodes
		var left_idx = i
		var right_idx = i + 1
		floor_2_probs[left_idx] += floor_1_probs[i] * (weights[0] / total)
		floor_2_probs[right_idx] += floor_1_probs[i] * (weights[1] / total)

	# Floor 3 probabilities (6 nodes: M, N, O, P, Q, R)
	var floor_3_probs = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for i in range(5):  # For each Floor 2 node
		var exits = floor_2_nodes[i].get_exit_roads()
		var weights = []
		for road in exits:
			weights.append(road.base_weight)
		var total = weights[0] + weights[1]

		var left_idx = i
		var right_idx = i + 1
		floor_3_probs[left_idx] += floor_2_probs[i] * (weights[0] / total)
		floor_3_probs[right_idx] += floor_2_probs[i] * (weights[1] / total)

	# Goal probabilities (7 slots: 0-6)
	# Each Floor 3 node maps to 2 goals (50/50 split in map_node_to_goal)
	var goal_probs: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
	for i in range(6):  # For each Floor 3 node (M, N, O, P, Q, R)
		# Node i can go to goal i or i+1 (50/50)
		goal_probs[i] += floor_3_probs[i] * 0.5
		goal_probs[i + 1] += floor_3_probs[i] * 0.5

	return goal_probs
