# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ProjectPlinko** is a Godot 4.5 strategic roguelite game built around Plinko/Pachinko mechanics. The project has evolved through multiple prototype phases:

- **Prototype v0.1 (VALIDATED ✓):** Physics validation - Confirming Godot's physics engine produces proper binomial distributions
- **Prototype v0.2 (IN DEVELOPMENT):** Strategic Plinko with roguelite progression - Weight-based routing, unit assignment, upgrade system
  - **Phase 2a (VALIDATED ✓):** Core math system - Weight calculation and probability routing working correctly
  - **Phase 2b (IN PROGRESS - 50% COMPLETE):** Roguelite loop - Scoring multipliers ✓, multi-round gameplay ✓, upgrades (pending)

Engine: Godot 4.5 (GL Compatibility renderer)

## Development Environment

### Running the Project
- Open the project in Godot 4.5 editor
- Press F5 or click "Run Project" to launch
- The project uses `res://icon.svg` as the default icon

### Project Configuration
- Config file: `project.godot`
- Uses GL Compatibility rendering method (supports both desktop and mobile)
- Project name: "ProjectPlinko"

## Current Development Status (2025-10-10)

**Active Phase:** Prototype v0.2, Phase 2b IN PROGRESS (Scoring & Rounds COMPLETE ✓)

### Phase 2a: Core Math System - VALIDATED ✓

**Status:** ALL 11 STEPS COMPLETE ✓ (2025-10-09)

#### Completed & Validated Systems:

1. **Board Structure** ✓
   - 5-floor layout (3→4→5→6→7 nodes)
   - 30 roads connecting all floors
   - Visual distinction: Blue rectangles (start nodes), Gold rectangles (goal slots)

2. **Weight Calculation Engine** ✓
   - Core formula implemented: `final_weight = base_road_weight × node_exit_modifier × unit_preference`
   - Currently: all modifiers = 1.0, all preferences = 1.0 (baseline testing)
   - Probability calculation: Normalized weights across available exits

3. **Weighted Random Selection** ✓
   - Units choose roads based on calculated probabilities
   - Distribution matches expected statistical behavior
   - Validated with 100-unit test drop

4. **Unit Pathfinding** ✓
   - Units traverse from Floor 0 → Goal slot correctly
   - Path tracking functional (logs first 20 units)
   - All units reach valid goals (0-6)

5. **Unit Assignment UI** ✓
   - 3 SpinBox controls for Floor 0 nodes (A, B, C)
   - Range: 0-100 per node (no capacity enforcement for math testing)
   - Validation: 1-300 total units allowed
   - Default: 30-40-30 (100 units)

6. **Goal Detection** ✓
   - Floor 3 nodes correctly map to goal slots
   - Each Floor 3 node routes to 2 possible goals (50/50 split)
   - All 7 goals reachable

7. **Statistics Display** ✓
   - Goal distribution panel shows unit counts and percentages
   - ASCII bar chart visualization
   - Center slot aggregation (Goals 3+4)
   - **Enhanced in Step 10:** Expected vs Actual comparison with color-coded validation

8. **Road Traffic Visualization** ✓
   - Roads change color/thickness based on units traveled
   - Legend: Gray (0) → Orange (1-4) → Yellow (5-9) → Green (10+)
   - Real-time feedback as units drop
   - **Enhanced in Step 10:** Modified roads turn MAGENTA (thick) vs default gray (thin)

9. **Test Results** ✓
   - 100-unit drop with 30-40-30 assignment: All units reached goals
   - Distribution shows expected bell curve (center-heavy)
   - No crashes, errors, or null references
   - Performance: Instant drops (no animation for fast testing)

10. **Manual Weight Testing UI** ✓ (VALIDATED 2025-10-09)
    - Road selection dropdown listing all 30 roads (e.g., "A → D", "B → E")
    - Weight slider: 10-200 range (step: 5) with real-time value display
    - Apply Weight button: Sets selected road to chosen weight
    - Reset All Weights button: Returns all roads to default 50
    - Visual feedback: Modified roads highlighted in MAGENTA (thick lines)
    - **Expected Probability Calculation System:**
      - `calculate_expected_distribution()` - Computes theoretical % for each goal based on:
        - Current road weights (including manual modifications)
        - Unit assignment distribution (30-40-30 or custom)
        - Full path probability propagation through all 4 floors
      - Walks complete probability tree: Floor 0 assignment → Floor 1-3 weighted splits → Goal distribution
    - **Results Display Enhancement:**
      - Shows Expected vs Actual comparison table
      - Format: `Goal | Actual | Expected | Diff`
      - Color-coded validation:
        - GREEN: ±2% difference (excellent match)
        - YELLOW: ±2-5% difference (acceptable variance)
        - RED: >5% difference (needs investigation)
    - **Validation Test:** A→D, D→H, H→M all at 200 weight
      - Result: Units concentrated in Goals 0-1 (left side) as expected
      - Expected % calculation accurate (matched weighted path probabilities)
      - Actual distribution within acceptable variance (mostly green diffs)

