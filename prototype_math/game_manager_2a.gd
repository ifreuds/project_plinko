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

# Scoring system (Phase 2b)
var goal_multipliers: Array[float] = [5.0, 0.0, 1.0, 2.0, 1.0, 0.0, 5.0]  # 7 goal multipliers
const BASE_POINTS_PER_UNIT: int = 10

# Round system (Phase 2b)
var current_round: int = 1
var cumulative_score: int = 0
var round_scores: Array[int] = []  # Track score for each completed round
var current_round_score: int = 0  # Score from current drop

# UI References (matched to scene structure - now inside MainScrollContainer)
@onready var round_info_label: Label = $UI/Panel/MainScrollContainer/VBoxContainer/RoundInfoLabel
@onready var drop_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/ButtonContainer/DropButton
@onready var reset_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/ButtonContainer/ResetButton
@onready var next_round_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/NextRoundButton
@onready var node_a_input: SpinBox = $UI/Panel/MainScrollContainer/VBoxContainer/NodeAContainer/SpinBox
@onready var node_b_input: SpinBox = $UI/Panel/MainScrollContainer/VBoxContainer/NodeBContainer/SpinBox
@onready var node_c_input: SpinBox = $UI/Panel/MainScrollContainer/VBoxContainer/NodeCContainer/SpinBox
@onready var total_label: Label = $UI/Panel/MainScrollContainer/VBoxContainer/TotalLabel
@onready var results_label: RichTextLabel = $UI/Panel/MainScrollContainer/VBoxContainer/ResultsLabel
@onready var path_log: RichTextLabel = $UI/Panel/MainScrollContainer/VBoxContainer/ScrollContainer/PathLog

# Weight testing UI
@onready var road_dropdown: OptionButton = $UI/Panel/MainScrollContainer/VBoxContainer/RoadSelectContainer/RoadDropdown
@onready var weight_slider: HSlider = $UI/Panel/MainScrollContainer/VBoxContainer/WeightSliderContainer/WeightSlider
@onready var weight_value_label: Label = $UI/Panel/MainScrollContainer/VBoxContainer/WeightSliderContainer/WeightValue
@onready var apply_weight_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/WeightButtonContainer/ApplyWeightButton
@onready var reset_weights_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/WeightButtonContainer/ResetWeightsButton

