extends Node2D

## Game Manager for Prototype 2a - MODULAR COORDINATOR
## Lightweight orchestrator that delegates to specialized managers

# Preload managers (workaround for class_name recognition)
const UpgradeManagerScript = preload("res://prototype_math/managers/upgrade_manager.gd")

# Manager instances
var board_mgr: BoardManager
var drop_sim: DropSimulator
var scoring_mgr: ScoringManager
var round_mgr: RoundManager
var validation_mgr: ValidationManager
var upgrade_mgr
var ui_ctrl: UIController

# Board reference
@onready var board: Node2D = $Board

# UI References (passed to managers)
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
@onready var road_dropdown: OptionButton = $UI/Panel/MainScrollContainer/VBoxContainer/RoadSelectContainer/RoadDropdown
@onready var weight_slider: HSlider = $UI/Panel/MainScrollContainer/VBoxContainer/WeightSliderContainer/WeightSlider
@onready var weight_value_label: Label = $UI/Panel/MainScrollContainer/VBoxContainer/WeightSliderContainer/WeightValue
@onready var apply_weight_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/WeightButtonContainer/ApplyWeightButton
@onready var reset_weights_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/WeightButtonContainer/ResetWeightsButton
@onready var run_1000_test_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/ValidationButtonContainer/Run1000TestButton
@onready var validate_prob_sums_button: Button = $UI/Panel/MainScrollContainer/VBoxContainer/ValidationButtonContainer/ValidateProbSumsButton
@onready var validation_results_label: RichTextLabel = $UI/Panel/MainScrollContainer/VBoxContainer/ValidationResultsLabel
@onready var upgrade_panel: Panel = $UI/Panel/UpgradePanel
@onready var upgrade_card_1: Button = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard1
@onready var upgrade_card_2: Button = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard2
@onready var upgrade_card_3: Button = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard3
@onready var upgrade_title_1: Label = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard1/VBoxContainer/UpgradeTitle1
@onready var upgrade_title_2: Label = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard2/VBoxContainer/UpgradeTitle2
@onready var upgrade_title_3: Label = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard3/VBoxContainer/UpgradeTitle3
@onready var upgrade_desc_1: Label = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard1/VBoxContainer/UpgradeDesc1
@onready var upgrade_desc_2: Label = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard2/VBoxContainer/UpgradeDesc2
@onready var upgrade_desc_3: Label = $UI/Panel/UpgradePanel/HBoxContainer/UpgradeCard3/VBoxContainer/UpgradeDesc3

func _ready():
	# Initialize all managers
	scoring_mgr = ScoringManager.new()
	board_mgr = BoardManager.new()
	drop_sim = DropSimulator.new()
	round_mgr = RoundManager.new()
	validation_mgr = ValidationManager.new()
	upgrade_mgr = UpgradeManagerScript.new()
	ui_ctrl = UIController.new()

	# Setup manager dependencies
	board_mgr.setup(board, scoring_mgr)  # Pass board instance instead of self
	drop_sim.setup(board_mgr)
	validation_mgr.setup(board_mgr, drop_sim)
	validation_mgr.set_ui_inputs(node_a_input, node_b_input, node_c_input)
	upgrade_mgr.setup(board_mgr, scoring_mgr)
	ui_ctrl.setup(board_mgr, scoring_mgr, round_mgr, validation_mgr, upgrade_mgr)

	# Pass UI references to controller
	var ui_refs = {
		"round_info_label": round_info_label,
		"drop_button": drop_button,
		"reset_button": reset_button,
		"next_round_button": next_round_button,
		"node_a_input": node_a_input,
		"node_b_input": node_b_input,
		"node_c_input": node_c_input,
		"total_label": total_label,
		"results_label": results_label,
		"path_log": path_log,
		"road_dropdown": road_dropdown,
		"weight_slider": weight_slider,
		"weight_value_label": weight_value_label,
		"apply_weight_button": apply_weight_button,
		"reset_weights_button": reset_weights_button,
		"run_1000_test_button": run_1000_test_button,
		"validate_prob_sums_button": validate_prob_sums_button,
		"validation_results_label": validation_results_label,
		"upgrade_panel": upgrade_panel,
		"upgrade_card_1": upgrade_card_1,
		"upgrade_card_2": upgrade_card_2,
		"upgrade_card_3": upgrade_card_3,
		"upgrade_title_1": upgrade_title_1,
		"upgrade_title_2": upgrade_title_2,
		"upgrade_title_3": upgrade_title_3,
		"upgrade_desc_1": upgrade_desc_1,
		"upgrade_desc_2": upgrade_desc_2,
		"upgrade_desc_3": upgrade_desc_3
	}
	ui_ctrl.set_ui_references(ui_refs)

	# Setup signals and UI (board already exists in scene)
	board_mgr.reference_static_nodes()  # NEW: Reference static nodes instead of creating them
	setup_signals()
	ui_ctrl.initialize_ui_values()

