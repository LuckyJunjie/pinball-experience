# Refactor for Flutter I/O Pinball Parity

**Document ID:** 4_07

## Completed (this refactor)

### 1. Flutter assets reused
- **Source:** `/Users/junjiepan/github/pinball` (pinball_components, pinball_theme, main assets)
- **Destination:** `assets/sprites/` (or project asset folder)
- **Contents:** board_background.png, backbox/marquee.png, android/, dash/, dino/, sparky/, google_word/, multiplier/, multiball/, skill_shot/, plunger/, launch_ramp/, flipper/, kicker/, score/, boundary/, baseboard/, etc.
- **Usage:** Main uses `board_background.png` for playfield and `backbox/marquee.png` for backbox marquee at top.

### 2. Backbox UI (Flutter-style)
- **Score:** "score:" (lowercase) + score value, matching Flutter ScoreView.
- **Ball Ct:** "Ball Ct:" + 3 round indicators (yellow squares when round available, dim when lost), matching RoundCountDisplay (3 rounds).
- **Marquee:** TextureRect at top using Flutter marquee image.
- **Bottom banner:** "I/O PINBALL" and "FREE PLAY | 3 Balls Per Game" at bottom center.

### 3. Playfield layout (Flutter → Godot adaptations)
- **CoordinateConverter:** Central utility for Flutter Forge2D → Godot pixel conversion.
- **Transform:** Flutter (x, y) → Godot (400 + x×5, 300 + y×5). See [FLUTTER-LAYOUT-AND-ASSETS.md](FLUTTER-LAYOUT-AND-ASSETS.md).
- **Flippers:** Left (340, 518), Right (424, 518) from Flutter (-12.05, 43.6), (4.8, 43.6).
- **Launcher:** Godot uses center launcher (400, 518); Flutter has right-side (605, 518.5).
- **Camera:** Godot 4.5.1 uses fixed center (400, 300), visible height 650 – Flutter zoom/pos formulas were for different viewport.
- **Board background:** Flutter board_background.png, scaled 0.5, centered at (400, 300).

### 4. Game mechanics (already aligned with Flutter)
- **GameManager:** round_score, total_score, multiplier (1–6), rounds (3), bonus_history, status (waiting, playing, gameOver). Round lost: totalScore += roundScore×multiplier; multiplier reset to 1; rounds decrement.
- **Scoring:** 5k, 20k, 200k, 1M (skill shot 1M; bumpers 20k/200k).
- **Drain:** Ball removal and RoundLost when no balls left.
- **Start flow:** Play → Character select (4 themes) → How to play → Game.

### 5. BackboxBloc parity (this session)
- **BackboxManager** (autoload): States LeaderboardSuccess, LeaderboardFailure, Loading, InitialsForm, InitialsSuccess, InitialsFailure, Share. Mock leaderboard (no Firebase). `request_initials(score, character_key)`, `submit_initials(initials)`, `request_share(score)`, `go_to_leaderboard()`.
- **Backbox views:** BackboxContent in Main UI: LeaderboardPanel (top 10 list), InitialsPanel (3-letter OptionButtons + Submit), GameOverInfoPanel (after submit). Game Over panel (Replay) shows only after initials submitted (Flutter flow).
- **Character:** MainMenu sets `BackboxManager.selected_character_key` on character select; game over passes it to `request_initials`.

### 6. Camera focusing (Godot 4.5.1 adapted)
- **Main._apply_camera_status():** Fixed center (400, 300), visible height 650. Flutter formulas (zoom/pos per status) produced off-screen views; Godot uses single centered view so flippers, launcher, ramp, zones are all visible.

### 7. Score view parity (this session)
- **UI:** When game over, score area shows "Game Over" (Flutter ScoreView); Ball Ct column hidden. Multiplier label visible during play, shows "Multiplier: Nx".

### 8. Ramp multiplier (this session)
- **Ramp.gd:** Area2D on Playfield; body_entered (ball) → add_score(5000), hit_count++; every 5 hits → GameManager.increase_multiplier(). Ramp node in Main.tscn.

## Remaining for full parity

- **Zones with Flutter art and behavior:** Google Gallery (GOOGLE letters, rollovers), Android Acres (full ramp visual, bumpers, spaceship), Dino Desert (Chrome Dino, slingshots), Flutter Forest (Dash bumpers, signpost), Sparky Scorch (bumpers, computer). Use assets under `assets/sprites/` and [Component-Specifications.md](../details/Component-Specifications.md).
- **Bonuses:** googleWord, dashNest, sparkyTurboCharge, dinoChomp, androidSpaceship (bonus ball 5s after Google Word or Dash Nest already in GameManager).
- **Share display:** Backbox ShareState view (copy/share message); optional.
- **Character theme:** Apply selected theme to ball sprite and leaderboard icon.

## Reference

- Flutter layout and coordinates: [FLUTTER-LAYOUT-AND-ASSETS.md](FLUTTER-LAYOUT-AND-ASSETS.md)
- Flutter parsing: [FLUTTER-PINBALL-PARSING.md](FLUTTER-PINBALL-PARSING.md)
- Component specs: [Component-Specifications.md](../details/Component-Specifications.md)