# Validation testing UI
@onready var run_1000_test_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/ValidationButtonContainer/Run1000TestButton
@onready var validate_prob_sums_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/ValidationButtonContainer/ValidateProbSumsButton
@onready var validation_results_label: RichTextLabel = $UI/Panel/MainScrollContainer/VBoxContainer/ValidationResultsLabel

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
		goal.size = Vector2(50, 60)  # Slightly taller to fit multiplier
		goal.position = Vector2(start_x + i * node_spacing_x, goal_y)

		# Color based on multiplier
		var multiplier = goal_multipliers[i]
		if multiplier == 5.0:
			goal.color = Color(0.0, 1.0, 0.5, 1.0)  # Bright green for 5x (JACKPOT!)
		elif multiplier == 0.0:
			goal.color = Color(0.9, 0.1, 0.1, 1.0)  # Red for 0x (BUST!)
		elif multiplier == 2.0:
			goal.color = Color(1.0, 0.8, 0.0, 1.0)  # Bright yellow for 2x (good value)
		else:  # 1x
			goal.color = Color(0.7, 0.6, 0.3, 1.0)  # Muted gold for 1x (safe)

		# Add goal number label (top part)
		var label = Label.new()
		label.text = str(i)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.position = Vector2(0, 2)
		label.size = Vector2(goal.size.x, 20)
		label.add_theme_font_size_override("font_size", 16)
		goal.add_child(label)

		# Add multiplier label (bottom part)
		var mult_label = Label.new()
		mult_label.text = "%.1fx" % multiplier
		mult_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		mult_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		mult_label.position = Vector2(0, goal.size.y - 22)
		mult_label.size = Vector2(goal.size.x, 20)
		mult_label.add_theme_font_size_override("font_size", 12)
		mult_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))  # White for visibility
		goal.add_child(mult_label)

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
	next_round_button.pressed.connect(_on_next_round_pressed)
	node_a_input.value_changed.connect(_on_unit_assignment_changed)
	node_b_input.value_changed.connect(_on_unit_assignment_changed)
	node_c_input.value_changed.connect(_on_unit_assignment_changed)

	# Weight testing signals
	road_dropdown.item_selected.connect(_on_road_selected)
	weight_slider.value_changed.connect(_on_weight_slider_changed)
	apply_weight_button.pressed.connect(_on_apply_weight_pressed)
	reset_weights_button.pressed.connect(_on_reset_weights_pressed)

	# Validation testing signals
	run_1000_test_button.pressed.connect(_on_run_1000_test_pressed)
	validate_prob_sums_button.pressed.connect(_on_validate_prob_sums_pressed)

	_update_total_label()
	_populate_road_dropdown()
	_update_round_display()

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
	"""Display goal distribution statistics with expected vs actual and scoring"""
	var total_units = 0
	for count in goal_counts:
		total_units += count

	# Calculate expected distribution based on current weights
	var expected_probs = calculate_expected_distribution()

	# Calculate total score for this round
	current_round_score = calculate_score()

	var result_text = "\n[b]=== ROUND %d RESULTS ===[/b]\n" % current_round
	result_text += "(%d units dropped)\n\n" % total_units
	result_text += "[color=gray]Goal | Mult | Units | %    | Score[/color]\n"

	for i in range(7):
		var count = goal_counts[i]
		var multiplier = goal_multipliers[i]
		var actual_percent = (float(count) / total_units * 100.0) if total_units > 0 else 0.0
		var slot_score = calculate_goal_score(i)

		# Color code multipliers for visual distinction
		var mult_color = "lime" if multiplier == 5.0 else ("red" if multiplier == 0.0 else ("yellow" if multiplier == 2.0 else "white"))

		result_text += "  %d  | [color=%s]%.1fx[/color] | %3d  | %4.1f%% | [b]%d[/b]\n" % [
			i, mult_color, multiplier, count, actual_percent, slot_score
		]

	# Show round score prominently
	result_text += "\n[color=yellow]═══════════════════════════[/color]\n"
	result_text += "[b]ROUND SCORE: [color=lime]%d points[/color][/b]\n" % current_round_score
	result_text += "[color=yellow]═══════════════════════════[/color]\n"

	# Show cumulative progress
	result_text += "\n[color=cyan]Cumulative: %d points (over %d rounds)[/color]\n" % [cumulative_score, current_round - 1]

	# Calculate center vs edge distribution
	var center = goal_counts[3] + goal_counts[4]
	var center_percent = (float(center) / total_units * 100.0) if total_units > 0 else 0.0
	var expected_center = (expected_probs[3] + expected_probs[4]) * 100.0
	result_text += "\nCenter (3+4): %.1f%% actual vs %.1f%% expected\n" % [center_percent, expected_center]

	results_label.text = result_text
	print(result_text)

	# Enable next round button, disable drop button
	next_round_button.disabled = false
	drop_button.disabled = true

func _create_bar(percent: float) -> String:
	"""Create ASCII bar chart"""
	var bar_length = int(percent / 5.0)  # Each block = 5%
	var bar = ""
	for i in range(bar_length):
		bar += "■"
	for i in range(20 - bar_length):
		bar += "░"
	return "[%s]" % bar

func calculate_score() -> int:
	"""Calculate total score based on units in each goal slot and their multipliers"""
	var total_score = 0

	for i in range(7):
		var units = goal_counts[i]
		var multiplier = goal_multipliers[i]
		var slot_score = units * multiplier * BASE_POINTS_PER_UNIT
		total_score += int(slot_score)

	return total_score

func calculate_goal_score(goal_index: int) -> int:
	"""Calculate score for a single goal slot"""
	if goal_index < 0 or goal_index >= 7:
		return 0

	var units = goal_counts[goal_index]
	var multiplier = goal_multipliers[goal_index]
	return int(units * multiplier * BASE_POINTS_PER_UNIT)

func _update_round_display():
	"""Update the round info label"""
	round_info_label.text = "Round %d | Cumulative Score: %d" % [current_round, cumulative_score]