func setup_signals():
	"""Connect UI signals to handlers"""
	drop_button.pressed.connect(_on_drop_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	next_round_button.pressed.connect(_on_next_round_pressed)
	node_a_input.value_changed.connect(_on_unit_assignment_changed)
	node_b_input.value_changed.connect(_on_unit_assignment_changed)
	node_c_input.value_changed.connect(_on_unit_assignment_changed)
	road_dropdown.item_selected.connect(_on_road_selected)
	weight_slider.value_changed.connect(_on_weight_slider_changed)
	apply_weight_button.pressed.connect(_on_apply_weight_pressed)
	reset_weights_button.pressed.connect(_on_reset_weights_pressed)
	run_1000_test_button.pressed.connect(_on_run_1000_test_pressed)
	validate_prob_sums_button.pressed.connect(_on_validate_prob_sums_pressed)
	upgrade_card_1.pressed.connect(_on_upgrade_card_1_pressed)
	upgrade_card_2.pressed.connect(_on_upgrade_card_2_pressed)
	upgrade_card_3.pressed.connect(_on_upgrade_card_3_pressed)

# ===== SIGNAL HANDLERS (Delegate to managers) =====

func _on_unit_assignment_changed(_value):
	ui_ctrl.update_total_label()

func _on_drop_pressed():
	"""Handle drop button press - orchestrate drop flow"""
	print("\n=== STARTING DROP ===")

	# Reset state
	drop_sim.reset_goal_counts()
	board_mgr.reset_road_traffic()
	ui_ctrl.prepare_for_drop()

	# Get unit assignments
	var assignments = [
		int(node_a_input.value),
		int(node_b_input.value),
		int(node_c_input.value)
	]

	var unit_counter = 1
	var floor_0_nodes = board_mgr.get_floor_0_nodes()

	# Drop units from each starting node
	for node_idx in range(3):
		var num_units = assignments[node_idx]
		var starting_node = floor_0_nodes[node_idx]

		for i in range(num_units):
			var unit = Unit.new(unit_counter)
			drop_sim.drop_unit(unit, starting_node, path_log)
			unit_counter += 1

	# Display results
	var goal_counts = drop_sim.get_goal_counts()
	ui_ctrl.display_results(goal_counts)

	# Show upgrade cards (Phase 2b: Roguelite loop)
	var upgrade_cards = upgrade_mgr.generate_upgrade_cards(3)
	ui_ctrl.show_upgrade_selection(upgrade_cards)

func _on_next_round_pressed():
	"""Handle next round button press - delegate to managers"""
	round_mgr.advance_round()
	ui_ctrl.update_round_display()
	ui_ctrl.set_next_round_state()

func _on_reset_pressed():
	"""Reset all statistics and UI"""
	drop_sim.reset_goal_counts()
	board_mgr.reset_road_traffic()
	round_mgr.reset()
	ui_ctrl.update_round_display()
	ui_ctrl.clear_results()
	ui_ctrl.set_next_round_state()
	print("Reset complete")

func _on_road_selected(index: int):
	ui_ctrl.on_road_selected(index)

func _on_weight_slider_changed(value: float):
	ui_ctrl.on_weight_slider_changed(value)

func _on_apply_weight_pressed():
	ui_ctrl.apply_weight_to_selected_road()

func _on_reset_weights_pressed():
	ui_ctrl.reset_all_road_weights()

func _on_run_1000_test_pressed():
	validation_mgr.run_1000_unit_test(validation_results_label, path_log)

func _on_validate_prob_sums_pressed():
	validation_mgr.validate_probability_sums(validation_results_label)

func _on_upgrade_card_1_pressed():
	ui_ctrl.on_upgrade_selected(0)

func _on_upgrade_card_2_pressed():
	ui_ctrl.on_upgrade_selected(1)

func _on_upgrade_card_3_pressed():
	ui_ctrl.on_upgrade_selected(2)
