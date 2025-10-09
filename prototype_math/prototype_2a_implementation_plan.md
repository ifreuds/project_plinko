# Prototype 2a Implementation Plan

## Goal
Validate the core math system for weight-based routing. Prove that the weight calculation formula produces expected probability distributions.

## Scope
- **NO** roguelite loop (no upgrades, no scoring multipliers)
- **NO** animation (instant/simulated drops for fast iteration)
- **YES** core math validation (weight calculation works correctly)
- **YES** comprehensive verification tools (logging, stats, probability display)

---

## Architecture Decisions

### Scene Structure
- **New scene:** `prototype_math/prototype_2a.tscn`
- **Reason:** v0.1 is physics-based, v0.2 is math-based — incompatible paradigms
- **Benefit:** Keeps v0.1 validated prototype intact as reference

### Visual Style
- **Nodes:** Rectangles (simple ColorRect or Polygon2D)
- **Roads:** Thin lines (Line2D connecting nodes)
- **Units:** Circles (shown in goal slots after landing, not during travel)
- **UI:** Debug-style (quick and functional, not polished)

### Movement Approach
- **No animation** during Phase 2a
- Units instantly traverse paths via calculation
- Focus on **verification tools** instead of visual feedback
- Animation can be added in Phase 2b/2c if desired

---

## Implementation Status

**Date Updated:** 2025-10-09

- Steps 1-10: **COMPLETE AND VALIDATED ✓**
- Step 11: **PENDING**

**Test Results:**
- Initial: 100-unit drop with 30-40-30 assignment
  - ✅ All units reached valid goal slots
  - ✅ Distribution shows expected bell curve (center-heavy)
  - ✅ No crashes, errors, or null references
  - ✅ Path tracking functional (first 20 units logged)
  - ✅ Traffic visualization working correctly
  - ✅ Statistics display accurate

- Weight Testing: A→D, D→H, H→M at 200 weight
  - ✅ Units correctly concentrated in Goals 0-1 (left side)
  - ✅ Expected probability calculation accurate (within ±2% variance)
  - ✅ Color-coded validation working (green/yellow/red diff indicators)
  - ✅ Modified road visual feedback clear (magenta thick lines)

## Implementation Steps

### **Step 1: Board Structure Expansion** ✓ COMPLETE
Create new 4-floor layout matching v0.2 design.

**Tasks:**
- Create `prototype_math/prototype_2a.tscn`
- Create `prototype_math/game_manager_2a.gd`
- Position nodes in proper layout:
  - Floor 0: 3 nodes (A, B, C)
  - Floor 1: 4 nodes (D, E, F, G)
  - Floor 2: 5 nodes (H, I, J, K, L)
  - Floor 3: 6 nodes (M, N, O, P, Q, R)
  - Goals: 7 slots (0-6)
- Use ColorRect rectangles for visual representation

**Verification:**
- Open scene in Godot, visually confirm layout
- Nodes are evenly spaced and floors are clearly separated

---

### **Step 2: Road System Foundation** ✓ COMPLETE
Create Road class and generate connections.

**Tasks:**
- Create `prototype_math/road.gd` with properties:
  - `base_weight: float = 50.0`
  - `from_node: Node2D` (reference to source node)
  - `to_node: Node2D` (reference to destination node)
- Generate roads connecting each node to 2 nodes on floor below
- Add Line2D visual representation for each road

**Verification:**
- Print all roads to console: `"Road: A → D (weight: 50)"`
- Visually see lines connecting nodes correctly

---

### **Step 3: Node System with Road Connections** ✓ COMPLETE
Make nodes aware of their exit roads.

**Tasks:**
- Create `prototype_math/board_node.gd` with properties:
  - `floor_level: int`
  - `node_id: String` (A, B, C, D, etc.)
  - `exit_roads: Array[Road]` (roads leaving this node)
- Method: `get_exit_modifier_for_road(road: Road) -> float` (returns 1.0 for now)
- Populate exit_roads during board setup

**Verification:**
- Select node, print its exit roads
- Confirm each Floor 0-2 node has 2 exit roads
- Confirm Floor 3 nodes have 0 exit roads (final floor)

---

### **Step 4: Weight Calculation Core** ✓ COMPLETE
Implement multiplicative weight formula.

**Tasks:**
- Create `prototype_math/unit.gd` with properties:
  - `unit_id: int`
  - `current_node: BoardNode`
  - `path_history: Array[String]` (track nodes visited)
