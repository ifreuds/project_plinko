# Plinko Probability Mathematics

## 7-Row Triangle Board Setup

Board Configuration:
- 7 rows of pins in triangle formation
- 8 bottom slots (numbered 0-7 from left to right)
- Each ball starts at top center
- At each pin, ball has 50% chance to go left or right

## The Math (Binomial Distribution)

This is a Galton Board - it demonstrates binomial probability distribution.

For 7 rows:
- Ball makes 7 decisions (left or right at each row)
- Total possible paths = 2^7 = 128 paths
- Landing position determined by: "How many times did ball go RIGHT?"

Probability Formula:
P(slot_n) = C(7, n) / 128

Where C(7, n) = "7 choose n" = combinations formula

## Expected Probability for Each Slot

Slot 0: 0 Rights, 7 Lefts   | C(7,0) = 1  | 1/128   | 0.78%
Slot 1: 1 Right,  6 Lefts   | C(7,1) = 7  | 7/128   | 5.47%
Slot 2: 2 Rights, 5 Lefts   | C(7,2) = 21 | 21/128  | 16.41%
Slot 3: 3 Rights, 4 Lefts   | C(7,3) = 35 | 35/128  | 27.34%
Slot 4: 4 Rights, 3 Lefts   | C(7,4) = 35 | 35/128  | 27.34%
Slot 5: 5 Rights, 2 Lefts   | C(7,5) = 21 | 21/128  | 16.41%
Slot 6: 6 Rights, 1 Left    | C(7,6) = 7  | 7/128   | 5.47%
Slot 7: 7 Rights, 0 Lefts   | C(7,7) = 1  | 1/128   | 0.78%

Visual Distribution (Bell Curve):
Center slots (3 & 4) get most balls (~54% combined)
Edge slots (0 & 7) rarely get balls (<1% each)

## What This Means for Gameplay

1. Center slots (3 & 4) are "safe bets" - about 54% of balls land here
2. Edge slots (0 & 7) are "high risk" - less than 1% chance naturally
3. Strategic pins can BREAK this distribution - that's the fun!
4. Enemy weak spots on edges = harder but higher reward

## For Testing (Drop 128 balls)

If physics is perfect and truly random, expected results:
- Slot 0: approximately 1 ball
- Slot 1: approximately 7 balls
- Slot 2: approximately 21 balls
- Slot 3: approximately 35 balls
- Slot 4: approximately 35 balls
- Slot 5: approximately 21 balls
- Slot 6: approximately 7 balls
- Slot 7: approximately 1 ball

Reality: You'll see small variance due to physics randomness, but should be close!

## Combinations Formula Reference

C(n, k) = n! / (k! × (n-k)!)

For 7 rows:
C(7, 0) = 1
C(7, 1) = 7
C(7, 2) = 21
C(7, 3) = 35
C(7, 4) = 35
C(7, 5) = 21
C(7, 6) = 7
C(7, 7) = 1