11. **Automated Validation & UI Polish** ✓ (COMPLETE 2025-10-09)
    - **Run 1000-Unit Test Button:**
      - Drops 1000 units with assignment: 300-400-300 (Floor 0 nodes A-B-C)
      - Uses `drop_unit_silent()` for performance (no path logging)
      - Calculates expected distribution from current road weights
      - Compares actual vs expected for each goal slot
      - **Pass/Fail Criteria:**
        - GREEN (✓ PASS): ±2% variance
        - YELLOW (⚠ WARN): ±2-5% variance
        - RED (✗ FAIL): >5% variance
      - Shows overall result and center slot validation
      - Execution time: ~1-2 seconds for 1000 units
    - **Validate Probability Sums Button:**
      - Checks all 18 nodes (Floors 0, 1, 2) plus Floor 3 goal routing
      - Verifies each node's exit probabilities sum to 1.0 (100%)
      - Uses epsilon tolerance (0.001) for floating-point precision
      - Reports per-node status and overall validation result
      - Confirms mathematical soundness of weight system
    - **UI Polish:**
      - Entire panel wrapped in MainScrollContainer (scrollable)
      - Fixed layout overflow issues
      - Optimized panel heights:
        - Results panel: 200px
        - Path log: 120px
        - Validation panel: 200px
      - Panel repositioned: (650, 10) with size 380×740
      - All controls stay within frame
    - **Validation Results:**
      - ✅ 1000-unit test: All goals within ±2% variance (mostly GREEN passes)
      - ✅ Probability sums: All 18 nodes = 1.000000 (mathematically sound)
      - ✅ No crashes or null errors during testing
      - ✅ Performance validated (1000 units in ~1-2 seconds)

#### Phase 2a Files Created:
- `prototype_math/prototype_2a.tscn` - Main scene with complete testing UI
  - Scrollable container for all controls
  - Unit assignment spinboxes
  - Road weight manipulation UI
  - Statistics displays with validation
  - Automated test buttons
- `prototype_math/game_manager_2a.gd` - Game logic (620+ lines)
  - Core systems: board generation, unit assignment, weighted routing
  - Weight testing UI: road selection, weight adjustment, visual feedback
  - Expected probability calculation: full tree propagation (80+ lines)
  - Enhanced results display: Expected vs Actual comparison with color-coded validation
  - Automated validation tests: 1000-unit test, probability sum checker
  - Silent drop mode: `drop_unit_silent()` for performance testing
- `prototype_math/board_node.gd` - Node class (modifiers, exit probability)
- `prototype_math/road.gd` - Road class with traffic tracking
- `prototype_math/unit.gd` - Unit class with path tracking
- `prototype_math/prototype_2a_implementation_plan.md` - Implementation guide

#### Known Limitations (By Design for Phase 2a):
These are intentional simplifications - implemented in Phase 2b:
- No node modifiers (all return 1.0 for baseline math validation)
- No unit preferences (all return 1.0 for baseline math validation)
- No scoring multipliers (Phase 2b feature)
- No upgrade system (Phase 2b feature)
- No animation (instant drops for fast testing and iteration)

**Note:** All limitations are deliberate. Phase 2a focused exclusively on validating the mathematical foundation. With the core weight calculation system proven sound, Phase 2b will layer on gameplay systems.

### Phase 2a: Key Learnings & Validation Results

**Validation Tests Performed:**
- Test 1: 100 units, 30-40-30 assignment, default weights (2025-10-09)
- Test 2: 100 units, modified weights A→D/D→H/H→M at 200 (2025-10-09)
- Test 3: 1000 units, 300-400-300 assignment, automated validation (2025-10-09)
- Test 4: Probability sum validation across all 18 nodes (2025-10-09)

#### Confirmed Working Systems:
1. **Weight calculation is mathematically sound** - The multiplicative formula `final_weight = base × modifier × preference` correctly produces probability distributions that match theoretical expectations within ±2% variance
2. **Weighted random selection is unbiased** - Distribution across goals matches expected bell curve when all weights are equal (baseline: 50.0), and shifts predictably when weights are modified
3. **Path tracking is reliable** - All units successfully traverse from Floor 0 → Goal with no pathfinding failures, null references, or infinite loops
4. **Traffic visualization provides clear feedback** - Color coding (Gray→Orange→Yellow→Green, MAGENTA for modified) makes popular routes and manual adjustments immediately visible
5. **UI controls are intuitive** - SpinBox assignment interface works smoothly, validation prevents invalid inputs, weight manipulation is straightforward
6. **Expected probability calculation is accurate** - Theoretical distribution calculated via probability tree propagation matches actual outcomes within ±2% variance across 1000-unit tests
7. **Weight manipulation shifts distribution predictably** - Increasing specific road weights correctly biases unit flow toward connected goals, creating strategic manipulation opportunities
8. **Performance is acceptable** - 1000 units process in ~1-2 seconds using silent drop mode, confirming system scales for gameplay
9. **Mathematical integrity validated** - All nodes' exit probabilities sum to 1.0 (within epsilon 0.001), confirming no probability "leaks" or calculation errors
10. **System is robust** - No crashes, errors, or edge cases discovered during extensive testing

