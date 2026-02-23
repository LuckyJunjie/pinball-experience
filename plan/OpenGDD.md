# Pinball Experience – Open Game Design Document (OpenGDD)

**Document ID:** 1_08  
**Purpose:** AI/Agent-friendly implementation guide with detailed UI/UX specs, asset-to-component mapping, and asset usage tracking. Use this document when implementing the game in Godot 4.x.

**References:** [Requirements](../requirements/Requirements.md) | [Technical-Design](../design/Technical-Design.md) | [UI-Design](../design/details/UI-Design.md) | [Component-Specifications](../design/details/Component-Specifications.md) | [Asset-Requirements](../design/details/Asset-Requirements.md)

---

## Part A: Critique of Current UI Design

The provided UI design is functional but overly simplistic for a modern pinball game with extended features like a store, level mode, and score range board. Key issues:

- **Lack of Visual Flair**: The design is minimalistic (flat colors, no textures, gradients, or shadows). It does not convey the playful, energetic theme inspired by I/O Pinball.
- **Missing Core Screens**: The current UI only covers the in-game HUD. It omits:
  - Main menu (Play, Levels, Store)
  - Character selection
  - How to Play screen
  - Store interface
  - Level selection (world map or list)
  - Score range board (brackets and rewards)
  - Backbox/leaderboard (initials entry, top 10, game over info, share)
- **In-Game HUD Limitations**:
  - Instructions are static and take up valuable screen space.
  - No display of multiplier, rounds left, or bonus indicators.
  - Ball queue visual is unclear and not tied to game state.
- **Poor Adaptability**: Fixed positioning and lack of responsive design will cause issues on different screen sizes, especially mobile.
- **No Feedback or Animation**: The design lacks visual feedback for scoring, bonuses, or game state changes, reducing player engagement.

---

## Part B: Proposed Enhanced UI/UX Design

### Design Principles

1. **Immersive & Thematic**: Use vibrant colors, gradients, and subtle animations to reflect the four character themes (Sparky, Dino, Dash, Android).
2. **Clarity & Readability**: Information is organized hierarchically; critical data (score, multiplier, rounds) is prominent; secondary info is accessible but unobtrusive.
3. **Consistent Navigation**: Clear transitions between screens, with back buttons and consistent styling.
4. **Mobile-Friendly**: Touch targets are large enough; UI scales using anchors and Control nodes.
5. **Feedback-Rich**: Animated score popups, flashing indicators, and smooth transitions keep the player engaged.

---

## Part C: Screen-by-Screen Specification

### 1. Main Menu (Splash)

**Layout**:
- Full-screen CanvasLayer with a dynamic background (character-themed art cycle or looping video).
- Centered vertical stack of large buttons: **Play** (Classic), **Levels**, **Store**, **Settings** (optional).
- Bottom row: **Score Range Board** button (icon + text) and **Leaderboard** button.

**Visuals**: Buttons with rounded corners, gradient fills, hover animations (scale up, glow). Each button has an icon (Play = pinball, Levels = map, Store = bag/coins).

**Transitions**: Fade in on load; button press triggers slide or fade to next screen.

**Behavior**: Play → Character Select; Levels → Level Select; Store → Store scene; Score Range Board → overlay; Leaderboard → Backbox leaderboard state.

---

### 2. Character Selection

**Layout**:
- Title: "Choose Your Character".
- Grid of four cards (Sparky, Dino, Dash, Android), each with: large character art, theme name, brief tagline, Select button.
- Back button to Main Menu.

**Visuals**: Each card uses character color palette; glowing border on hover; selected card pulses before transition.

**Behavior**: On selection, store theme in GameManager; transition to How to Play.

---

### 3. How to Play

**Layout**:
- Split screen: left = simplified playfield diagram with numbered zones; right = instructions (objective, scoring, controls, special moves).
- "Got it!" button at bottom.

**Visuals**: Diagram animates to highlight each zone; icons for keys and touch gestures.

**Behavior**: Dismiss → start game (load playfield, status = playing).

---

### 4. In-Game HUD (Playing State)

**Layout**:
- **Top Bar**: Left = Score (large, digit roll-up); Center = Multiplier badge (x1–x6); Right = Rounds left (3 ball icons); Right = Multiball indicators (4 lights).
- **Bottom Bar**: Left = Bonus history (small icons); Right = Launcher charge meter (only when ball in launcher).
- **Floating Score Popups**: "+5000" at hit location, fades and moves up (~0.5 s).

