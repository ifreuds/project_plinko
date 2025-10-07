# Plinko War - Prototype v0.1 Plan
Engine: Godot 4.5
Goal: Validate core loop and physics - "Does the Plinko board behave as expected mathematically?"

## What We're Building (Minimum Viable Prototype)

A testing environment where:
1. Balls drop from the top in a 7-row triangle board
2. Balls bounce off static pins
3. Balls land in 8 scoring slots at the bottom
4. Statistics track distribution to validate physics against probability model

What's NOT in this prototype:
- No unit types yet (just one standard ball)
- No special pins (just basic collision pins)
- No enemies or rounds
- No progression or unlocks
- No scoring system (just counting and statistics)

## Core Features to Implement

### 1. Basic Scene Setup
- Create a 2D scene (game board)
- Set up camera to view the entire board
- Define play area boundaries

### 2. Pin System (7-Row Triangle)
- Create pin objects (static circles/pegs)
- Arrange pins in triangle pattern:
  - Row 1: 1 pin
  - Row 2: 2 pins
  - Row 3: 3 pins
  - Row 4: 4 pins
  - Row 5: 5 pins
  - Row 6: 6 pins
  - Row 7: 7 pins
- Pins should be StaticBody2D with CircleShape2D collision
- Pins have physics material for bounce

### 3. Ball Physics
- Create ball object (RigidBody2D with CircleShape2D)
- Ball spawns at top center of board
- Ball affected by gravity
- Ball bounces off pins (physics material with bounce property)
- Ball has slight randomness in initial drop angle
- Ball is removed from scene after landing in slot

### 4. Scoring Slots (8 slots at bottom)
- Create 8 slots numbered 0-7 from left to right
- Each slot is an Area2D that detects ball entry
- When ball enters slot, increment that slot's counter
- Ball is removed after being counted

### 5. Testing Interface UI
- Input field: Set number of balls to drop (default: 128)
- "Drop Balls" button: Automatically spawns and drops all balls in sequence
- "Reset Counters" button: Clear all statistics and start fresh
- "Fast Forward" toggle: Speed up physics simulation (optional for v0.1)
- Total balls dropped counter

### 6. Per-Slot Statistics Display
Each of the 8 slots displays:
- Slot number (0-7)
- Expected probability as fraction (e.g., "35/128")
- Expected percentage (e.g., "27.34%")
- Actual ball count (e.g., "Balls: 34")
- Actual percentage based on total balls dropped (e.g., "Actual: 26.5%")
- Visual indicator: Background color intensity based on ball count (heatmap)

### 7. Expected Probability Reference
Display somewhere on screen:
- Slot 0: 1/128 (0.78%)
- Slot 1: 7/128 (5.47%)
- Slot 2: 21/128 (16.41%)
- Slot 3: 35/128 (27.34%)
- Slot 4: 35/128 (27.34%)
- Slot 5: 21/128 (16.41%)
- Slot 6: 7/128 (5.47%)
- Slot 7: 1/128 (0.78%)

## Technical Requirements

### Physics Settings Needed:
- Gravity: Adjust to feel good (start with default)
- Ball bounce: 0.5-0.8 (needs testing)
- Ball friction: 0.1-0.3 (needs testing)
- Pin friction: 0.2 (needs testing)
- Pin bounce: 0.3-0.5 (needs testing)

### Key Godot Nodes:
- Ball: RigidBody2D + CircleShape2D + Sprite2D
- Pin: StaticBody2D + CircleShape2D + Sprite2D
- Scoring Slot: Area2D + CollisionShape2D + Label
- UI: CanvasLayer + VBoxContainer (for controls) + Labels (for stats)

### Scripts Needed:
1. ball.gd - Ball physics and behavior
2. scoring_slot.gd - Detect ball entry, increment counter, emit signal
3. game_manager.gd - Spawn balls, track total statistics, reset counters
4. slot_display.gd - Update slot UI with count and percentages

## Success Criteria

Physics and probability model is validated if:
- After dropping 128+ balls, distribution roughly matches expected probabilities (within ±3%)
- Center slots (3 & 4) consistently get most balls (~54% combined)
- Edge slots (0 & 7) rarely get balls (<1% each)
- No systematic bias to left or right side
- Ball behavior feels satisfying (not too floaty, not too rigid)

Red flags to watch for:
- Ball gets stuck on pins
- Ball passes through pins (collision issues)
- Distribution heavily skewed from expected probabilities
- Balls behave too randomly or too deterministically

## Iteration Questions After v0.1

After building and testing this, we'll answer:
1. Does the probability distribution match theory?
2. Does the ball drop feel satisfying to watch?
3. Is the bounce behavior predictable enough for future strategy?
4. Do we need to adjust pin spacing or board size?
5. What physics settings give the best feel?
6. Is 7 rows the right amount, or should we test 5 or 9 rows?

## Resources for Godot 4.5 Beginners

Key Documentation:
- RigidBody2D: https://docs.godotengine.org/en/stable/classes/class_rigidbody2d.html
- PhysicsMaterial: https://docs.godotengine.org/en/stable/classes/class_physicsmaterial.html
- Area2D signals: https://docs.godotengine.org/en/stable/classes/class_area2d.html
- Control nodes for UI: https://docs.godotengine.org/en/stable/classes/class_control.html

Helpful Tutorials:
- Godot 2D physics basics
- Creating a Plinko/Pachinko game in Godot
- Collision detection with Area2D
- Creating simple UI with Control nodes

## Next Steps After Prototype v0.1

Once v0.1 works and validates physics:
1. Add ability to manually place/move pins before dropping balls
2. Implement actual scoring system (slots have point values)
3. Design 3 unit types with different physics properties
4. Design 5 pin types with special effects
5. Create one enemy with specific scoring rules
6. Build one complete round flow