#### Architectural Decisions Validated:
- **Instant drops (no animation)** for Phase 2a was correct choice - enables rapid testing iteration (1000 units in ~1-2 seconds vs minutes with animation)
- **Baseline weights (all 1.0 modifiers)** proves the core math works - any future complexity builds on solid foundation
- **Traffic visualization** emerged as surprisingly useful debugging tool - visual patterns reveal probability flow instantly, manual weight changes show immediate MAGENTA feedback
- **Modular node/road/unit classes** scale well - no refactoring needed as system grew from 100 to 1000+ unit tests
- **Probability tree calculation** provides essential validation tool - comparing expected vs actual distributions catches math errors and confirms system integrity
- **Silent drop mode** (`drop_unit_silent()`) separates testing from debugging - allows performance validation without console spam
- **Color-coded validation UI** makes test results instantly readable - green/yellow/red indicators eliminate need to manually interpret variance percentages

#### Design Patterns That Emerged:
1. **Probability normalization at decision points** - Each node calculates `weight_sum`, then `probability = weight / weight_sum` for each exit. Ensures probabilities always sum to 1.0 regardless of weight values.
2. **Cumulative probability selection** - Random value 0-1 walks through cumulative probabilities until threshold crossed. Elegant weighted random implementation that scales to any number of exits.
3. **Dictionary-based road lookup** - `roads_by_start[node_id]` provides O(1) access to available exits. Critical for performance at scale (1000+ units).
4. **Traffic data as first-class feature** - Tracking `units_traveled` on roads enables both debugging and future gameplay visualization. Visual feedback loop closed.
5. **Expected vs Actual validation pattern** - Calculate theoretical distribution independently via probability tree propagation, compare against simulation results, color-code variance (±2% green, ±2-5% yellow, >5% red) for instant validation feedback. This pattern caught multiple subtle bugs during development.
6. **Silent vs Verbose execution modes** - `drop_unit()` logs paths for debugging, `drop_unit_silent()` skips logging for performance testing. Separation of concerns enables both detailed debugging and scalability validation.

#### Critical Success Factors (What Made Phase 2a Work):
1. **Testing-first mentality** - Built validation tools (expected distribution calculator, automated tests) BEFORE implementing upgrades. Prevented building gameplay on broken math.
2. **Incremental validation** - Each step validated independently (100 units → modified weights → 1000 units → probability sums). Caught issues early when fixes were cheap.
3. **Visual feedback loops** - Traffic colors, MAGENTA modified roads, green/yellow/red variance indicators made system behavior immediately visible. Debugging was observation, not guesswork.
4. **Mathematical rigor** - Probability tree calculation, epsilon-based sum validation, large sample tests (1000 units) ensured statistical soundness, not "looks about right."
5. **Clear separation of concerns** - Phase 2a = pure math validation, Phase 2b = gameplay systems. No feature creep, no "while we're here" additions. Discipline paid off.

### Phase 2b: Roguelite Loop (IN PROGRESS)

**Status:** Scoring & Round System COMPLETE ✓ (2025-10-10)

**Dependencies Met:**
- ✅ Weight calculation system validated
- ✅ Probability routing proven accurate
- ✅ Performance acceptable (1000 units in ~1-2 seconds)
- ✅ Mathematical integrity confirmed
- ✅ UI framework established

**Phase 2b Progress:**

#### 1. Scoring System ✅ COMPLETE (2025-10-10)
- **Goal Multipliers Implemented:** `[5x, 0x, 1x, 2x, 1x, 0x, 5x]`
  - Design rationale: Equal EV between edge vs center strategies, differentiated by variance
  - Edge slots (0, 6): 5x jackpot (rare) or adjacent 0x bust (common) = HIGH VARIANCE
  - Center slot (3): 2x bonus (most common) = LOW VARIANCE, SAFE
  - Slots 2, 4: 1x safe fallback
  - Slots 1, 5: 0x traps (punish near-misses)
- **Score Calculation:** `units × multiplier × 10 (base points)`
- **Visual Enhancements:**
  - Goal slots color-coded: GREEN (5x), RED (0x), YELLOW (2x), Gold (1x)
  - Multipliers displayed on each goal slot label
  - Results table format: Goal | Mult | Units | % | Score
  - Total score highlighted in lime green