**Visuals**: Score = digital font with glow; multiplier badge color changes (yellow → orange → red); ball icons = themed ball sprites; HUD background = dark translucent.

**Animations**: Score counting-up; multiplier pulse; bonus icons slide in; score popup tween up and fade.

---

### 5. Backbox (Leaderboard & Game Over)

**Layout** (slides down from top when needed):
- **Leaderboard**: Title "Top 10"; scrollable list (Rank, Initials, Score, Character icon); Close, Share.
- **Initials Entry**: Final score, character icon; 3 input fields; Submit.
- **Game Over Info**: Final score, "New High Score!" badge; Replay, Store, Main Menu, Share.

**Visuals**: LCD/arcade look (scanlines, pixel font); retro arcade buttons.

---

### 6. Store UI

**Layout**: Top = Coin balance; Tabs = Balls, Flippers, Plunger, Bumpers, Power-ups; Grid of items (icon, name, description, price, Buy/Equip); Back button.

**Visuals**: Card-style items; purchased = checkmark; coin balance updates on purchase.

---

### 7. Level Select

**Layout**: World map or level list; level nodes (number, difficulty stars, lock icon); tap level → popup (name, objective, reward, Play); Back.

**Visuals**: Unlocked = glowing; locked = grayed out.

---

### 8. Score Range Board

**Layout**: Overlay with vertical list of brackets (0–100k, 100k–500k, …); progress bar; reward text. Highlight current and next bracket.

**Visuals**: Reached = green; current = blue; future = gray.

---

## Part D: Asset-to-Component Mapping

Each Godot node/component maps to specific assets. Use this table when implementing scenes.

### D.1 Playfield and Boundaries

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Playfield background | `assets/sprites/board_background.png` | Main playfield texture |
| Boundaries (outer) | `assets/sprites/boundary/outer.png` | Wall collision/visual |
| Boundaries (outer bottom) | `assets/sprites/boundary/outer_bottom.png` | Bottom wall |
| Boundaries (bottom) | `assets/sprites/boundary/bottom.png` | Drain area boundary |
| Wall (generic) | `assets/sprites/wall.png` | Fallback wall tile |

### D.2 Launcher

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| LaunchRamp | `assets/sprites/launch_ramp/ramp.png` | Ramp visual |
| LaunchRamp foreground | `assets/sprites/launch_ramp/foreground_railing.png` | Railing overlay |
| LaunchRamp background | `assets/sprites/launch_ramp/background_railing.png` | Railing behind |
| Flapper | `assets/sprites/flapper/flap.png` | Flapper visual |
| Flapper front support | `assets/sprites/flapper/front_support.png` | Support |
| Flapper back support | `assets/sprites/flapper/back_support.png` | Support |
| Plunger | `assets/sprites/plunger/plunger.png` | Plunger body |
| RocketSprite | `assets/sprites/plunger/rocket.png` | Rocket/ball launcher visual |

### D.3 Bottom Group (Flippers, Baseboard, Kickers)

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| FlipperLeft | `assets/sprites/flipper/left.png` | Left flipper |
| FlipperRight | `assets/sprites/flipper/right.png` | Right flipper |
| BaseboardLeft | `assets/sprites/baseboard/left.png` | Left baseboard |
| BaseboardRight | `assets/sprites/baseboard/right.png` | Right baseboard |
| KickerLeft (dimmed) | `assets/sprites/kicker/left/dimmed.png` | Inactive |
| KickerLeft (lit) | `assets/sprites/kicker/left/lit.png` | Active |
| KickerRight (dimmed) | `assets/sprites/kicker/right/dimmed.png` | Inactive |
| KickerRight (lit) | `assets/sprites/kicker/right/lit.png` | Active |

### D.4 Ball (per theme)

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Ball (Sparky) | `assets/sprites/sparky/ball.png` | Sparky theme |
| Ball (Dino) | `assets/sprites/dino/ball.png` | Dino theme |
| Ball (Dash) | `assets/sprites/dash/ball.png` | Dash theme |
| Ball (Android) | `assets/sprites/android/ball.png` | Android theme |
| Ball trail (optional) | `assets/sprites/ball/flame_effect.png` | Optional polish |

