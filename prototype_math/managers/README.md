# Managers Architecture Documentation

## Overview

The Prototype 2a system uses a **modular manager architecture** to separate concerns and improve maintainability. The `game_manager_2a.gd` acts as a lightweight coordinator that delegates to 6 specialized managers.

**Benefits:**
- **Context Efficiency**: Read 50-320 lines per edit instead of 895+
- **Isolated Debugging**: Issues contained to specific manager scope
- **Easy Extension**: Add new managers (e.g., `upgrade_manager.gd`) without modifying existing code
- **Clear Separation of Concerns**: Each manager has one responsibility
- **Token Savings**: Only load relevant files during edits

---

## Manager Files

### 1. `game_manager_2a.gd` (164 lines)
**Role:** Lightweight Coordinator
**Purpose:** Orchestrates manager interactions and handles UI signal routing

**Responsibilities:**
- Initializes all managers in `_ready()`
- Sets up manager dependencies and cross-references
- Connects UI signals to appropriate handlers
- Delegates all business logic to specialized managers
- **Does NOT contain:** Game logic, calculations, or UI formatting

**Key Pattern:**
```gdscript
func _on_drop_pressed():
    # Orchestrate drop flow by delegating to managers
    drop_sim.reset_goal_counts()
    board_mgr.reset_road_traffic()
    ui_ctrl.prepare_for_drop()
    # ... drop units via drop_sim
    ui_ctrl.display_results(drop_sim.get_goal_counts())
```

**When to Edit:**
- Adding new managers
- Routing new UI signals
- Changing manager initialization order
- Adding new cross-manager orchestration flows

---

### 2. `board_manager.gd` (208 lines)
**Role:** Board Structure & Geometry
**Purpose:** Creates and manages nodes, roads, and visual goal slots

**Responsibilities:**
- Creates all board nodes (Floors 0-3) with proper positioning
- Sets up road connections between adjacent floors
- Renders visual goal slots with multiplier-based colors
- Provides access to floor nodes and roads for other managers
- Manages road weight resets and traffic resets

**Key Functions:**
- `setup_board()`: Creates all 18 BoardNodes (3+4+5+6) with positioning
- `setup_roads()`: Creates 30 Road connections between floors
- `create_road(from, to)`: Helper to wire up road connections
- `reset_road_traffic()`: Resets all road traffic counters
- `reset_all_weights()`: Resets all roads to default weight 50
- `get_floor_X_nodes()`: Accessors for floor node arrays

**When to Edit:**
- Changing board layout or geometry
- Adding new floor levels
- Modifying goal slot visuals
- Adding new road connection patterns
- Implementing node capacity systems

**Dependencies:**
- `ScoringManager`: For goal slot color coding based on multipliers
- `BoardNode`, `Road` classes

---

### 3. `drop_simulator.gd` (151 lines)
**Role:** Unit Pathfinding & Weighted Routing
**Purpose:** Simulates unit drops through the board using weighted probability

**Responsibilities:**
- Executes unit pathfinding from Floor 0 → Floor 3
- Calculates weighted probabilities at each decision point
- Chooses roads using weighted random selection
- Tracks goal slot landings (goal_counts array)
- Maps Floor 3 nodes to final goal slots
- Provides both verbose (path logging) and silent (performance testing) drop modes

**Key Functions:**
- `drop_unit(unit, start_node, path_log)`: Verbose drop with logging
- `drop_unit_silent(unit, start_node)`: Silent drop for testing
- `calculate_route_probability(road, from_node, unit)`: Core weight formula
- `choose_next_road(node, unit)`: Weighted random selection
- `map_node_to_goal(floor3_node)`: Floor 3 → Goal slot mapping
- `reset_goal_counts()`: Clears goal landing counters

**Core Algorithm:**
```gdscript
# Weight calculation: base × node_modifier × unit_preference
final_weight = road.base_weight × from_node.get_exit_modifier_for_road(road) × unit.get_preference_for_road(road)

# Weighted random: normalize weights to probabilities
probability = weight / total_weight

# Cumulative probability selection
rand_val in [0, total_weight] → choose road where cumulative >= rand_val
```