- **Strategic Validation:**
  - Edge nodes confirmed slightly higher EV with massive variance swings
  - Center nodes confirmed safe consistent scoring
  - Meaningful risk/reward choice present from Turn 1

#### 2. Round System ✅ COMPLETE (2025-10-10)
- **Round Tracking:** current_round, cumulative_score, round_scores array
- **UI Components:**
  - Round info display: "Round X | Cumulative Score: Y"
  - "Next Round >" button with state management
  - Button state toggle: Drop ↔ Next Round (prevents double-clicks)
- **Multi-Round Flow:**
  - Drop Units → See Results (round + cumulative) → Next Round → Repeat
  - Drop button disabled after drop (forces Next Round click)
  - Next Round button disabled until drop completes
  - Reset button now resets entire run (all rounds, cumulative score)
- **Testing Validated:**
  - 5-round flow works smoothly
  - No state corruption or button glitches
  - Scores accumulate correctly across rounds

#### 3. Upgrade Card System ⏳ PENDING (Next Session)
**Planned Implementation:**
- Step 1: UI for showing 3 upgrade cards (post-drop display)
- Step 2: Card selection interaction (click to choose)
- Step 3: First upgrade type: Road Weight Boost (already validated in Phase 2a)
- Step 4: Apply upgrade to board state (modify road base_weight)
- Step 5: Test 5-round run with upgrades modifying strategy
- **Potential additions:**
  - Second upgrade type: Goal multiplier modification
  - Visual feedback for applied upgrades (highlight modified roads)
  - Upgrade history tracking

#### 4. Animations ⏳ PENDING (Later)
- Unit drop visualization (optional, instant drops work well for testing)
- Score pop-ups (polish feature)
- Road highlight effects (show selected upgrade application)

#### 5. Full Roguelite Loop ⏳ IN PROGRESS (50% Complete)
**Completed:**
- ✅ Assign Units (Phase 2a system, still functional)
- ✅ Drop (Phase 2a system, still functional)
- ✅ Score (NEW - fully implemented 2025-10-10)
- ⏳ Choose Upgrade (NEXT - ready to implement)

**Success Criteria Status:**
- ✅ Score calculation accurate (validated with test runs)
- ⏳ 5 rounds playable without crashes (validated for scoring only, pending upgrades)
- ⏳ Upgrades modify board state predictably (not yet implemented)
- ⏳ Distribution shifts remain mathematically sound after upgrades (not yet testable)
- ⏳ Gameplay loop feels satisfying (partial - scoring adds tension, awaiting upgrades)

### Phase 2b: Key Learnings & Design Decisions

**Session: 2025-10-10 (Scoring + Rounds Implementation)**

#### Design Decision: Multiplier Balance `[5x, 0x, 1x, 2x, 1x, 0x, 5x]`

**Rationale:**
- Original design proposed `[3x, 0.5x, 1x, 1x, 1x, 1x, 0.5x, 3x]`
- Problem: Edge slots had strictly lower EV than center slots → no incentive to risk edges
- Solution: Rebalanced to create **equal EV, differentiated variance** strategy
  - Edge strategy (target slots 0/6): 5x jackpot (rare) but 0x traps adjacent (common)
  - Center strategy (target slot 3): 2x bonus (most common landing)
  - Side strategies (slots 2/4): 1x safe fallback options

**Mathematical Justification:**
- Edge nodes slightly favor their respective edge slots (but still low probability)
- Center node heavily favors slot 3 (binomial center-clustering)
- Edge EV ≈ Center EV when accounting for probability × multiplier
- **Result:** Strategic choice is variance-based, not EV optimization
  - High variance (boom or bust): Load edge nodes, aim for 5x
  - Low variance (consistent): Load center node, collect reliable 2x

**Testing Validation:**
- Tested edge-heavy assignment: Wild score swings (0-50 point rounds)
- Tested center-heavy assignment: Consistent scoring (15-25 point rounds)
- **Strategic depth confirmed:** Meaningful choice from Turn 1

#### Architecture Decision: Round State Management

**Implementation:**
- `current_round` (integer): Tracks round number
- `cumulative_score` (integer): Total score across all rounds
- `round_scores` (array): Per-round score history
- Button state toggling: Drop active → Next Round active → Drop active (loop)

**Why This Works:**
- Simple state machine prevents double-execution bugs
- Cumulative score creates progression feeling
- Round history enables future features (score graphs, run summaries)
- Clean separation: "Drop" modifies board state, "Next Round" resets for next turn

#### UI/UX Decision: Color-Coded Goal Slots

**Color Scheme:**
- GREEN (lime): 5x multiplier slots (0, 6) - visually attractive, high reward
- RED (crimson): 0x multiplier slots (1, 5) - warning color, avoid these
- YELLOW (gold): 2x multiplier slot (3) - warm, safe, "jackpot lite"
- GOLD (default): 1x multiplier slots (2, 4) - neutral, baseline