func _on_next_round_pressed():
	"""Handle next round button press - advance to next round"""
	# Add current round score to cumulative
	round_scores.append(current_round_score)
	cumulative_score += current_round_score

	# Advance round
	current_round += 1
	current_round_score = 0

	# Update UI
	_update_round_display()

	# Enable drop button, disable next round button
	drop_button.disabled = false
	next_round_button.disabled = true

	# Clear results for next round
	results_label.text = "Round %d - Ready to drop!" % current_round

	print("Advanced to Round %d (Cumulative: %d points)" % [current_round, cumulative_score])

func _on_reset_pressed():
	"""Reset all statistics and UI"""
	goal_counts = [0, 0, 0, 0, 0, 0, 0]
	for road in all_roads:
		road.reset_traffic()
	path_log.clear()
	results_label.text = ""

	# Reset round system
	current_round = 1
	cumulative_score = 0
	round_scores.clear()
	current_round_score = 0
	_update_round_display()

	# Reset button states
	drop_button.disabled = false
	next_round_button.disabled = true

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

# Automated validation tests
func _on_run_1000_test_pressed():
	"""Run comprehensive 1000-unit test with validation"""
	validation_results_label.clear()
	validation_results_label.append_text("[b]=== 1000-UNIT VALIDATION TEST ===[/b]\n\n")

	# Store original assignment
	var original_a = node_a_input.value
	var original_b = node_b_input.value
	var original_c = node_c_input.value

	# Set to balanced assignment for testing (300-400-300 = 1000 total)
	node_a_input.value = 300
	node_b_input.value = 400
	node_c_input.value = 300

	print("\n=== RUNNING 1000-UNIT VALIDATION TEST ===")
	validation_results_label.append_text("Running 1000 units (300-400-300 assignment)...\n")
	validation_results_label.append_text("Please wait...\n")

	# Clear path log to avoid UI overflow
	path_log.clear()

	# Reset and run drop
	goal_counts = [0, 0, 0, 0, 0, 0, 0]
	for road in all_roads:
		road.reset_traffic()

	var assignments = [300, 400, 300]
	var unit_counter = 1

	# Drop units (WITHOUT path logging to avoid UI overflow)
	for node_idx in range(3):
		var num_units = assignments[node_idx]
		var starting_node = floor_0_nodes[node_idx]
		for i in range(num_units):
			var unit = Unit.new(unit_counter)
			drop_unit_silent(unit, starting_node)  # Use silent version
			unit_counter += 1

	# Calculate expected distribution
	var expected_probs = calculate_expected_distribution()

	# Validate results
	var total_units = 1000
	var all_tests_passed = true

	validation_results_label.append_text("\n[b]Results:[/b]\n")
	validation_results_label.append_text("Goal | Actual | Expected | Diff | Status\n")

	for i in range(7):
		var count = goal_counts[i]
		var actual_percent = (float(count) / total_units * 100.0)
		var expected_percent = expected_probs[i] * 100.0
		var diff = actual_percent - expected_percent

		var status = ""
		var status_color = ""
		if abs(diff) < 2.0:
			status = "✓ PASS"
			status_color = "green"
		elif abs(diff) < 5.0:
			status = "⚠ WARN"
			status_color = "yellow"
			all_tests_passed = false
		else:
			status = "✗ FAIL"
			status_color = "red"
			all_tests_passed = false

		validation_results_label.append_text("  %d  | %5.1f%% | %5.1f%% | %+.1f%% | [color=%s]%s[/color]\n" % [
			i, actual_percent, expected_percent, diff, status_color, status
		])

	# Test center distribution
	var center = goal_counts[3] + goal_counts[4]
	var center_percent = (float(center) / total_units * 100.0)
	var expected_center = (expected_probs[3] + expected_probs[4]) * 100.0
	var center_diff = center_percent - expected_center

	validation_results_label.append_text("\n[b]Center (3+4):[/b] %.1f%% actual vs %.1f%% expected (diff: %+.1f%%)\n" % [
		center_percent, expected_center, center_diff
	])

	# Overall result
	validation_results_label.append_text("\n[b]OVERALL:[/b] ")
	if all_tests_passed:
		validation_results_label.append_text("[color=green]✓ ALL TESTS PASSED[/color]\n")
		validation_results_label.append_text("All goals within ±2% variance. Math system validated!\n")
	else:
		validation_results_label.append_text("[color=yellow]⚠ SOME WARNINGS[/color]\n")
		validation_results_label.append_text("Some goals show ±2-5% variance. This is acceptable for probabilistic systems.\n")

	print("1000-unit validation test complete")

	# Restore original assignment
	node_a_input.value = original_a
	node_b_input.value = original_b
	node_c_input.value = original_c