### D.5 Google Gallery

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| GoogleWord letter 1 (G) | `assets/sprites/google_word/letter1/dimmed.png`, `lit.png` | G |
| GoogleWord letter 2 (o) | `assets/sprites/google_word/letter2/dimmed.png`, `lit.png` | o |
| GoogleWord letter 3 (o) | `assets/sprites/google_word/letter3/dimmed.png`, `lit.png` | o |
| GoogleWord letter 4 (g) | `assets/sprites/google_word/letter4/dimmed.png`, `lit.png` | g |
| GoogleWord letter 5 (l) | `assets/sprites/google_word/letter5/dimmed.png`, `lit.png` | l |
| GoogleWord letter 6 (e) | `assets/sprites/google_word/letter6/dimmed.png`, `lit.png` | e |
| GoogleRolloverLeft | `assets/sprites/google_rollover/left/decal.png`, `pin.png` | 5k |
| GoogleRolloverRight | `assets/sprites/google_rollover/right/decal.png`, `pin.png` | 5k |

### D.6 Multipliers and Multiballs

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| MultiplierX2 | `assets/sprites/multiplier/x2/dimmed.png`, `lit.png` | x2 indicator |
| MultiplierX3 | `assets/sprites/multiplier/x3/dimmed.png`, `lit.png` | x3 |
| MultiplierX4 | `assets/sprites/multiplier/x4/dimmed.png`, `lit.png` | x4 |
| MultiplierX5 | `assets/sprites/multiplier/x5/dimmed.png`, `lit.png` | x5 |
| MultiplierX6 | `assets/sprites/multiplier/x6/dimmed.png`, `lit.png` | x6 |
| MultiballA/B/C/D | `assets/sprites/multiball/dimmed.png`, `lit.png` | 4 indicators (same sprite) |

### D.7 Skill Shot

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| SkillShot | `assets/sprites/skill_shot/decal.png` | Decal |
| SkillShot (dimmed) | `assets/sprites/skill_shot/dimmed.png` | Inactive |
| SkillShot (lit) | `assets/sprites/skill_shot/lit.png` | Active (1M) |
| SkillShot pin | `assets/sprites/skill_shot/pin.png` | Pin visual |

### D.8 Android Acres

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| SpaceshipRamp | `assets/sprites/android/ramp/main.png` | Ramp |
| SpaceshipRamp railing | `assets/sprites/android/ramp/railing_foreground.png`, `railing_background.png` | Railings |
| SpaceshipRamp board opening | `assets/sprites/android/ramp/board_opening.png` | Opening |
| SpaceshipRamp arrows | `assets/sprites/android/ramp/arrow/active1..5.png`, `inactive.png` | Progress arrows |
| SpaceshipRail | `assets/sprites/android/rail/main.png`, `exit.png` | Rail path |
| AndroidBumperA | `assets/sprites/android/bumper/a/dimmed.png`, `lit.png` | 20k |
| AndroidBumperB | `assets/sprites/android/bumper/b/dimmed.png`, `lit.png` | 20k |
| AndroidBumperCow | `assets/sprites/android/bumper/cow/dimmed.png`, `lit.png` | 20k |
| AndroidSpaceship (saucer) | `assets/sprites/android/spaceship/saucer.png` | Target |
| AndroidSpaceship (animatronic) | `assets/sprites/android/spaceship/animatronic.png` | Character |
| AndroidSpaceship (light beam) | `assets/sprites/android/spaceship/light_beam.png` | Effect |

### D.9 Dino Desert

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| ChromeDino (head) | `assets/sprites/dino/animatronic/head.png` | Dino head |
| ChromeDino (mouth) | `assets/sprites/dino/animatronic/mouth.png` | Mouth sensor area |
| DinoWalls (top) | `assets/sprites/dino/top_wall.png` | Top wall |
| DinoWalls (bottom) | `assets/sprites/dino/bottom_wall.png` | Bottom wall |
| DinoWalls (tunnel) | `assets/sprites/dino/top_wall_tunnel.png` | Tunnel |
| SlingshotLeft/Right | `assets/sprites/slingshot/upper.png`, `lower.png` | Slingshots |

### D.10 Flutter Forest (Dash)

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Signpost | `assets/sprites/signpost/inactive.png`, `active1.png`, `active2.png`, `active3.png` | 5k; animation frames |
| DashBumperMain | `assets/sprites/dash/bumper/main/inactive.png`, `active.png` | 200k |
| DashBumperA | `assets/sprites/dash/bumper/a/inactive.png`, `active.png` | 20k |
| DashBumperB | `assets/sprites/dash/bumper/b/inactive.png`, `active.png` | 20k |
| DashAnimatronic | `assets/sprites/dash/animatronic.png` | Character |