**Rationale:**
- Instant visual communication of risk/reward
- Players don't need to read numbers to understand slot values
- Color psychology: Green = go/good, Red = stop/bad, Yellow = caution/bonus

#### Performance Note: Instant Drops Still Optimal

**Observation:**
- Scoring system adds ~5-10ms overhead per drop (negligible)
- 100-unit drops still complete in <100ms
- Multi-round testing (5 rounds) shows no performance degradation

**Decision:**
- Continue using instant drops (no animation) for Phase 2b
- Defer animation to Phase 2c polish (after gameplay mechanics proven)
- Philosophy: Validate core loop first, add juice later

#### Files Modified (2025-10-10):
- `prototype_math/game_manager_2a.gd` - Added scoring + round system (~40 lines)
  - `goal_multipliers` array: `[5.0, 0.0, 1.0, 2.0, 1.0, 0.0, 5.0]`
  - `calculate_score()` function: Iterates goals, applies multipliers
  - `_on_next_round_pressed()` handler: Resets state, increments round
  - Round tracking variables and UI updates
- `prototype_math/prototype_2a.tscn` - Added UI elements
  - RoundInfoLabel: Shows "Round X | Cumulative Score: Y"
  - NextRoundButton: Controls round progression
  - Goal slot color modulation: GREEN/RED/YELLOW/GOLD
  - Results display enhancement: Mult column added

**No Breaking Changes:**
- Phase 2a systems (weight calculation, probability routing) untouched
- All existing tests (1000-unit validation, probability sums) still pass
- Manual road weight manipulation still functional

**Next Session Prep:**
- Upgrade card system is next logical step
- Road Weight Boost upgrade already validated in Phase 2a (just needs UI wrapper)
- Consider second upgrade type: Goal multiplier modification (e.g., "Center Bonus: Slot 3 now 3x")

### Phase 2b: Modular Refactoring Plan (NEXT SESSION)

**Problem Statement:**
- `game_manager_2a.gd` has grown to 620+ lines (monolithic architecture)
- Every edit requires reading 200-500 lines of context
- Context window inefficiency is impacting iteration speed
- Will worsen when adding upgrade system (~150+ additional lines)
- Burning token budget on repeated file reads

**Solution: Modular Manager Architecture**

**New File Structure:**
```
prototype_math/
├── game_manager_2a.gd           (COORDINATOR - ~50 lines)
│   └── Lightweight orchestrator, delegates to managers
├── managers/
│   ├── board_manager.gd         (~100 lines)
│   │   └── Board/road/goal setup, node generation
│   ├── drop_simulator.gd        (~80 lines)
│   │   └── Unit pathfinding logic, weighted routing
│   ├── scoring_manager.gd       (~60 lines)
│   │   └── Score calculation, multipliers, round scores
│   ├── round_manager.gd         (~50 lines)
│   │   └── Round tracking, progression, state flow
│   ├── validation_manager.gd    (~150 lines)
│   │   └── Testing tools, probability calculation, automated tests
│   └── ui_controller.gd         (~100 lines)
│       └── UI updates, button states, display formatting
├── board_node.gd                (UNCHANGED)
├── road.gd                      (UNCHANGED)
├── unit.gd                      (UNCHANGED)
└── prototype_2a.tscn            (UNCHANGED)
```

**Benefits:**
1. **Context efficiency** - Read 50-150 lines per edit instead of 620+
2. **Isolated debugging** - Issues contained to specific manager scope
3. **Easier upgrades** - Add `upgrade_manager.gd` without touching other systems
4. **Better organization** - Clear separation of concerns (SRP principle)
5. **Reduced token usage** - Only load relevant manager files during edits
6. **Parallel development** - Multiple systems can be modified independently

**Implementation Steps (Next Session):**
1. Create `prototype_math/managers/` directory
2. Extract scoring logic → `scoring_manager.gd`
   - Move `goal_multipliers`, `calculate_score()`, score tracking variables
3. Extract round logic → `round_manager.gd`
   - Move `current_round`, `cumulative_score`, `round_scores`, round flow
4. Extract validation → `validation_manager.gd`
   - Move `calculate_expected_distribution()`, 1000-unit test, probability sum validation
5. Extract board setup → `board_manager.gd`
   - Move `setup_board()`, node/road generation, goal slot creation
6. Extract UI updates → `ui_controller.gd`
   - Move `update_results_display()`, button state management, label updates
7. Extract drop simulation → `drop_simulator.gd`
   - Move `drop_unit()`, `drop_unit_silent()`, pathfinding logic
8. Convert `game_manager_2a.gd` to thin coordinator
   - Initialize all managers in `_ready()`
   - Delegate calls to appropriate managers
   - Maintain only high-level orchestration logic
9. Test all functionality (drop, score, rounds, validation)
10. **THEN** implement upgrade system on clean foundation

