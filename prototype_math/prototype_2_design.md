# Prototype 2: Strategic Plinko with Roguelite Progression

## Core Concept

A roguelite Plinko game where players strategically assign units to starting nodes, drop them through a weighted node/road network, and earn rewards based on which goal slots they reach. After each drop, players choose from 3 random upgrades to improve their board, creating a build-optimization loop similar to Balatro or Slay the Spire.

**Key Innovation:** Unlike traditional Plinko (pure luck), players make meaningful choices from turn 1 through unit assignment, starting position selection, and upgrade paths.

---

## Map Structure

### Floor Layout
```
Floor 0: [A] [B] [C]           (3 starting nodes - player assigns units here)
         /\ /\ /\
Floor 1:  [D] [E] [F] [G]      (4 nodes)
           \ /\ /\ /
Floor 2:    [H] [I] [J] [K] [L] (5 nodes)
             \ /\ /\ /\ /
Floor 3:      [M] [N] [O] [P] [Q] [R] (6 nodes)
               \ /\ /\ /\ /\ /\ /
Goals:          [0] [1] [2] [3] [4] [5] [6] (7 scoring slots)
```

### Initial State
- **All nodes start EMPTY** (no modifiers/effects)
- **All roads start BASE** (50/50 split probabilities)
- Floor 0 nodes are **assignable** (player places units here before drop)
- Upgrades are earned through roguelite loop (see below)

---

## The Four Core Elements

### 1. **Unit**
The traveling entity that drops through the board.

**Properties:**
- Base unit has **0 preference modifier** (neutral)
- Upgraded units can have **route preferences** (e.g., "prefers risky roads +30%")
- Upgraded units can have **node interactions** (e.g., "gains bonus on Fire nodes")

**Starting Pool:**
- Player starts with **10 units per drop**
- Units are consumed when dropped (reset each round)

### 2. **Node** (Land)
Landing spots on each floor that units bounce through.

**Properties:**
- **Base:** Empty node, no effects
- **Upgraded:** Can apply multiplicative modifiers to connected roads
  - Example: "Magnet Node" → `left_road_weight × 1.3`
  - Example: "Repulsor Node" → `right_road_weight × 0.7`

**Special Nodes:**
- Floor 0 nodes are **starting positions**
- Each has a **capacity limit** (default: 6 units max)
- Capacity can be upgraded through roguelite rewards

### 3. **Road**
The path between two nodes on adjacent floors.

**Properties:**
- **base_weight:** The fundamental probability value (default: 50)
- Upgrading a road increases its base_weight (e.g., 50 → 70 → 90)
- Higher weight = more likely for units to travel this path

**Connections:**
- Each node on Floor N connects to 2 nodes on Floor N+1 (left and right)
- Edge nodes may have asymmetric connections

### 4. **Goal** (Scoring Slots)
The final destination where units land and score points.

**Scoring Multipliers:**
```
Slot:       [0]  [1]  [2]  [3]  [4]  [5]  [6]
Multiplier: 3x   0.5x  1x   1x   1x   1x  0.5x  3x
Difficulty: Hard Easy  Med  Safe Safe Med  Easy Hard
```

**Risk/Reward Design:**
- **Edge slots (0, 6):** 3x multiplier - hardest to reach, biggest reward
- **Near-edge (1, 5):** 0.5x multiplier - "trap" slots, risky but not rewarding
- **Center (3, 4):** 1x multiplier - safe, consistent scoring
- **Mid (2, 5):** 1x multiplier - balanced option

**Goal Upgrades:**
- Multipliers can be upgraded (e.g., "Edge slots now 5x")
- New effects can be added (e.g., "Slot 3 grants extra unit next round")

---

## Weight Calculation System

Units choose which road to take based on **multiplicative weight stacking**.

### Formula
```gdscript
final_weight = base_road_weight × node_exit_modifier × unit_preference
```

### Example Calculation

**Scenario:**
- Unit at Node D (Floor 1)
- Two exit roads:
  - Road to Node H (left): base_weight = 70 (upgraded)
  - Road to Node I (right): base_weight = 50 (base)
- Node D has "Wind Boost" modifier: left_road × 1.2
- Unit is "Scout" type: risky_road_preference × 1.3 (Road I is tagged risky)

**Calculation:**
```
Left Road:  70 × 1.2 × 1.0 = 84
Right Road: 50 × 1.0 × 1.3 = 65

Total weight: 84 + 65 = 149
Probability: Left = 84/149 = 56.4%, Right = 65/149 = 43.6%
```

### Implementation Code
```gdscript
func calculate_route_probability(road: Road, from_node: Node, unit: Unit) -> float:
    var base = road.base_weight  # e.g., 70
    var node_mod = from_node.get_exit_modifier_for_road(road)  # e.g., 1.2
    var unit_pref = unit.get_preference_for_road(road)  # e.g., 1.3

    return base * node_mod * unit_pref

func choose_next_road(current_node: Node, unit: Unit) -> Road:
    var roads = current_node.get_exit_roads()
    var weights = []

    for road in roads:
        weights.append(calculate_route_probability(road, current_node, unit))

    return weighted_random_choice(roads, weights)
```

