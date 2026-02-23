# Pinball – Implementation Summary

**Document ID:** 3_05

## How to Run

Set the main scene to the main menu (Splash) scene:

- In Godot: Project → Project Settings → Application → Run → Main Scene → main menu scene (e.g. `res://scenes/MainMenu.tscn`)
- Or in `project.godot`: `run/main_scene="res://scenes/MainMenu.tscn"`

**Intended flow (per requirements):** Main menu offers **Play** (Classic), **Levels** (Level Mode), and **Store**. **Play** → Character Select → How to Play → Start Game → playfield. **Levels** → Level Select → (optional Character Select) → level playfield. **Store** → shop UI; return to menu or (from post-game) leaderboard. After game over: Leaderboard (initials, share), **Replay** → Character Select, optional **Store**.

---

## Implemented (Minimum Viable)

### State and flow

- **GameManager** (autoload): round_score, total_score, multiplier (1–6), rounds (3), bonus_history, status (waiting, playing, gameOver). Signals: scored, round_lost, bonus_activated, multiplier_increased, game_over, game_started. add_score(), on_round_lost(), increase_multiplier(), add_bonus(), start_game(), ball spawn at launcher, bonus ball timer (5s).
- **Start flow**: MainMenu – Play → selectCharacter (4 themes) → howToPlay → Main and start_game(). *(Target: main menu also offers Levels and Store.)*
- **Game over**: When rounds == 0, GameManager emits game_over; UI shows GameOverPanel (final score, Replay). Replay → Character Select. *(Target: optional Store from leaderboard.)*

### Playfield and physics

- **Main.tscn**: Playfield (background, walls with bottom gap), Drain (Area2D), SkillShot (Area2D 1M), Balls node, Launcher (reuse), Flippers (reuse), UI (score, multiplier, rounds, game over panel, back button), SoundManager.
- **Drain.gd**: body_entered(Ball) → remove ball; if was last ball, GameManager.on_round_lost().
- **Ball**: Spawned at launcher by GameManager (frozen until Launcher picks it up). Launcher uses existing input (Space / launch_ball). Flippers use flipper_left / flipper_right.
- **SkillShot.gd**: body_entered(Ball) → GameManager.add_score(1000000), play sound.

### UI and audio

- **UI.gd**: Connects to GameManager scored, round_lost, multiplier_increased, game_started, game_over; updates ScoreLabel, MultiplierLabel, RoundsLabel; shows GameOverPanel on game_over; Replay → MainMenu.
- **SoundManager**: Present in Main; SkillShot calls play_sound("obstacle_hit"). Other sounds (ball_launch, ball_lost, flipper_click) used by Launcher/Ball if connected.

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