**Manager Communication Pattern:**
```gdscript
# game_manager_2a.gd (Coordinator)
var board_mgr: BoardManager
var drop_mgr: DropSimulator
var scoring_mgr: ScoringManager
var round_mgr: RoundManager
var validation_mgr: ValidationManager
var ui_ctrl: UIController

func _ready():
    board_mgr = BoardManager.new()
    drop_mgr = DropSimulator.new(board_mgr)
    scoring_mgr = ScoringManager.new()
    round_mgr = RoundManager.new()
    # ... initialize managers with cross-dependencies

func _on_drop_button_pressed():
    drop_mgr.drop_units(assignment_data)
    var results = scoring_mgr.calculate_score(drop_mgr.goal_distribution)
    ui_ctrl.update_results(results)
    round_mgr.complete_round(results.score)
```

**Estimated Time:** 30-45 minutes
- Extraction: ~20 minutes
- Wiring: ~10 minutes
- Testing: ~10 minutes
- Validation: ~5 minutes

**Success Criteria:**
- ✅ All existing functionality works identically (drop, score, rounds, validation)
- ✅ No crashes or null reference errors
- ✅ 1000-unit test still passes (validation intact)
- ✅ Each manager file is <150 lines
- ✅ `game_manager_2a.gd` reduced to <100 lines (ideally ~50)

**After Refactor:**
- Upgrade system implementation will be cleaner (add `upgrade_manager.gd`)
- Each new feature gets its own manager (minimal cross-contamination)
- Context window usage dramatically reduced (read only relevant files)
- Iteration speed increases (edit specific managers, not entire system)

**Post-Upgrade Architecture:**
```
managers/
├── board_manager.gd
├── drop_simulator.gd
├── scoring_manager.gd
├── round_manager.gd
├── validation_manager.gd
├── ui_controller.gd
└── upgrade_manager.gd        (NEW - implements card system)
```

**IMPORTANT: Next Session Workflow**
1. User requests: "Refactor game_manager_2a into modular architecture"
2. Knowledge Keeper (you) refers to this plan
3. Implementation follows steps 1-9 above
4. After validation passes, THEN proceed with upgrade system
5. Do NOT skip refactor - foundation is critical for scalability

**Rationale for Refactor-First Approach:**
- Current 620-line file is already difficult to manage
- Adding upgrades (~150 lines) would push to 770+ lines (unsustainable)
- Refactor now = one-time 45-minute cost
- Skip refactor = compounding context window tax on every future edit
- Clean foundation enables faster upgrade implementation (paradoxically saves time overall)

## Architecture Overview

### Prototype Phase v0.1 (VALIDATED ✓)

This minimal viable prototype validated physics against probability theory. The prototype confirmed that balls dropped through a triangle pin board produce the expected statistical distribution matching binomial theory.

**Status:** Complete and validated. Physics parameters are locked and proven.

### Prototype Phase v0.2 (IN DEVELOPMENT)

A strategic roguelite Plinko system built on mathematical weight calculation rather than pure physics simulation.

**Architectural Shift:** While v0.1 validated that physics can produce proper distributions, v0.2 moves to probability-based routing for strategic depth. Units don't bounce physically; instead, they choose routes based on weighted calculations that players can manipulate through upgrades. This enables meaningful strategic choices while maintaining the satisfying "Plinko feel" of watching units cascade down through decision points.

#### Core Concept
Players assign units to starting nodes, drop them through a weighted node/road network, and earn rewards based on goal slot landings. After each drop, players choose upgrades to modify board weights, creating a build-optimization loop.

#### The Four Core Elements

**1. Unit**
- The traveling entity that drops through the board
- Base units have neutral routing behavior (no preferences)
- Upgraded units can have route preferences (e.g., "risky road attraction +30%")
- Starting pool: 10 units per drop

**2. Node (Land)**
- Landing spots on each floor that units bounce through
- Base state: Empty, no modifiers
- Upgraded state: Apply multiplicative modifiers to connected roads
  - Example: "Magnet Node" → `left_road_weight × 1.3`
- Floor 0 nodes are starting positions with capacity limits (default: 6 units each)

**3. Road**
- Paths between nodes on adjacent floors
- **base_weight:** Fundamental probability value (default: 50)
- Upgrading roads increases base_weight (e.g., 50 → 70 → 90)
- Higher weight = more likely travel path

**4. Goal (Scoring Slots)**
- Final destinations where units land and score
- **Multipliers:** `[5x, 0x, 1x, 2x, 1x, 0x, 5x]` (as implemented in Phase 2b)
- Risk/Reward design:
  - Edge slots (0, 6): 5x multiplier, jackpot rewards (hardest to reach)
  - Near-edge (1, 5): 0x multiplier, "trap" slots (punish near-misses)
  - Center slot (3): 2x multiplier, safe consistent scoring (most common)
  - Side slots (2, 4): 1x multiplier, baseline fallback options