---

## Roguelite Loop

### Core Cycle
```
1. ASSIGN UNITS → 2. DROP → 3. SCORE → 4. CHOOSE UPGRADE → (repeat)
```

### Detailed Flow

#### **Phase 1: Unit Assignment**
- Player has **10 units** to assign to Floor 0 nodes (3 nodes: A, B, C)
- Each node has **capacity limit** (default: 6 units)
- **Constraint:** Can't put all units in one node → forces 2+ node strategy

**Strategic Considerations:**
- Left nodes (A) → higher chance at left goals (including edge slot 0)
- Right nodes (C) → higher chance at right goals (including edge slot 6)
- Middle node (B) → safe, tends toward center goals (3, 4)
- Load balancing: 6-4-0? 4-3-3? 5-5-0?

#### **Phase 2: Drop**
- Units drop simultaneously (or in rapid sequence for visual clarity)
- Each unit travels through nodes, choosing roads based on weight calculation
- Visual feedback shows paths taken

#### **Phase 3: Scoring**
- Units land in goal slots
- Calculate total score: `Σ (units_in_slot × slot_multiplier × base_points)`
- Display results (e.g., "Slot 0: 2 units × 3x = 6 points")

#### **Phase 4: Choose Upgrade**
- System offers **3 random upgrade cards**
- Player picks **1**
- Upgrade is applied to board
- Return to Phase 1 with upgraded board

### Upgrade Categories

1. **Road Upgrades**
   - "Upgrade Left Road from Node D" → base_weight: 50 → 70
   - "Mega Highway" → base_weight: 50 → 100

2. **Node Upgrades**
   - "Magnet Tower" → left_exit_roads × 1.3
   - "Repulsor Field" → right_exit_roads × 0.7
   - "Chaos Node" → randomize weights on each drop

3. **Unit Upgrades**
   - "Scout Training" → all units gain risky_road_preference × 1.3
   - "Tank Corps" → all units gain safe_road_preference × 1.2
   - "Lucky Charm" → all units gain edge_goal_attraction × 1.5

4. **Goal Upgrades**
   - "Edge Mastery" → edge slots (0, 6) multiplier: 3x → 5x
   - "Safety Net" → near-edge slots (1, 5) multiplier: 0.5x → 1x
   - "Bonus Slot" → Slot 3 grants +2 units next round

5. **Capacity Upgrades**
   - "Expanded Platform A" → Node A capacity: 6 → 8
   - "Mass Drop" → All Floor 0 nodes capacity: 6 → 7
   - "Unit Surplus" → Starting units: 10 → 12

---

## Starting Node Strategy

Why starting node choice matters **before any upgrades:**

### Probability Flow (Base Board)
```
Starting from Node A (left):
→ Slightly higher chance to reach Goals 0, 1, 2 (left side)

Starting from Node C (right):
→ Slightly higher chance to reach Goals 4, 5, 6 (right side)

Starting from Node B (center):
→ Balanced distribution, tends toward Goals 2, 3, 4 (center)
```

### Strategic Implications

**Risk-Seeking Strategy:**
- Load up edge nodes (A or C) heavily
- Aim for edge goal slots (0 or 6) with 3x multiplier
- High variance, high reward

**Safe Strategy:**
- Distribute evenly (3-4-3 or 4-2-4)
- Target center goals (3, 4) with 1x multiplier
- Low variance, consistent scoring

**Hybrid Strategy:**
- Asymmetric load (6-4-0 or 0-4-6)
- Focus on one side's edge slot while keeping some safety

---

## Example Turn Walkthrough

### Turn 1 (Base Board)
**Setup:**
- 10 units to assign
- All nodes empty, all roads base (50/50)
- Goal multipliers: [3x, 0.5x, 1x, 1x, 1x, 1x, 0.5x, 3x]

**Player Decision:**
- Assigns 6 units to Node A (left)
- Assigns 4 units to Node B (center)
- Node C empty

**Drop Results:**
```
Goal 0: 1 unit  → 1 × 3x = 3 points
Goal 1: 2 units → 2 × 0.5x = 1 point
Goal 2: 3 units → 3 × 1x = 3 points
Goal 3: 2 units → 2 × 1x = 2 points
Goal 4: 2 units → 2 × 1x = 2 points
Total: 11 points
```

**Upgrade Offered:**
1. "Mega Left Road" (upgrade road from D→H to 70 weight)
2. "Magnet Node D" (left exits from D × 1.3)
3. "Edge Mastery" (slots 0, 6 now 5x multiplier)

**Player Picks:** "Edge Mastery" (risky but high upside)

---

### Turn 2 (With Edge Mastery)
**Setup:**
- Same 10 units
- Goal multipliers NOW: [5x, 0.5x, 1x, 1x, 1x, 1x, 0.5x, 5x]