### D.11 Sparky Scorch

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| SparkyBumperA | `assets/sprites/sparky/bumper/a/dimmed.png`, `lit.png` | 20k |
| SparkyBumperB | `assets/sprites/sparky/bumper/b/dimmed.png`, `lit.png` | 20k |
| SparkyBumperC | `assets/sprites/sparky/bumper/c/dimmed.png`, `lit.png` | 20k |
| SparkyComputer (base) | `assets/sprites/sparky/computer/base.png` | Base |
| SparkyComputer (top) | `assets/sprites/sparky/computer/top.png` | Top |
| SparkyComputer (glow) | `assets/sprites/sparky/computer/glow.png` | Glow effect |
| SparkyAnimatronic | `assets/sprites/sparky/animatronic.png` | Character |

### D.12 Backbox

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Backbox marquee | `assets/sprites/backbox/marquee.png` | Top marquee |
| Display divider | `assets/sprites/backbox/display_divider.png` | Divider |
| Display title decoration | `assets/sprites/backbox/display_title_decoration.png` | Title bar |
| Share button (Facebook) | `assets/sprites/backbox/button/facebook.png` | Share |
| Share button (Twitter) | `assets/sprites/backbox/button/twitter.png` | Share |

### D.13 Character Selection and UI

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Character Select background | `assets/sprites/select_character_background.png` | Background |
| Sparky icon | `assets/sprites/sparky/icon.png` | Card/theme |
| Dino icon | `assets/sprites/dino/icon.png` | Card/theme |
| Dash icon | `assets/sprites/dash/icon.png` | Card/theme |
| Android icon | `assets/sprites/android/icon.png` | Card/theme |
| Sparky leaderboard icon | `assets/sprites/sparky/leaderboard_icon.png` | Leaderboard entry |
| Dino leaderboard icon | `assets/sprites/dino/leaderboard_icon.png` | Leaderboard entry |
| Dash leaderboard icon | `assets/sprites/dash/leaderboard_icon.png` | Leaderboard entry |
| Android leaderboard icon | `assets/sprites/android/leaderboard_icon.png` | Leaderboard entry |
| Play/Replay button | `assets/sprites/pinball_button.png` | Generic button |
| Error/Loading background | `assets/sprites/error_background.png` | Loading/failure |
| Display arrows | `assets/sprites/display_arrows/arrow_left.png`, `arrow_right.png` | UI arrows |

### D.14 Score Popups (HUD)

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Score background | `assets/sprites/score/mini_score_background.png` | HUD score bg |
| Score popup 5k | `assets/sprites/score/five_thousand.png` | Floating popup |
| Score popup 20k | `assets/sprites/score/twenty_thousand.png` | Floating popup |
| Score popup 200k | `assets/sprites/score/two_hundred_thousand.png` | Floating popup |
| Score popup 1M | `assets/sprites/score/one_million.png` | Floating popup |

### D.15 Character Theme Backgrounds (optional)

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Sparky background | `assets/sprites/sparky/background.jpg` | Theme bg |
| Dino background | `assets/sprites/dino/background.jpg` | Theme bg |
| Dash background | `assets/sprites/dash/background.jpg` | Theme bg |
| Android background | `assets/sprites/android/background.jpg` | Theme bg |

### D.16 Character Animations (optional)

| Node / Component | Asset Path | Notes |
|------------------|------------|-------|
| Sparky animation | `assets/sprites/sparky/animation.png` | Sprite sheet |
| Dino animation | `assets/sprites/dino/animation.png` | Sprite sheet |
| Dash animation | `assets/sprites/dash/animation.png` | Sprite sheet |
| Android animation | `assets/sprites/android/animation.png` | Sprite sheet |

---

## Part E: Audio Asset Mapping

| Event / Component | Asset Path | Notes |
|-------------------|------------|-------|
| Ball launch | `assets/sounds/ball_launch.wav` | Plunger/launch |
| Ball lost (drain) | `assets/sounds/ball_lost.wav` | Drain |
| Flipper click | `assets/sounds/flipper_click.wav` | Flipper |
| Hold/rollover entry | `assets/sounds/hold_entry.wav` | Skill shot, rollovers |
| Obstacle hit | `assets/sounds/obstacle_hit.wav` | Bumper, kicker (if exists) |

**Missing (create or add):** `bumper.wav`, `kicker.wav`, `rollover.wav`, `bonus.wav`, `multiplier_up.wav`

---

## Part F: Asset Usage List

### F.1 Used Assets (mapped to components)