#### Map Structure
```
Floor 0: [A] [B] [C]           (3 starting nodes)
Floor 1: [D] [E] [F] [G]       (4 nodes)
Floor 2: [H] [I] [J] [K] [L]   (5 nodes)
Floor 3: [M] [N] [O] [P] [Q] [R] (6 nodes)
Goals:   [0] [1] [2] [3] [4] [5] [6] (7 scoring slots)
```

#### Weight Calculation System
Units choose routes based on **multiplicative weight stacking**:
```
final_weight = base_road_weight × node_exit_modifier × unit_preference
```

Example:
- Road base_weight: 70 (upgraded)
- Node modifier: ×1.2 (Wind Boost)
- Unit preference: ×1.3 (Scout seeking risky roads)
- **Result:** 70 × 1.2 × 1.3 = 109.2 effective weight

#### Roguelite Loop
```
1. ASSIGN UNITS → 2. DROP → 3. SCORE → 4. CHOOSE UPGRADE → (repeat)
```

**Phase 1: Unit Assignment**
- Assign 10 units across 3 Floor 0 nodes (6 capacity each)
- Forces multi-node strategy (can't put all units in one spot)

**Phase 2: Drop**
- Units traverse board choosing roads based on weight calculations
- Visual feedback shows paths taken

**Phase 3: Scoring**
- Units land in goal slots
- Calculate: `Σ (units_in_slot × slot_multiplier × base_points)`

**Phase 4: Choose Upgrade**
- System offers 3 random upgrade cards
- Player picks 1
- Upgrade applied to board
- Return to Phase 1 with improved board

#### Five Upgrade Categories

1. **Road Upgrades:** Increase base_weight (50 → 70 → 90)
2. **Node Upgrades:** Apply modifiers (Magnet, Repulsor, Chaos effects)
3. **Unit Upgrades:** Change unit preferences (risky, safe, edge-seeking)
4. **Goal Upgrades:** Modify multipliers or add special effects
5. **Capacity Upgrades:** Expand node capacity or starting unit count

#### Implementation Phases

- **Phase 2a (COMPLETE ✓):** Core math system validation - ALL 11 STEPS VALIDATED (2025-10-09)
  - Weight calculation, probability routing, traffic visualization
  - Manual weight manipulation UI
  - Automated validation tests (1000 units, probability sums)
  - Performance confirmed (1000 units in ~1-2 seconds)
- **Phase 2b (READY TO START):** Roguelite loop (multipliers, upgrades, multi-round gameplay)
- **Phase 2c (FUTURE):** Full feature set (all 5 upgrade categories, polish)

**Design Principles:**
- Meaningful Turn 1 choices (even before upgrades)
- Multiplicative stacking for intuitive power scaling
- Risk/reward baked into goal multipliers
- Visual clarity of probabilities
- Build variety similar to Balatro/Slay the Spire

### Core Game Systems (v0.1 - LEGACY)

#### 1. Plinko Board Structure
- **7-row triangle pin arrangement** (1+2+3+4+5+6+7 = 28 pins total)
- **8 scoring slots** at the bottom (numbered 0-7, left to right)
- Pins are StaticBody2D with CircleShape2D collision
- Pins use PhysicsMaterial for bounce behavior

#### 2. Ball Physics System
- Balls: RigidBody2D with CircleShape2D collision
- Spawn at top center with slight random initial angle
- Affected by gravity and bounce off pins
- Removed after landing in slot

#### 3. Scoring and Statistics
- Each slot is an Area2D that detects ball entry
- Tracks both expected and actual probability distributions
- Expected probabilities follow binomial distribution:
  - Slot 0/7: 1/128 (0.78%)
  - Slot 1/6: 7/128 (5.47%)
  - Slot 2/5: 21/128 (16.41%)
  - Slot 3/4: 35/128 (27.34%)

#### 4. Testing Interface
- Input field for number of balls to drop (default: 128)
- Automated ball spawning and statistics tracking
- Per-slot displays showing expected vs actual distributions
- Visual heatmap based on ball counts
- Reset functionality for fresh testing runs

### Expected Script Structure

When implementing, the following scripts are planned:
- `ball.gd` - Ball physics and lifecycle
- `scoring_slot.gd` - Slot detection and counter management
- `game_manager.gd` - Overall game state, ball spawning, statistics
- `slot_display.gd` - UI updates for slot statistics

## Physics Parameters (VALIDATED ✓)

**Final working parameters** (achieved proper bell curve distribution):

### Ball & Pin PhysicsMaterial:
- **friction**: 0.40
- **bounce**: 0.28

### Ball RigidBody2D:
- **gravity_scale**: 0.5
- **linear_damp**: 1.1
- **angular_damp**: 2.0
- **initial velocity**: randf_range(-18.0, 18.0) horizontal

### Key Physics Principles Learned:
1. **Energy dissipation is critical** - Each collision must remove 20-40% of energy to prevent "deflection ratcheting" (velocity accumulation leading to edge-clustering)
2. **Balance damping carefully** - Too much (1.2+) causes center compression, too little (<0.8) causes edge-clustering
3. **Initial velocity matters** - Must be tight enough to hit first pin (±18-20 safe, ±50+ skips pins) but wide enough for statistical variation
4. **Symmetrical materials required** - Ball and pin must use same friction/bounce or behavior becomes unpredictable
5. **Iterative micro-adjustments work best** - Large parameter swings cause overcorrection

## Success Validation Criteria ✓

**VALIDATED** - Physics model meets acceptance criteria (532 ball test):

| Slot | Actual % | Expected % | Status |
|------|----------|------------|--------|
| 0    | 1.7%     | 0.8%       | ✓ Acceptable (2x expected) |
| 1    | 5.8%     | 5.5%       | ✓✓ Almost perfect |
| 2    | 13.9%    | 16.4%      | ✓ Good |
| 3    | 26.1%    | 27.3%      | ✓✓ Very close |
| 4    | 27.1%    | 27.3%      | ✓✓ Almost perfect |
| 5    | 19.0%    | 16.4%      | ✓ Good |
| 6    | 3.9%     | 5.5%       | ✓ Close |
| 7    | 2.4%     | 0.8%       | ✓ Acceptable (3x expected) |

**Key Metrics:**
- ✅ Center slots (3+4) = 53.2% vs expected 54.6% (within 2.5%)
- ✅ Bell curve shape preserved
- ✅ No left/right systematic bias
- ✅ Edge slots minimal (1.7% and 2.4% vs theoretical 0.8%)
- ✅ Ball behavior feels controlled and satisfying

## Known Issues & Limitations

### Edge Cases (Rare but observed):
1. **Stuck balls on pin tops** - Ball can find perfect balance point on top of pin and stop moving
   - Frequency: ~1 in 500-1000 balls
   - Impact: Ball never enters slot, remains on board
   - **Potential solutions** (not yet implemented):
     - Stuck detection + gentle nudge (recommended)
     - Timeout removal after X seconds
     - Pin geometry modification (slight taper)
     - Continuous micro-vibration on all balls
     - Sleep state detection with forced impulse

### Performance Limitations:
2. **Slow simulation speed at 500+ balls** - Unlike card-based games (Balatro), physics simulation is computationally intensive
   - 500+ ball drops take considerable time per test run
   - Not intensive calculation strain, just long execution time
   - May need optimization for gameplay (faster time scale, batched spawning, physics substeps tuning)
   - Consider: Do players need to watch all balls drop, or can some be simulated instantly?

### Resolved During Development:
- ✅ ~~Balls passing through pins~~ - Fixed via collision layer system
- ✅ ~~Edge-clustering distribution~~ - Fixed via proper damping
- ✅ ~~Center-compression distribution~~ - Fixed via balanced parameters
- ✅ ~~Balls bouncing back upward~~ - Fixed via controlled bounce values

## Future Expansion

### Beyond Prototype v0.2

Potential additions after core roguelite loop is validated:

**Expansion Ideas:**
- **Enemies:** Goals become "enemy slots" - landing causes damage/penalties
- **Special Pins:** Nodes with one-time effects (Teleporter jumps ahead a floor)
- **Multi-Unit Synergies:** "If 3+ units land in same slot, double multiplier"
- **Persistent Progression:** Meta-currency to unlock permanent upgrades between runs
- **Challenge Modes:** Constrained runs (no Road upgrades, starting with 5 units, etc.)

**Balancing Questions:**
- Optimal starting unit count? (10? 12? 15?)
- Should capacity increase naturally or only via upgrades?
- How many rounds per run? (10? 20? Until failure?)
- Should there be a health/energy system for failure stakes?

### v0.1 Legacy Expansion Ideas

~~Original plans before architectural shift to weight-based system:~~
- ~~Multiple unit types with different physics properties~~
- ~~Special pin types with gameplay effects~~
- ~~Manual pin placement/arrangement before drops~~

**Note:** Many v0.1 concepts evolved into v0.2 systems (units → strategic units, pins → nodes, physics → weights)

## Additional Documentation

### Prototype v0.1 (Physics Validation)
- `prototpye.md` - Detailed prototype v0.1 implementation plan
- `probability_explained.md` - Mathematical foundation for expected distributions

### Prototype v0.2 (Strategic Roguelite)
- `prototype_math/prototype_2_design.md` - Complete design specification for weight-based strategic Plinko system
  - Core Elements (Unit, Node, Road, Goal)
  - Weight calculation formulas
  - Roguelite loop structure
  - Implementation phases (2a, 2b, 2c)
  - Example turn walkthrough
  - Upgrade categories and balancing