**Player Decision:**
- Doubles down on edges: 6 to Node A, 4 to Node C

**Drop Results:**
```
Goal 0: 2 units → 2 × 5x = 10 points
Goal 1: 1 unit  → 1 × 0.5x = 0.5 points
Goal 2: 1 unit  → 1 × 1x = 1 point
Goal 4: 1 unit  → 1 × 1x = 1 point
Goal 5: 2 units → 2 × 0.5x = 1 point
Goal 6: 3 units → 3 × 5x = 15 points
Total: 28.5 points
```

**High risk paid off!** Edge strategy worked with upgraded multipliers.

---

## Prototype Implementation Phases

### **Phase 2a: Core Math System** ✓
**Goal:** Validate weight calculation and probability flow.

**Features:**
- 4-floor map (3→4→5→6 nodes → 7 goals)
- Base roads (all 50 weight)
- Empty nodes (no modifiers)
- Unit assignment UI (10 units → 3 Floor 0 nodes, 6 capacity each)
- Weight calculation system (multiplicative stacking)
- Drop simulation (units travel through board)
- Goal slot landing detection
- Basic scoring (no multipliers yet, just count units per slot)

**Validation Criteria:**
- Does weight calculation produce expected distributions?
- Can we manually adjust road weights and see probability changes?
- Is unit assignment intuitive?

---

### **Phase 2b: Roguelite Loop**
**Goal:** Add progression and strategic depth.

**Features:**
- Goal multipliers (3x, 0.5x, 1x, etc.)
- Scoring system with multipliers
- Upgrade card system (3 random choices after drop)
- At least 2 upgrade types implemented:
  - Road upgrades (change base_weight)
  - Goal upgrades (change multipliers)
- Multi-round gameplay (drop → score → upgrade → repeat)
- Visual feedback for upgrades applied

**Validation Criteria:**
- Are upgrade choices meaningful?
- Does the build optimization loop feel satisfying?
- Can players execute different strategies (safe vs risky)?

---

### **Phase 2c: Full Feature Set**
**Goal:** Polish and expand strategic options.

**Features:**
- Node upgrade system (modifiers like Magnet, Repulsor)
- Unit variety (different unit types with preferences)
- Capacity upgrades (expand Floor 0 node limits)
- Advanced goal effects (bonus units, special triggers)
- Visual polish (road highlights, weight indicators)
- Balance tuning based on playtesting

**Validation Criteria:**
- Are all 5 upgrade categories interesting?
- Does the game have replayability?
- Can we identify "build archetypes" (Rush Edge, Safe Center, Chaos, etc.)?

---

## Design Principles

1. **Meaningful Turn 1:** Even with nothing upgraded, unit assignment creates strategy
2. **Multiplicative Stacking:** Weight modifiers multiply intuitively (1.2 × 1.3 = 1.56x boost)
3. **Risk/Reward Baked In:** Goal multipliers create natural strategic spectrum (safe → risky)
4. **Upgrade Variety:** 5 categories ensure no two runs feel identical
5. **Visual Clarity:** Players should understand probabilities without deep math knowledge
6. **Roguelite Core:** Meaningful build choices, run variety, risk mitigation vs reward chasing

---

## Open Questions & Future Refinements

### Balancing Questions
- What's the right starting unit count? (10? 12? 15?)
- Should capacity limits increase naturally over turns? Or only via upgrades?
- How many rounds per run? (10? 20? Until failure condition?)
- Should there be a "health" or "energy" system to add failure stakes?

### Expansion Ideas
- **Enemies:** Goals become "enemy slots" - landing there causes damage/penalties
- **Special Pins:** Nodes with one-time effects ("Teleporter" jumps unit ahead a floor)
- **Multi-Unit Synergies:** "If 3+ units land in same slot, double multiplier"
- **Persistent Progression:** Meta-currency to unlock permanent upgrades between runs

### Technical Questions
- Should drops be instant/simulated for speed? Or always animated?
- How to handle simultaneous multi-unit pathfinding performance?
- Save/load system for run persistence?

---

## Summary

Prototype 2 transforms Plinko from a passive physics toy into a **strategic roguelite optimization puzzle**. By adding unit assignment, weighted roads, node modifiers, goal multipliers, and a build-crafting upgrade loop, every decision matters from turn 1 onward.

The core loop is tight:
**Assign → Drop → Score → Upgrade → Repeat**

And the strategic depth emerges from:
- **Spatial strategy** (where to place units on Floor 0)
- **Build optimization** (which upgrades to pursue)
- **Risk management** (safe center vs risky edges)
- **Route manipulation** (upgrading roads/nodes to funnel units)

This has the potential to be a deeply replayable game with emergent strategies and player expression, similar to Balatro's "build crafting" appeal.

**Next Step:** Implement Phase 2a to validate the core math and weight calculation system works as expected!
