# Flutter I/O Pinball – Layout and Asset Mapping

**Document ID:** 4_06

## Coordinate System (Flutter)

- **Board:** 101.6 x 143.8, **center (0, 0)**. Y positive = down.
- **Bounds:** left -50.8, right 50.8, top -71.9, bottom 71.9.

## Godot Transform

Use **scale = 5** and **center = (400, 300)** (viewport half):

- **Flutter (x, y) → Godot:** `(400 + x * 5, 300 + y * 5)`

Examples:
- Plunger (41, 43.7) → (605, 518.5)
- Backbox (0, -87) anchor bottom → top of board: Godot UI at top, y ≈ 0–80
- Flipper left (-12.05, 43.6) → (339.75, 518)
- Flipper right (4.8, 43.6) → (424, 518)
- Google Word (-4.45, 1.8) → (377.75, 309)
- Drain: bottom edge y = 71.9 → Godot y = 300 + 359.5 = 659.5

## Flutter Component Positions (for reference)

| Component | Flutter position |
|-----------|------------------|
| Backbox | (0, -87) anchor bottomCenter |
| Plunger | (41, 43.7) |
| Rocket | (42.8, 62.3) |
| Flipper L | (-12.05, 43.6) |
| Flipper R | (4.8, 43.6) |
| Kicker L/R | (±22.44 + adj, 25.1) |
| Google Word | (-4.45, 1.8) |
| Multipliers x2–x6 | (-19.6,-2), (12.8,-9.4), (-0.3,-21.2), (-8.9,-28), (9.8,-30.7) |
| Sparky bumpers | (-22.9,-41.65), (-21.25,-57.9), (-3.3,-52.55) |
| Sparky animatronic | (-14, -58.2) |
| Flutter Forest Signpost | (7.95, -58.35) |
| Dash bumpers | (18.55,-59.35), (8.95,-51.95), (21.8,-46.75) |
| Dash animatronic | (20, -66) |
| Android bumpers | (-25.2,1.5), (-32.9,-9.3), (-20.7,-13) |
| Android spaceship | (-26.5, -28.5) |
| Chrome Dino | (12.2, -6.9) |

## Flutter Assets (pinball_components, pinball_theme)

- **Board:** `board_background.png`
- **Backbox:** `backbox/marquee.png`, `display_divider.png`, `display_title_decoration.png`
- **Score HUD:** `score/mini_score_background.png` (from main assets/images/score/)
- **Launcher:** `launch_ramp/ramp.png`, `plunger/plunger.png`, `plunger/rocket.png`
- **Flippers:** `flipper/left.png`, `flipper/right.png`
- **Google Word:** `google_word/letter1..6` (dimmed.png, lit.png each)
- **Multiplier:** `multiplier/x2..x6` (dimmed.png, lit.png)
- **Multiball:** `multiball/dimmed.png`, `multiball/lit.png`
- **Skill shot:** `skill_shot/decal.png`, `dimmed.png`, `lit.png`, `pin.png`
- **Android:** bumper a/b/cow, ramp, rail, spaceship (animatronic, saucer)
- **Dash:** bumper a/b/main, animatronic
- **Dino:** animatronic (head, mouth), walls
- **Sparky:** bumper a/b/c, computer (base, glow, top), animatronic
- **Kicker:** left/right (dimmed, lit)
- **Score popups:** `score/five_thousand.png`, `twenty_thousand.png`, `two_hundred_thousand.png`, `one_million.png`
- **Character themes:** pinball_theme/assets/images/{android,dash,dino,sparky}/ ball.png, icon.png, leaderboard_icon.png, background.jpg, animation.png

## HUD (from Flutter)

- **ScoreView:** "score:" (lowercase) + displayScore + RoundCountDisplay
- **RoundCountDisplay:** "Rounds:" (l10n.rounds) + 3 RoundIndicator (yellow squares, active if rounds >= 1,2,3)
- **GameHud:** Uses mini_score_background, white border, shows score and rounds; bonus animation on bonus

## Camera (Flutter)

- **waiting:** zoom = size.y/175, position (0, -112)
- **playing:** zoom = size.y/160, position (0, -7.8)
- **gameOver:** zoom = size.y/100, position (0, -111)