**When to Edit:**
- Modifying weight calculation formulas
- Adding new pathfinding logic
- Implementing animation systems
- Changing goal slot mapping rules
- Adding unit type-specific behaviors

**Dependencies:**
- `BoardManager`: For accessing floor nodes and roads
- `Unit`, `Road`, `BoardNode` classes

---

### 4. `scoring_manager.gd` (49 lines)
**Role:** Scoring Calculations
**Purpose:** Calculates scores based on goal slot landings and multipliers

**Responsibilities:**
- Stores goal multiplier array: `[5.0, 0.0, 1.0, 2.0, 1.0, 0.0, 5.0]`
- Calculates total round score: `Σ(units × multiplier × 10)`
- Calculates individual goal slot scores
- Provides multiplier lookup by goal index
- Provides color mapping for multipliers (UI support)

**Key Functions:**
- `calculate_score(goal_counts)`: Total score for all goals
- `calculate_goal_score(goal_index, goal_counts)`: Single goal score
- `get_multiplier(goal_index)`: Lookup multiplier value
- `get_multiplier_color(goal_index)`: UI color ("lime", "red", "yellow", "white")

**Multiplier Design Rationale:**
- **Edge slots (0, 6): 5x** - Jackpot rewards (rare, high variance)
- **Near-edge (1, 5): 0x** - Traps (punish near-misses)
- **Center (3): 2x** - Bonus (most common, low variance)
- **Side (2, 4): 1x** - Safe fallback
- **Goal:** Equal EV between edge vs center strategies, differentiated by variance

**When to Edit:**
- Changing multiplier values
- Adding new scoring rules (combos, synergies)
- Implementing score modifiers from upgrades
- Adding new score calculation modes

**Dependencies:**
- None (pure calculation logic)

---

### 5. `round_manager.gd` (51 lines)
**Role:** Round Progression & Cumulative Scoring
**Purpose:** Tracks round state, cumulative scores, and round history

**Responsibilities:**
- Tracks current round number
- Maintains cumulative score across all rounds
- Stores per-round score history
- Handles round advancement logic
- Provides formatted round info text for UI

**Key State:**
- `current_round`: Current round number (starts at 1)
- `cumulative_score`: Total score across all rounds
- `round_scores`: Array of completed round scores
- `current_round_score`: Score from current drop (before advancing)

**Key Functions:**
- `set_current_round_score(score)`: Set score before advancing
- `advance_round()`: Increment round, add score to cumulative
- `reset()`: Reset all round state to defaults
- `get_round_info_text()`: Formatted "Round X | Cumulative Score: Y"
- `get_round_history()`: Array of past round scores

**When to Edit:**
- Adding round-based modifiers
- Implementing run failure conditions
- Adding round limits or victory conditions
- Tracking additional round statistics

**Dependencies:**
- None (pure state management)

---

### 6. `validation_manager.gd` (321 lines)
**Role:** Testing & Validation Tools
**Purpose:** Provides automated tests and expected probability calculations

**Responsibilities:**
- Calculates expected goal distribution based on road weights and unit assignment
- Runs 1000-unit validation tests comparing actual vs expected distributions
- Validates that all node exit probabilities sum to 1.0
- Provides detailed pass/fail reports with color-coded variance checks

**Key Functions:**
- `calculate_expected_distribution()`: Propagates probabilities through all floors
  - Uses current road weights and unit assignments
  - Returns `Array[float]` of expected goal percentages
  - **80+ lines of probability tree propagation logic**
- `run_1000_unit_test(validation_label, path_log)`: Automated test
  - Drops 1000 units with 300-400-300 assignment
  - Compares actual vs expected for each goal
  - Color-coded: GREEN (±2%), YELLOW (±2-5%), RED (>5%)
- `validate_probability_sums(validation_label)`: Mathematical integrity check
  - Verifies all 18 nodes have exit probabilities summing to 1.0 (±0.001 epsilon)

