# Pinball Game – Technical Design Document

**Document ID:** 3_03

## 1. Architecture Overview

### 1.1 Purpose

Replicates the Flutter I/O Pinball game in Godot 4.5.1 and extends it with **Store**, **Level Mode**, and **Score Range Board** per [Requirements](../requirements/Requirements.md). The architecture maps Flutter components (GameBloc, StartGameBloc, BackboxBloc) to Godot scenes and scripts; adds **PlayerAssets** (coins, upgrades) persisted and shared across Classic and Level modes. Leaderboard and share use local or optional backend.

### 1.2 Layers

```
┌─────────────────────────────────────────┐
│      Presentation Layer                 │
│  (MainMenu: Play / Levels / Store,       │
│   Store UI, Level Select, Score Range    │
│   Board, Backbox, HUD, Character select, │
│   How to Play)                          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Gameplay Layer                     │
│  (Playfield, Zones, Ball, Flippers,     │
│   Launcher, Drain, Scoring, Bonuses;     │
│   level-specific layouts in Level mode)  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      State Layer                        │
│  (GameManager, StartFlow, BackboxManager,│
│   StoreManager, LevelManager, App state) │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Data Layer                         │
│  (PlayerAssets: coins, upgrades, level   │
│   progress; SaveManager for persistence; │
│   local leaderboard, initials, share)   │
└─────────────────────────────────────────┘
```

### 1.3 Mapping from Flutter

| Flutter | Godot |
|---------|-------|
| GameBloc | GameManager (autoload or root) – roundScore, totalScore, multiplier, rounds, bonusHistory, status |
| StartGameBloc | StartFlow state (e.g. in GameManager or dedicated node) – initial, selectCharacter, howToPlay, play |
| BackboxBloc | BackboxManager or Backbox scene script – leaderboard, initials, game over, share |
| PinballGame (Forge2D) | Main scene with Playfield, Camera2D |
| BallSpawningBehavior | GameManager + Launcher – spawn ball at plunger on round start / round lost |
| BonusBallSpawningBehavior | GameManager – timer 5s, spawn ball at DinoWalls with impulse |
| DrainingBehavior | Drain area – body_entered Ball → remove ball; if no balls → RoundLost |
| CameraFocusingBehavior | Camera2D script – zoom/position per status (waiting, playing, gameOver) |
| Zones (AndroidAcres, etc.) | Child nodes of Playfield with zone scripts and scoring/bonus logic |
| — | **StoreManager** – Store UI state, purchase flow; reads/writes PlayerAssets |
| — | **LevelManager** – LevelSelect, level data, objectives; level progress in PlayerAssets |
| — | **PlayerAssets / SaveManager** – coins, upgrades, level progress; **single writer** for persistence; Store and Level only read/write via it |

---

## 2. Scene Structure

### 2.1 Main / Game Root

**Scene**: e.g. `scenes/Main.tscn` or `scenes/PinballGame.tscn`

**Node structure** (conceptual). Every **visible** playfield item is listed under its parent so the hierarchy shows where each object lives. Items may be implemented as Node2D, Area2D, StaticBody2D, RigidBody2D, or visual-only (Sprite2D/AnimatedSprite2D) children; the structure is the logical placement for design and implementation.