- Method: `get_preference_for_road(road: Road) -> float` (returns 1.0 for now)
- Implement in `game_manager_2a.gd`:
```gdscript
func calculate_route_probability(road: Road, from_node: BoardNode, unit: Unit) -> float:
    var base = road.base_weight
    var node_mod = from_node.get_exit_modifier_for_road(road)
    var unit_pref = unit.get_preference_for_road(road)
    return base * node_mod * unit_pref
```

**Verification:**
- Create test node with 2 roads (weight 70 and 50)
- Calculate probabilities: should get 70/120 = 58.3% and 50/120 = 41.7%
- Print results, verify math is correct

---

### **Step 5: Weighted Random Selection** ✓ COMPLETE
Implement weighted random choice for path selection.

**Tasks:**
- Implement in `game_manager_2a.gd`:
```gdscript
func choose_next_road(current_node: BoardNode, unit: Unit) -> Road:
    var roads = current_node.exit_roads
    var weights = []
    for road in roads:
        weights.append(calculate_route_probability(road, current_node, unit))
    return weighted_random(roads, weights)

func weighted_random(items: Array, weights: Array):
    var total = 0.0
    for w in weights:
        total += w
    var rand_val = randf() * total
    var cumulative = 0.0
    for i in range(items.size()):
        cumulative += weights[i]
        if rand_val <= cumulative:
            return items[i]
    return items[-1]  # Fallback
```

**Verification:**
- Run 1000 iterations with 70/50 split
- Count how many times each road chosen
- Verify distribution: ~580 left / ~420 right (within 5% tolerance)

---

### **Step 6: Unit Pathfinding** ✓ COMPLETE
Create unit traversal logic from Floor 0 → Goal.

**Tasks:**
- Implement in `unit.gd`:
```gdscript
func traverse_board(starting_node: BoardNode, game_manager) -> int:
    current_node = starting_node
    path_history.append(current_node.node_id)

    while current_node.floor_level < 3:  # While not at final floor
        var chosen_road = game_manager.choose_next_road(current_node, self)
        current_node = chosen_road.to_node
        path_history.append(current_node.node_id)

    # Map final node to goal slot
    var goal_slot = game_manager.map_node_to_goal(current_node)
    return goal_slot
```

**Verification:**
- Drop 1 unit from Node A
- Print its path: "A → D → H → M → Goal 2"
- Verify path makes sense (each step goes down one floor)
- Run 100 units, check all reach valid goals

---

### **Step 7: Unit Assignment System** ✓ COMPLETE
UI for assigning units to Floor 0 nodes.

**Tasks:**
- Add UI elements to scene:
  - 3 SpinBox inputs (one for each Floor 0 node)
  - Label showing "Total: X/10"
  - "Drop Units" button
- Add validation:
  - Each node max 6 units
  - Total must equal 10
  - Disable button if invalid

**Verification:**
- Try valid assignment (6-4-0): button enabled
- Try invalid (7-5-0 = 12 total): button disabled, error message shown
- Try invalid (8-2-0): button disabled (Node A exceeds capacity)

---

### **Step 8: Goal Slot Detection** ✓ COMPLETE
Map final floor nodes to goal slots.

**Tasks:**
- Implement mapping function:
```gdscript
func map_node_to_goal(final_node: BoardNode) -> int:
    # Floor 3 has 6 nodes (M, N, O, P, Q, R)
    # Goals have 7 slots (0-6)
    # Mapping:
    # M → between 0 and 1 → slot 0 or 1
    # N → slot 1 or 2
    # O → slot 2 or 3
    # P → slot 3 or 4
    # Q → slot 4 or 5
    # R → slot 5 or 6

    var node_positions = ["M", "N", "O", "P", "Q", "R"]
    var idx = node_positions.find(final_node.node_id)
    # Each node can route to 2 goals below it
    # We need to decide: does unit go left or right from final node?
    # For now: randomize 50/50
    return idx + randi_range(0, 1)
```

**Verification:**
- Drop 100 units, verify all land in slots 0-6
- Verify no units land in invalid slots (-1, 7, etc.)
- Check distribution makes rough sense (not all in one slot)

---

### **Step 9: Basic Scoring Display** ✓ COMPLETE
Show unit distribution across goals.

**Tasks:**
- Add UI panel showing:
```
=== GOAL DISTRIBUTION ===
Goal 0: 3 units  (3%)   [███░░░░░░░]
Goal 1: 8 units  (8%)   [████████░░]
Goal 2: 19 units (19%)  [███████████████████░]
...
```
- Track `goal_counts: Array[int]` (size 7)
- Update UI after each drop round

