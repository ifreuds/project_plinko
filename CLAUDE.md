# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ProjectPlinko** is a Godot 4.5 strategic roguelite game built around Plinko/Pachinko mechanics. The project has evolved through multiple prototype phases:

- **Prototype v0.1 (VALIDATED ✓):** Physics validation - Confirming Godot's physics engine produces proper binomial distributions
- **Prototype v0.2 (IN DEVELOPMENT):** Strategic Plinko with roguelite progression - Weight-based routing, unit assignment, upgrade system
  - **Phase 2a (VALIDATED ✓):** Core math system - Weight calculation and probability routing working correctly
  - **Phase 2b (PENDING):** Roguelite loop - Scoring multipliers, upgrades, multi-round gameplay

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

## Current Development Status (2025-10-09)

**Active Phase:** Prototype v0.2, Phase 2a → 2b transition

### Phase 2a: Core Math System - VALIDATED ✓

**Status:** Steps 1-10 COMPLETE ✓. Step 11 (final validation) remains.

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

#### Remaining Phase 2a Tasks:

**Step 11: Validation & Polish** (NEXT)

**Step 11: Validation & Polish**
- Automated validation tests (button for 1000-unit test)
- Probability sum checks (each node's exits = 100%)
- Edge case handling (zero weights, extreme values)
- Performance testing (300+ units)

#### Phase 2a Files Created:
- `prototype_math/prototype_2a.tscn` - Main scene with weight testing UI
- `prototype_math/game_manager_2a.gd` - Game logic (420+ lines)
  - Core systems: board generation, unit assignment, weighted routing
  - Weight testing UI: road selection, weight adjustment, visual feedback
  - Expected probability calculation: full tree propagation (80+ lines)
  - Enhanced results display: Expected vs Actual comparison with color-coded validation
- `prototype_math/board_node.gd` - Node class
- `prototype_math/road.gd` - Road class with traffic tracking
- `prototype_math/unit.gd` - Unit class with path tracking
- `prototype_math/prototype_2a_implementation_plan.md` - Implementation guide

#### Known Limitations (By Design):
These are intentional for Phase 2a - added in Phase 2b:
- ❌ No node modifiers (all return 1.0 for baseline)
- ❌ No unit preferences (all return 1.0 for baseline)
- ❌ No scoring multipliers (Phase 2b feature)
- ❌ No upgrade system (Phase 2b feature)
- ❌ No animation (instant drops for fast testing)

### Phase 2a: Key Learnings & Validation Results

**Validation Tests:**
- Initial: 100 units, 30-40-30 assignment (2025-10-09)
- Weight Testing: Variable weights on A→D, D→H, H→M at 200 (2025-10-09)

#### Confirmed Working:
1. **Weight calculation is mathematically sound** - The multiplicative formula `base × modifier × preference` correctly produces probability distributions
2. **Weighted random selection is unbiased** - Distribution across goals matches expected bell curve when all weights are equal (baseline: 50.0)
3. **Path tracking is reliable** - All 100 units successfully traversed from start to goal with no pathfinding failures
4. **Traffic visualization provides clear feedback** - Color coding (Gray→Orange→Yellow→Green) makes popular routes immediately visible
5. **UI controls are intuitive** - SpinBox assignment interface works smoothly, validation prevents invalid inputs
6. **Expected probability calculation is accurate** - Theoretical distribution calculated via probability tree propagation matches actual outcomes within ±2% variance (Step 10 validation)
7. **Weight manipulation shifts distribution predictably** - Increasing specific road weights correctly biases unit flow toward connected goals

#### Architectural Decisions Validated:
- **Instant drops (no animation)** for Phase 2a was correct choice - enables rapid testing iteration (100 units in <1 second)
- **Baseline weights (all 1.0 modifiers)** proves the core math works - any future complexity builds on solid foundation
- **Traffic visualization** emerged as surprisingly useful debugging tool - visual patterns reveal probability flow instantly
- **Modular node/road/unit classes** scale well - no refactoring needed as system grew
- **Probability tree calculation** provides essential validation tool - comparing expected vs actual distributions catches math errors and confirms system integrity

#### Design Patterns That Emerged:
1. **Probability normalization at decision points** - Each node calculates `weight_sum`, then `probability = weight / weight_sum` for each exit
2. **Cumulative probability selection** - Random value 0-1 walks through cumulative probabilities until threshold crossed
3. **Dictionary-based road lookup** - `roads_by_start[node_id]` provides O(1) access to available exits
4. **Traffic data as first-class feature** - Tracking `units_traveled` on roads enables both debugging and future gameplay visualization
5. **Expected vs Actual validation pattern** - Calculate theoretical distribution independently, compare against simulation results, color-code variance for instant validation feedback

#### Next Steps:
**Immediate:** Complete Step 11 (Validation & Polish)
- Automated 1000-unit test button
- Probability sum validation (each node's exits = 100%)
- Edge case handling (zero weights, extreme values)
- Performance testing (300+ units)

**After Step 11:** Phase 2b adds:
- Goal scoring multipliers ([3x, 0.5x, 1x, 1x, 1x, 1x, 0.5x, 3x])
- Upgrade card system (3 random choices after each drop)
- Multi-round gameplay with score tracking
- Visual polish and animations
- Full roguelite loop: Assign → Drop → Score → Upgrade → Repeat

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
- **Multipliers:** [3x, 0.5x, 1x, 1x, 1x, 1x, 0.5x, 3x]
- Risk/Reward design:
  - Edge slots (0, 6): 3x multiplier, hardest to reach
  - Near-edge (1, 5): 0.5x multiplier, "trap" slots
  - Center (3, 4): 1x multiplier, safe scoring

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

- **Phase 2a (VALIDATED ✓):** Core math system validation (weight calculation, probability flow, traffic visualization)
  - Steps 1-9: Complete and tested
  - Steps 10-11: In progress (manual weight UI, validation tests)
- **Phase 2b (PENDING):** Roguelite loop (multipliers, upgrades, multi-round gameplay)
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