```
Main (Node2D)
├── Camera2D                          # Camera behavior per status
├── Playfield (Node2D)                 # Board background, boundaries
│   ├── Boundaries (StaticBody2D)     # Walls, outer/bottom boundaries
│   │
│   ├── Backbox (CanvasLayer / Node2D) # Above board; marquee + display states. Can be CanvasLayer above playfield or child of Playfield in UI space; position per UI-Design.
│   │   └── Display                   # Swapped per state: Leaderboard, Initials, GameOver, Share, Loading
│   │
│   ├── GoogleGallery (Node2D)
│   │   ├── GoogleWord                # Letters G-o-o-g-l-e (lit state)
│   │   ├── GoogleRolloverLeft        # Area2D, 5k
│   │   └── GoogleRolloverRight       # Area2D, 5k
│   │
│   ├── Multipliers (Node2D)          # Visual indicators x2–x6 (ramp drives value)
│   │   ├── MultiplierX2
│   │   ├── MultiplierX3
│   │   ├── MultiplierX4
│   │   ├── MultiplierX5
│   │   └── MultiplierX6
│   │
│   ├── Multiballs (Node2D)           # 4 indicator lights (blink on bonus ball earned)
│   │   ├── MultiballA
│   │   ├── MultiballB
│   │   ├── MultiballC
│   │   └── MultiballD
│   │
│   ├── SkillShot (Area2D)             # Rollover/target, 1M points
│   │
│   ├── AndroidAcres (Node2D)          # Left zone
│   │   ├── SpaceshipRamp              # Area2D/body; 5k per shot, ramp bonus 1M, multiplier +1 every 5 hits
│   │   ├── SpaceshipRail              # Visual/collision rail
│   │   ├── AndroidBumperA             # 20k
│   │   ├── AndroidBumperB             # 20k
│   │   ├── AndroidBumperCow           # 20k
│   │   ├── AndroidSpaceship           # Target (alien ship); 200k + androidSpaceship bonus
│   │   └── AndroidAnimatronic         # Visual (saucer/animatronic)
│   │
│   ├── DinoDesert (Node2D)            # Near launcher
│   │   ├── ChromeDino                 # Sprite + mouth sensor (Area2D); 200k + dinoChomp bonus
│   │   ├── DinoWalls                  # Collision; also bonus ball spawn position
│   │   ├── SlingshotLeft
│   │   └── SlingshotRight
│   │
│   ├── FlutterForest (Node2D)         # Top right
│   │   ├── Signpost                   # 5k
│   │   ├── DashBumperMain             # 200k
│   │   ├── DashBumperA                # 20k
│   │   ├── DashBumperB                # 20k
│   │   └── DashAnimatronic            # Visual
│   │
│   ├── SparkyScorch (Node2D)          # Top left
│   │   ├── SparkyBumperA              # 20k
│   │   ├── SparkyBumperB              # 20k
│   │   ├── SparkyBumperC              # 20k
│   │   ├── SparkyComputer             # Target (Area2D); 200k + sparkyTurboCharge bonus
│   │   └── SparkyAnimatronic          # Visual
│   │
│   ├── Drain (Area2D)                 # Bottom edge; ball contact → remove ball, round_lost when no balls
│   │
│   ├── BottomGroup (Node2D)           # Left and right sides
│   │   ├── FlipperLeft                # RigidBody2D / kinematic
│   │   ├── FlipperRight
│   │   ├── BaseboardLeft              # Visual
│   │   ├── BaseboardRight
│   │   ├── KickerLeft                 # 5k
│   │   └── KickerRight                # 5k
│   │
│   └── Launcher (Node2D)               # Right side; ball spawn here at round start
│       ├── LaunchRamp                 # Ramp visual/collision
│       ├── Flapper                    # Mechanical flapper
│       ├── Plunger                    # Plunger body; launch action
│       └── RocketSprite               # Visual (rocket)
│
├── Balls (Node2D)                     # Container for Ball instances (spawned at Launcher or DinoWalls)
├── GameManager (Node)                 # Or autoload
├── UI (CanvasLayer)                   # HUD: score, multiplier, rounds
└── Overlays (CanvasLayer)             # Play button, Replay button, mobile controls
```

**Visible-items index** (all UI/playfield objects and where they live):

| Item | Parent in structure |
|------|---------------------|
| Walls, boundaries | Playfield → Boundaries |
| Backbox, marquee, leaderboard, initials, game over, share | Playfield → Backbox |
| Google letters, Google rollovers L/R | Playfield → GoogleGallery |
| Multiplier lights x2–x6 | Playfield → Multipliers |
| Multiball indicators (4) | Playfield → Multiballs |
| Skill shot target | Playfield → SkillShot |
| Ramp, rail, Android bumpers A/B/COW, alien ship (AndroidSpaceship), Android animatronic | Playfield → AndroidAcres |
| Chrome Dino, Dino walls, slingshots | Playfield → DinoDesert |
| Signpost, Dash bumpers main/A/B, Dash animatronic | Playfield → FlutterForest |
| Sparky bumpers A/B/C, Sparky computer, Sparky animatronic | Playfield → SparkyScorch |
| Drain | Playfield → Drain |
| Flippers (L/R), baseboards, kickers (L/R) | Playfield → BottomGroup |
| Launch ramp, flapper, plunger, rocket sprite | Playfield → Launcher |
| Balls | Main → Balls |
| HUD (score, multiplier, rounds) | Main → UI |
| Play, Replay, mobile controls | Main → Overlays |

### 2.2 Main Menu and Flow Scenes

- **MainMenu (Splash)**: Buttons for **Play** (Classic), **Levels** (Level Mode), **Store**. Play → CharacterSelect; Levels → LevelSelect; Store → Store scene.
- **Store**: Shop UI; display items, coin balance; purchase upgrades (writes PlayerAssets); Back → Splash or Leaderboard.
- **LevelSelect**: World map or level list; select level → CharacterSelect (optional) or LevelPlaying; Back → Splash.
- **CharacterSelect**: Four themes (Sparky, Dino, Dash, Android); selection stores theme → HowToPlay.
- **HowToPlay**: Single screen; dismiss → start game (load Main/PinballGame for Classic or level-specific playfield for Level mode; set status = playing).
- **Score Range Board**: Accessible from main menu or overlay; score brackets and rewards; progress toward next bracket.