**Verification:**
- Drop 100 units from balanced assignment (3-4-3)
- Verify center goals (3, 4) get more units than edge goals (0, 6)
- Verify total adds up to 100

---

### **Step 10: Manual Weight Testing** ✓ COMPLETE (VALIDATED 2025-10-09)
UI to manually adjust road weights.

**Tasks:**
- ✅ Add debug panel:
  - ✅ Dropdown to select a road (e.g., "A → D") - Lists all 30 roads
  - ✅ Slider to set weight (10 - 200, step: 5) with real-time value display
  - ✅ "Apply Weight" button - Sets selected road to chosen weight
  - ✅ "Reset All Weights" button - Returns all roads to default 50
  - ✅ Current weight display - Shows slider value updating live
- ✅ Store modified weights persistently during session
- ✅ Visual feedback for modified roads (MAGENTA thick lines vs gray thin)

**Enhanced Feature: Expected Probability Calculation**
- ✅ Implemented `calculate_expected_distribution()` (80+ lines)
  - Calculates theoretical goal distribution based on:
    - Current road weights (including manual modifications)
    - Unit assignment percentages
    - Full probability tree propagation through all 4 floors
  - Walks complete probability tree: Floor 0 → Floor 1-3 weighted splits → Goal mapping
- ✅ Results display enhancement:
  - Changed `Label` to `RichTextLabel` for BBCode color support
  - Shows Expected vs Actual comparison table
  - Format: `Goal | Actual | Expected | Diff`
  - Color-coded variance validation:
    - GREEN: ±2% (excellent match)
    - YELLOW: ±2-5% (acceptable variance)
    - RED: >5% (investigation needed)

**Verification:**
- ✅ Baseline test: All roads 50, drop 100 units, record distribution - Matches expected bell curve
- ✅ Extreme test: A→D, D→H, H→M all at 200 weight
  - Result: Units concentrated in Goals 0-1 (left side) as expected
  - Expected % calculation accurate (matched weighted path probabilities)
  - Actual distribution within acceptable variance (mostly green diffs)
- ✅ Visual feedback working: Modified roads clearly visible in magenta

---

### **Step 11: Validation & Polish** ⏳ PENDING
Ensure math correctness and system stability.

**Tasks:**
- Add validation checks:
  - Probabilities sum to 100% at each node
  - No null/invalid road selections
  - All units reach valid goals
- Add automated test button:
  - "Run Validation Test" → drops 1000 units, checks distribution
  - Expected: balanced board → center goals ~50%, edges ~5%