| Asset | Used By | Status |
|-------|---------|--------|
| `board_background.png` | Playfield | ✅ Mapped |
| `boundary/*.png` | Boundaries | ✅ Mapped |
| `launch_ramp/*.png` | LaunchRamp | ✅ Mapped |
| `flapper/*.png` | Flapper | ✅ Mapped |
| `plunger/*.png` | Plunger, RocketSprite | ✅ Mapped |
| `flipper/*.png` | FlipperLeft, FlipperRight | ✅ Mapped |
| `baseboard/*.png` | BaseboardLeft, BaseboardRight | ✅ Mapped |
| `kicker/*/*.png` | KickerLeft, KickerRight | ✅ Mapped |
| `sparky/ball.png`, `dino/ball.png`, `dash/ball.png`, `android/ball.png` | Ball (per theme) | ✅ Mapped |
| `google_word/letter*/*.png` | GoogleWord | ✅ Mapped |
| `google_rollover/*/*.png` | GoogleRolloverLeft, GoogleRolloverRight | ✅ Mapped |
| `multiplier/x*/*.png` | Multipliers x2–x6 | ✅ Mapped |
| `multiball/*.png` | Multiball indicators | ✅ Mapped |
| `skill_shot/*.png` | SkillShot | ✅ Mapped |
| `android/ramp/*.png`, `android/rail/*.png` | SpaceshipRamp, SpaceshipRail | ✅ Mapped |
| `android/bumper/*/*.png` | AndroidBumperA, B, Cow | ✅ Mapped |
| `android/spaceship/*.png` | AndroidSpaceship | ✅ Mapped |
| `dino/animatronic/*.png`, `dino/*_wall*.png` | ChromeDino, DinoWalls | ✅ Mapped |
| `slingshot/*.png` | SlingshotLeft, SlingshotRight | ✅ Mapped |
| `signpost/*.png` | Signpost | ✅ Mapped |
| `dash/bumper/*/*.png`, `dash/animatronic.png` | Dash bumpers, DashAnimatronic | ✅ Mapped |
| `sparky/bumper/*/*.png`, `sparky/computer/*.png`, `sparky/animatronic.png` | Sparky bumpers, SparkyComputer, SparkyAnimatronic | ✅ Mapped |
| `backbox/*.png` | Backbox | ✅ Mapped |
| `score/*.png` | HUD, score popups | ✅ Mapped |
| `*/icon.png`, `*/leaderboard_icon.png` | CharacterSelect, Leaderboard | ✅ Mapped |
| `select_character_background.png` | CharacterSelect | ✅ Mapped |
| `pinball_button.png` | Play/Replay | ✅ Mapped |
| `error_background.png` | Loading/failure | ✅ Mapped |
| `display_arrows/*.png` | UI arrows | ✅ Mapped |
| `wall.png` | Generic wall (fallback) | ✅ Mapped |

### F.2 Unused or Optional Assets

| Asset | Suggested Use | Status |
|-------|---------------|--------|
| `ball/flame_effect.png` | Ball trail (optional polish) | ⚪ Optional |
| `sparky/background.jpg` | Character theme background | ⚪ Optional |
| `dino/background.jpg` | Character theme background | ⚪ Optional |
| `dash/background.jpg` | Character theme background | ⚪ Optional |
| `android/background.jpg` | Character theme background | ⚪ Optional |
| `sparky/animation.png` | Character animation | ⚪ Optional |
| `dino/animation.png` | Character animation | ⚪ Optional |
| `dash/animation.png` | Character animation | ⚪ Optional |
| `android/animation.png` | Character animation | ⚪ Optional |

### F.3 Missing Assets (to create or source)

| Asset | Used By | Priority |
|-------|---------|----------|
| Main menu background | MainMenu | High |
| Store coin icon | Store UI | High |
| Store item icons | Store UI (Balls, Flippers, etc.) | High |
| Level map/list background | LevelSelect | High |
| Level lock icon | LevelSelect | High |
| Score Range Board bracket graphics | Score Range Board | Medium |
| How to Play diagram | How to Play | Medium |
| `bumper.wav`, `kicker.wav`, `rollover.wav` | Audio | Medium |
| `bonus.wav`, `multiplier_up.wav` | Audio | Medium |

---

## Part G: Godot Node Structure (Implementation)

### G.1 Main Menu

```
MainMenu (Control) - full rect
├── Background (TextureRect) - full screen; use placeholder or theme background
├── VBoxContainer (center)
│   ├── Button (Play) - icon: pinball
│   ├── Button (Levels) - icon: map
│   ├── Button (Store) - icon: bag/coins
│   └── Button (Settings)
├── HBoxContainer (bottom)
│   ├── Button (ScoreRangeBoard)
│   └── Button (Leaderboard)
└── AnimationPlayer (transitions)
```