### 2.3 Backbox

- **Backbox** node: Holds current display (Leaderboard, InitialsForm, GameOverInfo, Share, Loading, Failure). Switch display via BackboxManager state; position above playfield (e.g. y = -87 in world or in UI space). Backbox can be a CanvasLayer above playfield or a child of Playfield in UI space; position per [UI-Design](details/UI-Design.md).

---

## 3. Script Architecture

### 3.1 GameManager (GameBloc equivalent)

**Implements:** FR-1.2.x, FR-1.5.x, TR-3.3, TR-3.4

**Script**: e.g. `scripts/GameManager.gd`

**State**: round_score, total_score, multiplier (1–6), rounds (3), bonus_history, status (waiting, playing, gameOver), character_theme.

**Signals** (payloads per requirements TR-3.4): scored(points, source), round_lost(final_round_score, multiplier), bonus_activated(bonus_type), multiplier_increased(new_value), game_over(final_score), game_started().

**Methods**: add_score(points), on_round_lost(), increase_multiplier(), add_bonus(bonus), start_game(), display_score().

### 3.2 StartFlow, BackboxManager, Zone Scripts

- StartFlow: initial | selectCharacter | howToPlay | play.
- BackboxManager: leaderboard/initials/share states; local persistence.
- Zone scripts: call GameManager.add_score(), add_bonus(), increase_multiplier(); ramp every 5 hits.

### 3.5 Ball Spawning

- Round start / round lost: GameManager spawns Ball at plunger; add to Balls container.
- Bonus ball: After 5s (Google Word or Dash Nest), spawn at DinoWalls with impulse.

### 3.6 Camera

- On GameManager status: waiting (top), playing (playfield), gameOver (top). Tween position and zoom.

---

## 4. Data Flow

Scoring: Zone → GameManager.add_score() → scored signal → UI. Round lost: Drain → no balls → GameManager.on_round_lost(). Bonus: Zone → add_bonus(); if googleWord/dashNest start 5s timer → spawn bonus ball. Multiplier: Ramp every 5 hits → increase_multiplier(). Game over: game_over → BackboxManager.request_initials → initials → share.

---

## 5. Signals Summary

| Signal | Payload | Source | Listeners |
|--------|---------|--------|-----------|
| scored | points, source | GameManager | UI, optional popup |
| round_lost | final_round_score, multiplier | GameManager | Camera, Ball spawn, UI, PlayerAssets (coins) |
| bonus_activated | bonus_type | GameManager | Multiball indicators, Bonus ball timer |
| multiplier_increased | new_value | GameManager | UI |
| game_over | final_score | GameManager | BackboxManager, Camera, Overlays, Score Range Board |
| game_started | — | GameManager | Camera, Ball spawn |
| flow_changed | — | StartFlow / App state | UI, Game load |
| state_changed | — | BackboxManager | Backbox |
| leaderboard_loaded | — | BackboxManager | Backbox |
| initials_submitted | — | BackboxManager | Backbox |
| share_requested | — | BackboxManager | Share flow |
| bracket_reached | score_bracket: String | GameManager / ScoreRangeBoardManager | Score Range Board notification (FR-6.3) |

---

## 6. File Layout (Suggested)

**Scripts**: GameManager.gd, StartFlowManager.gd (or AppStateManager), BackboxManager.gd, CameraBehavior.gd; **StoreManager.gd**, **LevelManager.gd**, **PlayerAssets.gd** (or SaveManager for coins/upgrades/level progress); zone scripts (AndroidAcres, DinoDesert, GoogleGallery, FlutterForest, SparkyScorch, SkillShot, Drain, Launcher); **ScoreRangeBoardManager.gd** (optional).

**Scenes**: Main.tscn (Classic playfield), MainMenu.tscn (Splash: Play / Levels / Store), **Store.tscn**, **LevelSelect.tscn**, **LevelPlay.tscn** (or Main with level data), Backbox.tscn; CharacterSelect, HowToPlay.

**Level data**: Level layouts and objectives live in `resources/levels/` (e.g. JSON or Godot `.tres` resources). Format defined per FR-7.8.

**PlayerAssets**: PlayerAssets (or SaveManager) is the **only writer** for coins, upgrades, level progress; Store and Level only read/write via it. Single save file: e.g. `user://player_assets.json`.

---

## 7. Reuse and Reference

- Reuse Ball.gd, Flipper.gd, Launcher.gd, SoundManager. See [details/Asset-Requirements.md](details/Asset-Requirements.md). Flutter: [flutter-reference/FLUTTER-PINBALL-PARSING.md](flutter-reference/FLUTTER-PINBALL-PARSING.md).
