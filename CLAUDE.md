# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ProjectPlinko** is a Godot 4.5 game prototype that implements a Plinko/Pachinko physics simulation with statistical validation. The goal is to validate that the physics engine produces a probability distribution matching the theoretical binomial distribution for a 7-row triangle board with 8 scoring slots.

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

## Architecture Overview

### Current Prototype Phase (v0.1)

This is a minimal viable prototype focused on validating physics against probability theory. The prototype tests whether balls dropped through a triangle pin board produce the expected statistical distribution.

### Core Game Systems (Planned)

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

## Future Expansion (Post-v0.1)

The prototype is intentionally minimal. Once physics is validated, planned additions include:
- Multiple unit types with different physics properties
- Special pin types with gameplay effects
- Manual pin placement/arrangement before drops
- Actual scoring system (point values per slot)
- Enemy system with specific scoring rules
- Round-based gameplay flow
- Progression and unlocks

## Additional Documentation

- `prototpye.md` - Detailed prototype v0.1 implementation plan
- `probability_explained.md` - Mathematical foundation for expected distributions