**Expected Distribution Algorithm:**
```gdscript
# Floor 0: Unit assignment percentages
floor_0_probs = [A%, B%, C%]

# Floor 1-3: Propagate via weighted splits
for each node in floor:
    for each exit road:
        next_node_prob += node_prob × (road_weight / total_weight)

# Goals: Floor 3 nodes split 50/50 to adjacent goals
goal_probs[i] += floor_3_probs[i] × 0.5
goal_probs[i+1] += floor_3_probs[i] × 0.5
```

**When to Edit:**
- Adding new test scenarios
- Changing validation thresholds (currently ±2% pass, ±2-5% warn)
- Testing new probability calculation modes
- Adding performance benchmarks

**Dependencies:**
- `BoardManager`: For accessing node/road structure
- `DropSimulator`: For running silent unit drops

---

### 7. `ui_controller.gd` (219 lines)
**Role:** UI Display & Formatting
**Purpose:** Handles all UI updates, display formatting, and user interaction feedback

**Responsibilities:**
- Stores references to all UI elements (labels, buttons, spinboxes)
- Formats and displays drop results (goals, scores, multipliers)
- Updates round info display
- Manages button states (Drop ↔ Next Round toggling)
- Handles road weight manipulation UI
- Populates road dropdown
- Formats validation test results

**Key Functions:**
- `set_ui_references(ui_refs)`: Receives dictionary of UI elements from coordinator
- `initialize_ui_values()`: Sets defaults (30-40-30 assignment, populate dropdown)
- `display_results(goal_counts)`: Formats comprehensive results display
  - Goal distribution table
  - Score breakdown
  - Round score prominently displayed
  - Cumulative score tracking
- `update_total_label()`: Validates unit assignment (1-300 range)
- `populate_road_dropdown()`: Fills dropdown with "A → D" style labels
- `apply_weight_to_selected_road()`: Applies slider value to road, updates visuals

**UI State Management:**
- Drop button disabled after drop (forces Next Round)
- Next Round button disabled until drop completes
- Total label color: RED (invalid), GREEN (valid)
- Modified roads: MAGENTA (thick), default roads: GRAY (thin)

**When to Edit:**
- Adding new UI panels or controls
- Changing display formatting
- Adding visual effects or animations
- Implementing new user interaction flows
- Adding tooltips or help text

**Dependencies:**
- `BoardManager`: For road access
- `ScoringManager`: For score calculations and color mapping
- `RoundManager`: For round info text
- `ValidationManager`: For expected distribution calculations

---

## Manager Communication Patterns

### Initialization Flow (game_manager_2a.gd `_ready()`)
```
1. Create all manager instances
2. Setup manager dependencies:
   - BoardManager.setup(parent_node, ScoringManager)
   - DropSimulator.setup(BoardManager)
   - ValidationManager.setup(BoardManager, DropSimulator)
   - UIController.setup(BoardManager, ScoringManager, RoundManager, ValidationManager)
3. Pass UI references to UIController
4. BoardManager.setup_board() + setup_roads()
5. Setup signal connections
6. UIController.initialize_ui_values()
```

### Drop Flow (orchestrated by coordinator)
```
1. DropSimulator.reset_goal_counts()
2. BoardManager.reset_road_traffic()
3. UIController.prepare_for_drop()
4. For each assigned unit:
   - DropSimulator.drop_unit(unit, start_node, path_log)
5. UIController.display_results(DropSimulator.get_goal_counts())
```

### Round Advancement Flow
```
1. RoundManager.advance_round()
   - Adds current score to cumulative
   - Increments round number
2. UIController.update_round_display()
3. UIController.set_next_round_state()
```

### Validation Test Flow
```
1. ValidationManager.run_1000_unit_test(validation_label, path_log)
   - Internally calls DropSimulator.drop_unit_silent() 1000 times
   - Calculates expected distribution via probability tree
   - Compares actual vs expected
   - Formats color-coded results
```

---

## Design Principles

### 1. Single Responsibility Principle (SRP)
Each manager has ONE clear responsibility:
- **BoardManager**: Structure
- **DropSimulator**: Pathfinding
- **ScoringManager**: Calculations
- **RoundManager**: State
- **ValidationManager**: Testing
- **UIController**: Display

