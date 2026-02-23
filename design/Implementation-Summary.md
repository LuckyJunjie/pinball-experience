# Pinball – Implementation Summary

**Document ID:** 3_05

## How to Run

- **Baseline (0.1–0.5):** Main scene is `res://scenes/Main.tscn`. Run the project; game starts immediately.
- **Target flow:** Main menu (Splash) with Play, Levels, Store → Character Select → How to Play → playfield. After game over: Replay restarts the game.

---

## Implemented – Baseline 0.1–0.5

### State and flow (BASELINE 0.5)

- **GameManager** (autoload): round_score, total_score, multiplier (1–6), rounds (3), bonus_history, status (waiting, playing, gameOver). Signals: scored, round_lost, bonus_activated, multiplier_increased, game_over, game_started, ball_spawn_requested. add_score(), on_round_lost(), increase_multiplier(), add_bonus(), start_game(), spawn_ball_at_launcher().
- **Start flow**: Main.tscn loads → Main._ready() calls GameManager.start_game() → ball spawns at launcher.
- **Game over**: When rounds == 0, GameManager emits game_over; UI shows GameOverPanel (final score, Replay). Replay → reload scene → start_game().

### Playfield and physics (BASELINE 0.1–0.5)

- **Main.tscn**: Playfield (background, boundaries), Drain (Area2D), Balls node, Launcher, FlipperLeft, FlipperRight, Obstacles (3), UI.
- **Drain.gd**: body_entered(Ball) → remove ball; GameManager.on_ball_removed() → on_round_lost() when no balls remain.
- **Ball**: Spawned at launcher by Launcher (on ball_spawn_requested). Space/Down to launch.
- **Flipper.gd**: Left/Right arrow or A/D; kinematic rotation.
- **Obstacle.gd**: Area2D + StaticBody2D (bounce); configurable points (export var); add_score() on body_entered.
- **Walls**: StaticBody2D (left, right, top); bottom gap for drain.

### UI and audio

- **UI.gd**: HUD (score, multiplier, rounds); GameOverPanel (final score, Replay). Connects to GameManager signals.
- **SoundManager** (autoload): ball_launch, ball_lost, flipper_click, obstacle_hit.

### Target (per requirements v2.0)

- **Store**: Main menu and post-game; coins, upgradable items (balls, flippers, plunger, bumpers, multiplier boost, extra ball); persistence.
- **Score Range Board**: Main menu or overlay; score brackets and rewards; progress toward next bracket; rewards applied to player assets.
- **Level Mode**: Level Select → level playfields with custom layouts and objectives; same physics and player assets as Classic; level progress and rewards persisted.
- **Player assets**: Coins and upgrades persisted (e.g. SaveManager/PlayerAssets) and shared across Classic and Level modes.

---

## Document Index

| Path | Purpose |
|------|---------|
| requirements/Requirements.md | Requirements |
| design/GDD.md | Game Design Document |
| design/Technical-Design.md | Technical design |
| design/Game-Flow.md | State and flow |
| design/details/Component-Specifications.md | Component specs |
| design/details/Asset-Requirements.md | Asset list |
| design/Implementation-Summary.md | This file |

---

## Testing Checklist

1. Run MainMenu → Play → pick character → How to Play → Start Game → Main loads, one ball spawns at launcher.
2. Space to launch; Left/A and Right/D for flippers. Ball drains → round lost; after 3 rounds, game over panel with Replay.
3. Hit SkillShot area (center, y≈200) for 1M points; score and multiplier/rounds update.
4. Back to Menu from game; Replay after game over returns to character select.
