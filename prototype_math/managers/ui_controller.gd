extends RefCounted
class_name UIController

## Manages all UI updates and display formatting

# Manager references
var board_mgr: BoardManager
var scoring_mgr: ScoringManager
var round_mgr: RoundManager
var validation_mgr: ValidationManager
var upgrade_mgr  # UpgradeManager (untyped to avoid class_name issues)

# UI element references
var round_info_label: Label
var drop_button: Button
var reset_button: Button
var next_round_button: Button
var node_a_input: SpinBox
var node_b_input: SpinBox
var node_c_input: SpinBox
var total_label: Label
var results_label: RichTextLabel
var path_log: RichTextLabel
var road_dropdown: OptionButton
var weight_slider: HSlider
var weight_value_label: Label
var apply_weight_button: Button
var reset_weights_button: Button
var run_1000_test_button: Button
var validate_prob_sums_button: Button
var validation_results_label: RichTextLabel

# Upgrade UI elements
var upgrade_panel: Panel
var upgrade_card_1: Button
var upgrade_card_2: Button
var upgrade_card_3: Button
var upgrade_title_1: Label
var upgrade_title_2: Label
var upgrade_title_3: Label
var upgrade_desc_1: Label
var upgrade_desc_2: Label
var upgrade_desc_3: Label

# Stored upgrade cards
var current_upgrade_cards: Array = []

func setup(board_manager: BoardManager, scoring_manager: ScoringManager,
		   round_manager: RoundManager, validation_manager: ValidationManager,
		   upgrade_manager):
	"""Initialize UI controller with manager references"""
	board_mgr = board_manager
	scoring_mgr = scoring_manager
	round_mgr = round_manager
	validation_mgr = validation_manager
	upgrade_mgr = upgrade_manager

func set_ui_references(ui_refs: Dictionary):
	"""Set all UI element references from dictionary"""
	round_info_label = ui_refs.get("round_info_label")
	drop_button = ui_refs.get("drop_button")
	reset_button = ui_refs.get("reset_button")
	next_round_button = ui_refs.get("next_round_button")
	node_a_input = ui_refs.get("node_a_input")
	node_b_input = ui_refs.get("node_b_input")
	node_c_input = ui_refs.get("node_c_input")
	total_label = ui_refs.get("total_label")
	results_label = ui_refs.get("results_label")
	path_log = ui_refs.get("path_log")
	road_dropdown = ui_refs.get("road_dropdown")
	weight_slider = ui_refs.get("weight_slider")
	weight_value_label = ui_refs.get("weight_value_label")
	apply_weight_button = ui_refs.get("apply_weight_button")
	reset_weights_button = ui_refs.get("reset_weights_button")
	run_1000_test_button = ui_refs.get("run_1000_test_button")
	validate_prob_sums_button = ui_refs.get("validate_prob_sums_button")
	validation_results_label = ui_refs.get("validation_results_label")
	upgrade_panel = ui_refs.get("upgrade_panel")
	upgrade_card_1 = ui_refs.get("upgrade_card_1")
	upgrade_card_2 = ui_refs.get("upgrade_card_2")
	upgrade_card_3 = ui_refs.get("upgrade_card_3")
	upgrade_title_1 = ui_refs.get("upgrade_title_1")
	upgrade_title_2 = ui_refs.get("upgrade_title_2")
	upgrade_title_3 = ui_refs.get("upgrade_title_3")
	upgrade_desc_1 = ui_refs.get("upgrade_desc_1")
	upgrade_desc_2 = ui_refs.get("upgrade_desc_2")
	upgrade_desc_3 = ui_refs.get("upgrade_desc_3")

func initialize_ui_values():
	"""Set initial UI values"""
	node_a_input.value = 30
	node_b_input.value = 40
	node_c_input.value = 30
	update_total_label()
	populate_road_dropdown()
	update_round_display()

	# Hide upgrade panel initially
	if upgrade_panel:
		upgrade_panel.visible = false

func update_total_label():
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

func update_round_display():
	"""Update the round info label"""
	round_info_label.text = round_mgr.get_round_info_text()

func display_results(goal_counts: Array[int]):
	"""Display goal distribution statistics with expected vs actual and scoring"""
	var total_units = 0
	for count in goal_counts:
		total_units += count

	# Calculate expected distribution based on current weights
	var expected_probs = validation_mgr.calculate_expected_distribution()

	# Calculate total score for this round
	var current_round_score = scoring_mgr.calculate_score(goal_counts)
	round_mgr.set_current_round_score(current_round_score)

	var result_text = "\n[b]=== ROUND %d RESULTS ===[/b]\n" % round_mgr.get_current_round()
	result_text += "(%d units dropped)\n\n" % total_units
	result_text += "[color=gray]Goal | Mult | Units | %    | Score[/color]\n"

	for i in range(7):
		var count = goal_counts[i]
		var multiplier = scoring_mgr.get_multiplier(i)
		var actual_percent = (float(count) / total_units * 100.0) if total_units > 0 else 0.0
		var slot_score = scoring_mgr.calculate_goal_score(i, goal_counts)

		# Color code multipliers for visual distinction
		var mult_color = scoring_mgr.get_multiplier_color_name(i)

		result_text += "  %d  | [color=%s]%.1fx[/color] | %3d  | %4.1f%% | [b]%d[/b]\n" % [
			i, mult_color, multiplier, count, actual_percent, slot_score
		]

	# Show round score prominently
	result_text += "\n[color=yellow]═══════════════════════════[/color]\n"
	result_text += "[b]ROUND SCORE: [color=lime]%d points[/color][/b]\n" % current_round_score
	result_text += "[color=yellow]═══════════════════════════[/color]\n"

	# Show cumulative progress
	result_text += "\n[color=cyan]Cumulative: %d points (over %d rounds)[/color]\n" % [
		round_mgr.get_cumulative_score(),
		round_mgr.get_current_round() - 1
	]

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

