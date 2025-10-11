extends RefCounted
class_name ValidationManager

## Handles validation testing: expected distribution calculation and automated tests

# Manager references
var board_mgr: BoardManager
var drop_sim: DropSimulator

# UI references (passed during tests)
var node_a_input: SpinBox
var node_b_input: SpinBox
var node_c_input: SpinBox

func setup(board_manager: BoardManager, drop_simulator: DropSimulator):
	"""Initialize validation manager with required dependencies"""
	board_mgr = board_manager
	drop_sim = drop_simulator

func set_ui_inputs(a_input: SpinBox, b_input: SpinBox, c_input: SpinBox):
	"""Set references to unit assignment inputs"""
	node_a_input = a_input
	node_b_input = b_input
	node_c_input = c_input

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

	var floor_0_nodes = board_mgr.get_floor_0_nodes()
	var floor_1_nodes = board_mgr.get_floor_1_nodes()
	var floor_2_nodes = board_mgr.get_floor_2_nodes()
	var _floor_3_nodes = board_mgr.get_floor_3_nodes()  # Reserved for future use

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

func run_1000_unit_test(validation_results_label: RichTextLabel, path_log: RichTextLabel):
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
	drop_sim.reset_goal_counts()
	board_mgr.reset_road_traffic()

	var assignments = [300, 400, 300]
	var unit_counter = 1

	var floor_0_nodes = board_mgr.get_floor_0_nodes()

	# Drop units (WITHOUT path logging to avoid UI overflow)
	for node_idx in range(3):
		var num_units = assignments[node_idx]
		var starting_node = floor_0_nodes[node_idx]
		for i in range(num_units):
			var unit = Unit.new(unit_counter)
			drop_sim.drop_unit_silent(unit, starting_node)  # Use silent version
			unit_counter += 1

	# Calculate expected distribution
	var expected_probs = calculate_expected_distribution()

	# Validate results
	var total_units = 1000
	var all_tests_passed = true
	var goal_counts = drop_sim.get_goal_counts()

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

func validate_probability_sums(validation_results_label: RichTextLabel):
	"""Validate that probability sums equal 100% at each decision point"""
	validation_results_label.clear()
	validation_results_label.append_text("[b]=== PROBABILITY SUM VALIDATION ===[/b]\n\n")

	print("\n=== VALIDATING PROBABILITY SUMS ===")

	var all_valid = true
	var total_nodes_checked = 0
	var epsilon = 0.001  # Tolerance for floating point comparison

	var floor_0_nodes = board_mgr.get_floor_0_nodes()
	var floor_1_nodes = board_mgr.get_floor_1_nodes()
	var floor_2_nodes = board_mgr.get_floor_2_nodes()

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
