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

## Physics Tuning Parameters

Initial values to test (requires iteration):
- **Ball bounce**: 0.5-0.8
- **Ball friction**: 0.1-0.3
- **Pin friction**: 0.2
- **Pin bounce**: 0.3-0.5
- **Gravity**: Start with Godot default, adjust for feel

## Success Validation Criteria

The physics model is considered validated when:
- After 128+ balls, distribution matches expected probabilities within ±3%
- Center slots (3 & 4) consistently receive ~54% of balls combined
- Edge slots (0 & 7) each receive <1% of balls
- No systematic left/right bias
- Ball behavior feels satisfying (not too floaty or rigid)

## Known Issues to Watch For

- Balls getting stuck on pins (collision geometry issues)
- Balls passing through pins (physics step/velocity issues)
- Distribution heavily skewed from expected probabilities
- Overly random or overly deterministic behavior

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