### 2. Dependency Injection
Managers receive dependencies via `setup()` rather than creating them:
```gdscript
# GOOD
validation_mgr.setup(board_mgr, drop_sim)

# BAD
# validation_mgr creates its own BoardManager internally
```

### 3. Query Methods Over Direct Access
Managers provide getter methods rather than exposing internal state:
```gdscript
# GOOD
var nodes = board_mgr.get_floor_0_nodes()

# BAD
var nodes = board_mgr.floor_0_nodes  # Direct access
```

### 4. Manager Owns Its Domain
- **BoardManager** owns all road manipulation (reset_all_weights, reset_traffic)
- **DropSimulator** owns all goal counts (reset_goal_counts, get_goal_counts)
- **UIController** owns all UI updates (no other manager modifies UI)

### 5. Coordinator Never Contains Logic
The `game_manager_2a.gd` coordinator:
- ✅ Creates managers
- ✅ Wires dependencies
- ✅ Routes signals
- ❌ Never calculates, formats, or contains business logic

---

## Adding New Managers

### Example: Adding `upgrade_manager.gd`

**Step 1: Create the manager**
```gdscript
# prototype_math/managers/upgrade_manager.gd
extends RefCounted
class_name UpgradeManager

var board_mgr: BoardManager
var scoring_mgr: ScoringManager

func setup(board_manager: BoardManager, scoring_manager: ScoringManager):
    board_mgr = board_manager
    scoring_mgr = scoring_manager

func generate_upgrade_cards() -> Array:
    # Generate 3 random upgrade cards
    pass

func apply_upgrade(upgrade_data: Dictionary):
    # Apply upgrade to board state
    pass
```

**Step 2: Add to coordinator**
```gdscript
# game_manager_2a.gd
var upgrade_mgr: UpgradeManager

func _ready():
    # ... existing managers
    upgrade_mgr = UpgradeManager.new()
    upgrade_mgr.setup(board_mgr, scoring_mgr)
```

**Step 3: Integrate into flow**
```gdscript
func _on_drop_completed():
    var upgrade_cards = upgrade_mgr.generate_upgrade_cards()
    ui_ctrl.show_upgrade_selection(upgrade_cards)

func _on_upgrade_selected(upgrade_data):
    upgrade_mgr.apply_upgrade(upgrade_data)
    round_mgr.advance_round()
```

**No other managers need modification!**

---

## File Dependency Graph

```
game_manager_2a.gd (coordinator)
├── BoardManager
│   └── ScoringManager (for goal colors)
├── DropSimulator
│   └── BoardManager (for nodes/roads)
├── ScoringManager (standalone)
├── RoundManager (standalone)
├── ValidationManager
│   ├── BoardManager (for nodes/roads)
│   └── DropSimulator (for silent drops)
└── UIController
    ├── BoardManager (for road access)
    ├── ScoringManager (for score calculations)
    ├── RoundManager (for round info)
    └── ValidationManager (for expected distribution)
```

**Standalone Managers** (no dependencies):
- `ScoringManager`
- `RoundManager`

**Dependent Managers** (require setup):
- `BoardManager` → ScoringManager
- `DropSimulator` → BoardManager
- `ValidationManager` → BoardManager, DropSimulator
- `UIController` → BoardManager, ScoringManager, RoundManager, ValidationManager

---

## Performance Characteristics

| Manager | Lines | Typical Usage Frequency | Hot Path? |
|---------|-------|------------------------|-----------|
| BoardManager | 208 | Setup only (once) | No |
| DropSimulator | 151 | Every unit drop | **YES** |
| ScoringManager | 49 | Once per drop | No |
| RoundManager | 51 | Once per round | No |
| ValidationManager | 321 | Manual testing only | No |
| UIController | 219 | After every drop | No |

**Hot Path Optimization:**
- `DropSimulator.drop_unit_silent()` is performance-critical (called 1000× in tests)
- No logging, minimal allocations in silent mode
- Weighted random uses cumulative probability (O(n) where n = 2 exits)

---

## Testing Strategy

### Unit Testing (Per Manager)
Each manager can be tested independently:

