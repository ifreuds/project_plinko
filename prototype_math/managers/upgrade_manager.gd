extends RefCounted
class_name UpgradeManager

## Manages upgrade card generation, selection, and application

# Manager references
var board_mgr: BoardManager
var scoring_mgr: ScoringManager

# Upgrade types
enum UpgradeType {
	ROAD_WEIGHT_BOOST,  # Increase road base_weight by 50
	GOAL_MULTIPLIER_BOOST,  # Increase specific goal multiplier
}

# Upgrade card structure
class UpgradeCard:
	var type: UpgradeType
	var title: String
	var description: String
	var target_data: Dictionary  # Stores road index, goal index, etc.

func setup(board_manager: BoardManager, scoring_manager: ScoringManager):
	"""Initialize upgrade manager with dependencies"""
	board_mgr = board_manager
	scoring_mgr = scoring_manager

func generate_upgrade_cards(count: int = 3) -> Array[UpgradeCard]:
	"""Generate random upgrade cards"""
	var cards: Array[UpgradeCard] = []

	for i in range(count):
		var card = _generate_random_upgrade()
		cards.append(card)

	return cards

func _generate_random_upgrade() -> UpgradeCard:
	"""Generate a single random upgrade card"""
	var card = UpgradeCard.new()

	# For now, randomly choose between road boost and goal boost
	var upgrade_type = randi() % 2

	if upgrade_type == 0:
		# Road Weight Boost
		card.type = UpgradeType.ROAD_WEIGHT_BOOST
		var all_roads = board_mgr.get_all_roads()
		var road_index = randi() % all_roads.size()
		var road = all_roads[road_index]

		card.target_data = {"road_index": road_index}
		card.title = "Road Boost: %s → %s" % [road.from_node.node_id, road.to_node.node_id]
		card.description = "Increase road weight by 50\n(Current: %.0f)" % road.base_weight
	else:
		# Goal Multiplier Boost
		card.type = UpgradeType.GOAL_MULTIPLIER_BOOST

		# Only boost goals with multipliers that can be increased (not 0x or 5x)
		var boostable_goals = []
		for i in range(7):
			var mult = scoring_mgr.get_multiplier(i)
			if mult > 0.0 and mult < 5.0:
				boostable_goals.append(i)

		if boostable_goals.size() > 0:
			var goal_index = boostable_goals[randi() % boostable_goals.size()]
			var current_mult = scoring_mgr.get_multiplier(goal_index)

			card.target_data = {"goal_index": goal_index, "boost_amount": 1.0}
			card.title = "Goal Boost: Slot %d" % goal_index
			card.description = "Increase multiplier by 1x\n(Current: %.1fx → %.1fx)" % [current_mult, current_mult + 1.0]
		else:
			# Fallback to road boost if no boostable goals
			return _generate_road_boost_card()

	return card

func _generate_road_boost_card() -> UpgradeCard:
	"""Generate a road boost card (fallback)"""
	var card = UpgradeCard.new()
	card.type = UpgradeType.ROAD_WEIGHT_BOOST

	var all_roads = board_mgr.get_all_roads()
	var road_index = randi() % all_roads.size()
	var road = all_roads[road_index]

	card.target_data = {"road_index": road_index}
	card.title = "Road Boost: %s → %s" % [road.from_node.node_id, road.to_node.node_id]
	card.description = "Increase road weight by 50\n(Current: %.0f)" % road.base_weight

	return card

func apply_upgrade(card: UpgradeCard):
	"""Apply the selected upgrade to the game state"""
	match card.type:
		UpgradeType.ROAD_WEIGHT_BOOST:
			_apply_road_boost(card)
		UpgradeType.GOAL_MULTIPLIER_BOOST:
			_apply_goal_boost(card)

func _apply_road_boost(card: UpgradeCard):
	"""Apply road weight boost"""
	var road_index = card.target_data["road_index"]
	var road = board_mgr.get_road_by_index(road_index)

	if road:
		var old_weight = road.base_weight
		road.base_weight += 50.0

		# Visual feedback - highlight upgraded roads
		road.default_color = Color(0.0, 1.0, 1.0, 0.9)  # Cyan for upgraded
		road.width = 4.0

		print("Applied Road Boost: %s → %s (%.0f → %.0f)" % [
			road.from_node.node_id,
			road.to_node.node_id,
			old_weight,
			road.base_weight
		])

func _apply_goal_boost(card: UpgradeCard):
	"""Apply goal multiplier boost"""
	var goal_index = card.target_data["goal_index"]
	var boost_amount = card.target_data["boost_amount"]

	var old_mult = scoring_mgr.get_multiplier(goal_index)
	scoring_mgr.goal_multipliers[goal_index] += boost_amount

	print("Applied Goal Boost: Slot %d (%.1fx → %.1fx)" % [
		goal_index,
		old_mult,
		scoring_mgr.goal_multipliers[goal_index]
	])