- Edge case handling:
  - What if all roads have 0 weight? (shouldn't happen, but handle gracefully)
  - What if unit gets stuck? (shouldn't happen, but log error)

**Verification:**
- Run 1000 unit drop test multiple times
- Verify consistent results (within statistical variance)
- Test extreme weight configurations (all 0, all 200, asymmetric)
- Confirm no crashes or errors

---

## Verification Tools (Built-In)

### **1. Path Tracing Log**
Console output showing each unit's journey:
```
Unit #1: A → D(L,58%) → H(R,42%) → M(L,63%) → Goal 2
Unit #2: A → D(L,58%) → I(L,55%) → N(R,48%) → Goal 3
```

**Implementation:**
- Store path_history in Unit class
- Print after each unit completes journey
- Show node names + chosen direction + probability

---

### **2. Probability Display Panel**
Before dropping, show calculated probabilities:
```
=== FROM NODE A (6 units assigned) ===
Exit roads:
  → D (left):  70 weight = 58.3% likely
  → E (right): 50 weight = 41.7% likely

Expected: ~3-4 units → D, ~2-3 units → E
```

**Implementation:**
- Calculate probabilities for all Floor 0 nodes
- Display in UI panel before drop
- Update when weights change

---

### **3. Statistical Summary**
After drop, show aggregate results:
```
=== GOAL DISTRIBUTION (100 units dropped) ===
Goal 0: 3 units  (3%)   [■■■░░░░░░░]
Goal 1: 8 units  (8%)   [■■■■■■■■░░]
...
Center (3+4): 52% ✓ Expected ~50-55% on balanced board
```

**Implementation:**
- Track counts per goal
- Calculate percentages
- ASCII bar chart visualization
- Validation check for center vs edge distribution

---

### **4. Road Traffic Visualization** (Optional)
Color roads by traffic volume after drop:
- Green (thick): 5+ units
- Yellow (medium): 2-4 units
- Red (thin): 0-1 units

**Implementation:**
- Track `traffic_count: int` per road
- Update Line2D color/width based on count
- Reset on new drop

---

### **5. Step-Through Debug Mode** (Optional)
One unit at a time, press SPACE to advance:
```
[SPACE] Unit #1 at Node A... chose D (left, 58%)
[SPACE] Unit #1 at Node D... chose H (left, 63%)
[SPACE] Unit #1 reached Goal 2! ✓
```

**Implementation:**
- Boolean flag `step_mode: bool`
- Pause execution after each unit decision
- Resume on input

---

### **6. Automated Validation Tests** (Optional)
Built-in correctness checks:
```
✅ PASS: Balanced board center distribution (52% actual vs 50-55% expected)
✅ PASS: Probability sum check (all nodes sum to 100%)
❌ FAIL: Left-biased board distribution (48% left vs 70% expected)
```

**Implementation:**
- Predefined test scenarios
- Run 1000 units, check against expected ranges
- Display pass/fail with details

---

## Success Criteria

Phase 2a is **complete** when:

✅ ~~All 11 implementation steps are finished~~ **10/11 COMPLETE (Step 11 pending)**
✅ Weight calculation produces correct probabilities (manual verification) **VALIDATED**
⏳ 1000-unit drop test shows expected distribution on balanced board **PENDING (Step 11)**
✅ ~~Manual weight adjustment demonstrably affects unit distribution~~ **VALIDATED (Step 10)**
✅ Expected probability calculation matches actual outcomes **VALIDATED (within ±2% variance)**
✅ No crashes, null errors, or infinite loops **VALIDATED**
✅ Path tracing log shows valid paths (no skipped floors, invalid nodes) **VALIDATED**
✅ All units reach valid goal slots (0-6) **VALIDATED**

**Current Status:** Core math system fully validated. Expected vs Actual probability system working perfectly. Only comprehensive validation tests (Step 11) remaining before Phase 2b.

---

## Non-Goals (Explicitly Out of Scope)

❌ Animation (instant drops only)
❌ Scoring multipliers (just count units per slot)
❌ Upgrade system (weights are manually set via debug UI)
❌ Node modifiers (all nodes return 1.0 for get_exit_modifier)
❌ Unit preferences (all units return 1.0 for get_preference)
❌ Polished UI (debug-style only)
❌ Sound effects or visual polish

These will be added in **Phase 2b** (roguelite loop) and **Phase 2c** (full features).

---

## File Structure

```
prototype_math/
├── prototype_2a.tscn          # Main scene
├── game_manager_2a.gd         # Game logic, weight calculation
├── board_node.gd              # Node class (floors 0-3)
├── road.gd                    # Road class (base_weight, connections)
├── unit.gd                    # Unit class (pathfinding, history)
├── goal_slot.gd               # Goal slot class (optional, might just be ints)
└── prototype_2a_implementation_plan.md  # This file
```

---

## Next Steps

### Immediate Task:
1. **Complete Step 11** — Validation & polish
   - Automated 1000-unit test button
   - Probability sum checks (verify each node's exits = 100%)
   - Edge case handling (zero weights, extreme values)
   - Performance testing (300+ units)

### After Phase 2a Complete:
Once Steps 10-11 are finished and all success criteria met, we proceed to **Phase 2b: Roguelite Loop**:
- Goal scoring multipliers ([3x, 0.5x, 1x, 1x, 1x, 1x, 0.5x, 3x])
- Upgrade card system (3 random choices after each drop)
- Multi-round gameplay with score tracking
- Visual polish and animations

---

## Update Log

**2025-10-09 (Session 1):** Steps 1-9 completed and validated
- 100-unit test successful (30-40-30 assignment)
- All core systems functional (weight calculation, pathfinding, statistics, traffic visualization)
- No crashes or errors observed
- Ready to proceed with Steps 10-11

**2025-10-09 (Session 2):** Step 10 completed and validated
- Manual weight testing UI fully implemented
  - Road selection dropdown (30 roads)
  - Weight slider (10-200, step: 5)
  - Apply/Reset buttons
  - Visual feedback (magenta thick lines for modified roads)
- **Major Enhancement:** Expected probability calculation system
  - `calculate_expected_distribution()` - Full probability tree propagation
  - Expected vs Actual comparison display
  - Color-coded validation (green/yellow/red)
- Validation test: A→D, D→H, H→M at 200 weight
  - Units correctly concentrated in Goals 0-1
  - Expected calculation matched actual within ±2% variance
  - Color-coding working correctly
- Ready to proceed with Step 11 (final validation & polish)