func set_drop_completed_state():
	"""Update UI after drop completes"""
	next_round_button.disabled = false
	drop_button.disabled = true

func set_next_round_state():
	"""Update UI for next round"""
	drop_button.disabled = false
	next_round_button.disabled = true
	results_label.text = "Round %d - Ready to drop!" % round_mgr.get_current_round()

func clear_results():
	"""Clear all result displays"""
	path_log.clear()
	results_label.text = ""

func populate_road_dropdown():
	"""Fill dropdown with all road options"""
	road_dropdown.clear()

	var all_roads = board_mgr.get_all_roads()
	for i in range(all_roads.size()):
		var road = all_roads[i]
		var road_name = "%s → %s" % [road.from_node.node_id, road.to_node.node_id]
		road_dropdown.add_item(road_name, i)

	# Select first road
	if all_roads.size() > 0:
		road_dropdown.select(0)
		on_road_selected(0)

func on_road_selected(index: int):
	"""Update slider when a different road is selected"""
	var road = board_mgr.get_road_by_index(index)
	if road:
		weight_slider.value = road.base_weight
		weight_value_label.text = str(int(road.base_weight))

func on_weight_slider_changed(value: float):
	"""Update label when slider moves"""
	weight_value_label.text = str(int(value))

func apply_weight_to_selected_road():
	"""Apply the selected weight to the selected road"""
	var selected_index = road_dropdown.selected
	var selected_road = board_mgr.get_road_by_index(selected_index)

	if selected_road:
		var new_weight = weight_slider.value
		selected_road.base_weight = new_weight

		# Visual feedback - highlight modified roads
		if new_weight != 50.0:
			selected_road.default_color = Color(1.0, 0.0, 1.0, 0.9)  # Magenta for modified
			selected_road.width = 4.0
		else:
			selected_road.default_color = Color(0.5, 0.5, 0.5, 0.8)  # Gray for default
			selected_road.width = 2.0

		print("Applied weight %.0f to road: %s → %s" % [
			new_weight,
			selected_road.from_node.node_id,
			selected_road.to_node.node_id
		])

func reset_all_road_weights():
	"""Reset all road weights to default 50"""
	board_mgr.reset_all_weights()

	# Update slider to show current road's weight
	var selected_index = road_dropdown.selected
	on_road_selected(selected_index)

func prepare_for_drop():
	"""Prepare UI for unit drop"""
	path_log.clear()
	path_log.append_text("[b]=== DROP LOG ===[/b]\n\n")

func show_upgrade_selection(cards: Array):
	"""Show upgrade card selection UI"""
	current_upgrade_cards = cards

	# TEMPORARY: Auto-select first card if no UI exists
	if not upgrade_panel:
		print("⚠ No upgrade UI - auto-selecting first card for testing")
		print("Card 1: %s - %s" % [cards[0].title, cards[0].description])
		if cards.size() > 1:
			print("Card 2: %s - %s" % [cards[1].title, cards[1].description])
		if cards.size() > 2:
			print("Card 3: %s - %s" % [cards[2].title, cards[2].description])
		on_upgrade_selected(0)  # Auto-select first card
		return

	if upgrade_panel:
		upgrade_panel.visible = true

	# Populate card displays
	if cards.size() >= 1 and upgrade_title_1 and upgrade_desc_1:
		upgrade_title_1.text = cards[0].title
		upgrade_desc_1.text = cards[0].description

	if cards.size() >= 2 and upgrade_title_2 and upgrade_desc_2:
		upgrade_title_2.text = cards[1].title
		upgrade_desc_2.text = cards[1].description

	if cards.size() >= 3 and upgrade_title_3 and upgrade_desc_3:
		upgrade_title_3.text = cards[2].title
		upgrade_desc_3.text = cards[2].description

	# Disable next round button until upgrade is selected
	if next_round_button:
		next_round_button.disabled = true

	print("Showing %d upgrade cards" % cards.size())

func hide_upgrade_selection():
	"""Hide upgrade card selection UI"""
	if upgrade_panel:
		upgrade_panel.visible = false

func on_upgrade_selected(card_index: int):
	"""Handle upgrade card selection"""
	if card_index >= 0 and card_index < current_upgrade_cards.size():
		var selected_card = current_upgrade_cards[card_index]

		# Apply the upgrade
		upgrade_mgr.apply_upgrade(selected_card)

		# Refresh goal multiplier labels if goal was upgraded
		board_mgr.update_goal_multipliers()

		# Hide upgrade panel
		hide_upgrade_selection()

		# Enable next round button
		if next_round_button:
			next_round_button.disabled = false

		print("Selected upgrade: %s" % selected_card.title)