### G.2 In-Game HUD

```
HUD (CanvasLayer)
├── TopBar (MarginContainer) - anchors top
│   ├── ScoreLabel (Label) - font: Roboto Bold; texture: score/mini_score_background.png
│   ├── MultiplierBadge (PanelContainer + Label) - x1–x6
│   ├── RoundsContainer (HBoxContainer of TextureRect) - ball icons from theme
│   └── MultiballIndicators (HBoxContainer) - 4x multiball/dimmed.png or lit.png
├── BottomBar (MarginContainer) - anchors bottom
│   ├── BonusHistory (HBoxContainer of TextureRect) - bonus animation icons
│   └── ChargeMeter (ProgressBar) - visible only when ball in launcher
└── PopupManager (Node) - spawns Labels with score/five_thousand.png etc. at hit positions
```

### G.3 Backbox

```
Backbox (CanvasLayer or Control)
├── Marquee (TextureRect) - backbox/marquee.png
├── Display (Control) - swapped per state
│   ├── LeaderboardDisplay
│   ├── InitialsInputDisplay
│   ├── GameOverInfoDisplay
│   └── ShareDisplay
└── DisplayDivider (TextureRect) - backbox/display_divider.png
```

---

## Part H: Implementation Checklist

- [ ] Create MainMenu scene with animated background and buttons.
- [ ] Create CharacterSelect scene with four theme cards (use `*/icon.png`, `select_character_background.png`).
- [ ] Create HowToPlay scene with diagram and instructions.
- [ ] Implement HUD with TopBar (score, multiplier, rounds, multiball), BottomBar (bonus history, charge meter), PopupManager (score popups).
- [ ] Implement Backbox (Leaderboard, Initials, GameOver, Share) using `backbox/*.png`.
- [ ] Build Store UI with tabs and coin balance.
- [ ] Build LevelSelect with map and level nodes.
- [ ] Build ScoreRangeBoard overlay.
- [ ] Map all playfield components per Part D (Launcher, Drain, Zones, etc.).
- [ ] Connect UI to game state via signals (GameManager, BackboxManager, StoreManager, LevelManager, PlayerAssets).
- [ ] Add animations and sound effects; wire audio per Part E.
- [ ] Verify asset usage: all "Used" assets in F.1 are referenced in scenes; "Unused" in F.2 are optional; "Missing" in F.3 are created or sourced.

---

## Part I: Quick Reference – Asset Paths by Category

| Category | Base Path | Key Files |
|----------|-----------|-----------|
| Playfield | `assets/sprites/` | `board_background.png`, `boundary/*.png`, `wall.png` |
| Launcher | `assets/sprites/launch_ramp/`, `plunger/`, `flapper/` | `ramp.png`, `plunger.png`, `rocket.png`, `flap.png` |
| Bottom | `assets/sprites/flipper/`, `baseboard/`, `kicker/` | `left.png`, `right.png`, `left.png`, `right.png` |
| Balls | `assets/sprites/{sparky,dino,dash,android}/ball.png` | 4 theme balls |
| Google | `assets/sprites/google_word/`, `google_rollover/` | letter1..6, left/right |
| Multiplier/Multiball | `assets/sprites/multiplier/`, `multiball/` | x2..x6, dimmed/lit |
| Skill Shot | `assets/sprites/skill_shot/` | decal, dimmed, lit, pin |
| Android | `assets/sprites/android/` | ramp/, rail/, bumper/, spaceship/ |
| Dino | `assets/sprites/dino/` | animatronic/, top_wall, bottom_wall, slingshot |
| Dash | `assets/sprites/dash/` | bumper/, animatronic |
| Sparky | `assets/sprites/sparky/` | bumper/, computer/, animatronic |
| Backbox | `assets/sprites/backbox/` | marquee, display_divider, button/ |
| Score | `assets/sprites/score/` | mini_score_background, five_thousand, etc. |
| UI | `assets/sprites/` | pinball_button, select_character_background, error_background, display_arrows/ |
| Icons | `assets/sprites/{theme}/` | icon.png, leaderboard_icon.png |
| Audio | `assets/sounds/` | ball_launch, ball_lost, flipper_click, hold_entry, obstacle_hit |

---

*This OpenGDD is intended for AI/Agent-driven implementation. Update the Asset Usage List (Part F) as assets are integrated or new assets are added.*