```gdscript
# Test ScoringManager
var scoring_mgr = ScoringManager.new()
var goal_counts = [10, 0, 5, 20, 5, 0, 10]
assert(scoring_mgr.calculate_score(goal_counts) == expected_score)

# Test RoundManager
var round_mgr = RoundManager.new()
round_mgr.set_current_round_score(100)
round_mgr.advance_round()
assert(round_mgr.get_cumulative_score() == 100)
assert(round_mgr.get_current_round() == 2)
```

### Integration Testing (Full System)
1. Run prototype_2a.tscn
2. Drop 100 units → verify results display
3. Next Round → verify round advancement
4. Run 1000-unit test → verify all green passes
5. Validate probability sums → verify all ✓ PASS

### Regression Testing
- Manual road weight test: Apply 200 weight to A→D → verify units favor left
- Multi-round test: Play 5 rounds → verify cumulative score accurate
- Reset test: Reset after 3 rounds → verify all state cleared

---

## Common Modification Scenarios

### Scenario 1: Change Multiplier Values
**File to Edit:** `scoring_manager.gd` (line 9)
```gdscript
var goal_multipliers: Array[float] = [10.0, 0.0, 2.0, 3.0, 2.0, 0.0, 10.0]
```
**Impact:** Scoring calculations, goal slot colors (BoardManager auto-updates)

### Scenario 2: Add New Floor
**Files to Edit:**
1. `board_manager.gd`: Add floor_4_nodes array, setup logic
2. `drop_simulator.gd`: Extend pathfinding loop to floor 4
3. `validation_manager.gd`: Add floor 4 to expected distribution calculation

### Scenario 3: Add Upgrade System
**New File:** `upgrade_manager.gd`
**Modified Files:**
1. `game_manager_2a.gd`: Initialize upgrade_mgr
2. `ui_controller.gd`: Add show_upgrade_cards() function
3. `board_manager.gd`: Potentially add apply_road_upgrade() helper

### Scenario 4: Add Animation System
**New File:** `animation_controller.gd`
**Modified Files:**
1. `drop_simulator.gd`: Call animation_ctrl.animate_unit() instead of instant traversal
2. `game_manager_2a.gd`: Initialize animation_ctrl

---

## Troubleshooting

### Issue: Manager returns null/invalid data
**Check:** Manager dependencies set up correctly in coordinator `_ready()`

### Issue: UI not updating
**Check:** UIController has correct UI references passed via `set_ui_references()`

### Issue: Drop simulation incorrect results
**Check:**
1. BoardManager setup completed before drop
2. DropSimulator.reset_goal_counts() called before each drop
3. Road weights not corrupted (validate_probability_sums test)

### Issue: Expected vs Actual mismatch in validation
**Check:**
1. ValidationManager.set_ui_inputs() called with correct spinbox references
2. Road weights haven't been manually modified (reset to 50.0)
3. Sample size large enough (1000 units recommended)

---

## Migration Notes

### Converting from Monolithic (895 lines) to Modular (164 + 6 managers)

**What Changed:**
- All business logic moved to specialized managers
- Coordinator became thin orchestration layer
- UI references passed to UIController instead of direct access

**What Stayed the Same:**
- Scene structure (`prototype_2a.tscn`) unchanged
- UI element paths unchanged
- Signal connection mechanism unchanged
- External classes (`BoardNode`, `Road`, `Unit`) unchanged

**Breaking Changes:**
- None! All functionality preserved

**Performance Impact:**
- Negligible (managers are RefCounted, minimal overhead)
- Slightly more function calls (+1-2 per operation)
- 1000-unit test still completes in ~1-2 seconds

---

## Version History

### v1.0 - Modular Refactor (2025-10-10)
- Split 895-line monolith into 6 managers + coordinator
- Reduced coordinator to 164 lines (82% reduction)
- All Phase 2a functionality preserved
- All validation tests passing
- Ready for Phase 2b (upgrade system)

### v0.9 - Monolithic Architecture (2025-10-09)
- Single 895-line game_manager_2a.gd
- All 11 Phase 2a steps implemented
- Scoring + rounds system added (Phase 2b partial)