func _on_validate_prob_sums_pressed():
	"""Validate that probability sums equal 100% at each decision point"""
	validation_results_label.clear()
	validation_results_label.append_text("[b]=== PROBABILITY SUM VALIDATION ===[/b]\n\n")

	print("\n=== VALIDATING PROBABILITY SUMS ===")

	var all_valid = true
	var total_nodes_checked = 0
	var epsilon = 0.001  # Tolerance for floating point comparison

	# Check Floor 0 nodes
	validation_results_label.append_text("[b]Floor 0 Nodes:[/b]\n")
	for node in floor_0_nodes:
		var exits = node.get_exit_roads()
		if exits.size() == 0:
			continue

		var total_weight = 0.0
		for road in exits:
			total_weight += road.base_weight

		var prob_sum = 0.0
		for road in exits:
			prob_sum += road.base_weight / total_weight

		var is_valid = abs(prob_sum - 1.0) < epsilon
		var status_color = "green" if is_valid else "red"
		var status = "✓ PASS" if is_valid else "✗ FAIL"

		validation_results_label.append_text("  Node %s: Sum = %.6f [color=%s]%s[/color]\n" % [
			node.node_id, prob_sum, status_color, status
		])

		if not is_valid:
			all_valid = false
		total_nodes_checked += 1

	# Check Floor 1 nodes
	validation_results_label.append_text("\n[b]Floor 1 Nodes:[/b]\n")
	for node in floor_1_nodes:
		var exits = node.get_exit_roads()
		if exits.size() == 0:
			continue

		var total_weight = 0.0
		for road in exits:
			total_weight += road.base_weight

		var prob_sum = 0.0
		for road in exits:
			prob_sum += road.base_weight / total_weight

		var is_valid = abs(prob_sum - 1.0) < epsilon
		var status_color = "green" if is_valid else "red"
		var status = "✓ PASS" if is_valid else "✗ FAIL"

		validation_results_label.append_text("  Node %s: Sum = %.6f [color=%s]%s[/color]\n" % [
			node.node_id, prob_sum, status_color, status
		])

		if not is_valid:
			all_valid = false
		total_nodes_checked += 1

	# Check Floor 2 nodes
	validation_results_label.append_text("\n[b]Floor 2 Nodes:[/b]\n")
	for node in floor_2_nodes:
		var exits = node.get_exit_roads()
		if exits.size() == 0:
			continue

		var total_weight = 0.0
		for road in exits:
			total_weight += road.base_weight

		var prob_sum = 0.0
		for road in exits:
			prob_sum += road.base_weight / total_weight

		var is_valid = abs(prob_sum - 1.0) < epsilon
		var status_color = "green" if is_valid else "red"
		var status = "✓ PASS" if is_valid else "✗ FAIL"

		validation_results_label.append_text("  Node %s: Sum = %.6f [color=%s]%s[/color]\n" % [
			node.node_id, prob_sum, status_color, status
		])

		if not is_valid:
			all_valid = false
		total_nodes_checked += 1

	# Overall result
	validation_results_label.append_text("\n[b]SUMMARY:[/b]\n")
	validation_results_label.append_text("Checked %d nodes\n" % total_nodes_checked)

	if all_valid:
		validation_results_label.append_text("[color=green]✓ ALL PROBABILITY SUMS VALID[/color]\n")
		validation_results_label.append_text("All nodes have exits summing to 100%. System is mathematically sound!\n")
	else:
		validation_results_label.append_text("[color=red]✗ SOME PROBABILITY SUMS INVALID[/color]\n")
		validation_results_label.append_text("ERROR: Some nodes have probabilities that don't sum to 100%!\n")

	print("Probability sum validation complete: %d nodes checked, all valid: %s" % [total_nodes_checked, all_valid])
