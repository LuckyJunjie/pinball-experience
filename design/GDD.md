# Pinball Game – Game Design Document

**Document ID:** 3_02

## Document Information

- **Game Title**: Pinball (I/O Pinball–inspired, with Shop, Score Board, Level Mode)
- **Version**: 2.0
- **Source**: Same core game design as Flutter I/O Pinball (Google I/O 2022); extended with Store, Score Range Board, and Level Mode per [Requirements](../requirements/Requirements.md).
- **Engine**: Godot 4.x
- **Platform**: Desktop and mobile

---

## 1. Game Overview

### 1.1 Concept

The game replicates I/O Pinball rules, playfield zones, scoring, bonuses, multiplier, and rounds. It is extended with: **Store** (coins, upgradable items), **Score Range Board** (score brackets and rewards), and **Level Mode** (multiple levels with custom layouts and objectives). Leaderboard and share use local or optional backend. **Player assets** (coins, upgrades) are persisted and shared across **Classic** and **Level** modes.

### 1.2 Main Menu and Modes

- **Splash / Main menu**: **Play** (Classic), **Levels** (Level Mode), **Store**.
- **Classic**: Endless play, 3 rounds, standard I/O Pinball flow.
- **Level Mode**: Progression of levels with custom layouts and objectives; same physics and player assets as Classic.
- **Store**: Accessible from main menu and after game over; spend coins on upgrades used in both modes.

### 1.3 Core Loop (Classic)

1. **Start**: Play → Character select (4 themes) → How to Play → Game starts.
2. **Play**: Camera on playfield; 3 rounds; round score × multiplier added to total on round lost; multiplier resets to 1.
3. **Game Over**: Backbox shows initials → leaderboard → game over info → share (optional). Replay → character select; optional Store.

### 1.4 Win Condition

- **Classic**: Maximize total score and appear on the leaderboard.
- **Level Mode**: Complete level objectives (e.g. target score, tasks); earn coins and unlock levels/upgrades.

---

## 2. Mechanics

### 2.1 Scoring

- **Display score**: roundScore + totalScore (capped at 9999999999).
- **During round**: Hits add points to roundScore (5k, 20k, 200k, 1M depending on target).
- **End of round**: totalScore += roundScore * multiplier; then roundScore = 0, multiplier = 1.

### 2.2 Multiplier

- **Range**: 1–6.
- **Increase**: +1 for every 5 successful ramp shots (SpaceshipRamp in Android Acres). At 6, no further increase from ramp.
- **Reset**: To 1 on each round lost.

### 2.3 Bonus Ball

- **Trigger**: Google Word (all letters lit) or Dash Nest (all Dash bumpers lit).
- **Effect**: Bonus recorded; after 5 seconds a bonus ball spawns from DinoWalls area with impulse toward center. Multiball indicators (4) animate when bonus ball is earned.

### 2.4 Bonuses (Five)

| Bonus | Trigger |
|-------|---------|
| googleWord | All Google letters lit |
| dashNest | All Dash bumpers lit |
| sparkyTurboCharge | Ball enters Sparky computer target |
| dinoChomp | Ball enters Chrome Dino mouth |
| androidSpaceship | Ball enters Android spaceship target |

- googleWord and dashNest also trigger bonus ball (5s delay). All bonuses are recorded in bonusHistory.

---

## 3. Playfield Layout

### 3.1 Zones (Top to Bottom / Logical Order)

- **Backbox**: Marquee and display (leaderboard, initials, game over, share). Position above board (e.g. y = -87 in Flutter coords).
- **Google Gallery**: Center; Google Word + left/right rollovers (5k each).
- **Multipliers**: Five multiplier targets (x2–x6) at fixed positions.
- **Multiballs**: Four indicator lights (lit when bonus ball earned).
- **Skill Shot**: Rollover/target for 1M points.
- **Android Acres**: Left; SpaceshipRamp, rail, Android bumpers A/B/COW, AndroidSpaceship + animatronic.
- **Dino Desert**: Near launcher; ChromeDino, DinoWalls, Slingshots.
- **Flutter Forest**: Top right; Signpost, Dash bumpers main/A/B, Dash animatronic.
- **Sparky Scorch**: Top left; Sparky bumpers A/B/C, Sparky animatronic, Sparky computer.
- **Drain**: Bottom edge; ball contact removes ball and triggers round-lost when no balls left.
- **Bottom Group**: Left and right; flippers, baseboard, kickers (5k each).
- **Launcher**: Right side; launch ramp, flapper, plunger, rocket sprite; ball spawns here at round start.

### 3.2 Board Dimensions

- Reference: 101.6 x 143.8 (Flutter BoardDimensions). Godot may use same aspect or scale to fit viewport.

---

## 4. Flow

Flow aligns with the [state machine and transitions](../requirements/Requirements.md#1-state-machine-and-transitions) in requirements §1. See [Game-Flow.md](Game-Flow.md) for the full diagram and transition table.

### 4.1 Main Menu (Splash)

- **Play** (Classic) → CharacterSelect → HowToPlay → Playing.
- **Levels** (Level Mode) → LevelSelect → (optional CharacterSelect) → LevelPlaying.
- **Store** → Store UI; return to Splash or (from post-game) Leaderboard.

### 4.2 Start Flow (Classic)

1. **Initial**: Main menu with Play, Levels, Store.
2. **Play** → **Character Select**: User picks Sparky, Dino, Dash, or Android.
3. **How to Play**: User dismisses to continue.
4. **Play**: Game starts; status = playing; camera to playfield; ball spawns at launcher.

### 4.3 Game State

- **Waiting**: Before first ball in play (e.g. camera on backbox/top).
- **Playing**: Ball(s) in play; scoring and multiplier active; camera on playfield.
- **Game Over**: Rounds = 0; backbox shows initials then game over info.

### 4.4 Backbox Flow

- **Loading**: Fetching leaderboard (or local load).
- **Leaderboard**: Top 10 when idle or before game.
- **Initials**: After game over; user enters initials and submits.
- **Game Over Info**: After submit; option to share.
- **Share**: User can share score (e.g. copy text or native share).
- From game over: optional **Store** entry before or after Replay / Back to menu.

### 4.5 Store and Level Mode Flow

- **Store**: Enter from Splash or Leaderboard; spend coins on upgrades; Back/Done returns to Splash or Leaderboard.
- **Level Mode**: LevelSelect → pick level → (optional CharacterSelect) → HowToPlay → LevelPlaying; LevelComplete → rewards to player assets → LevelSelect or Splash.

---

## 5. UI and Presentation

### 5.1 Main Menu and Mode Screens

- **Splash**: Buttons for Play (Classic), Levels, Store.
- **Store**: List of upgradable items (balls, flippers, plunger, bumpers, multiplier boost, extra ball); coin balance; purchase and back.
- **Level Select**: World map or level list; level locked/unlocked; select level to play.
- **Score Range Board**: Accessible from main menu or overlay; score brackets and rewards; progress toward next bracket (see §8).

### 5.2 HUD (When Playing, Not Game Over)

- Score (roundScore + totalScore).
- Multiplier (1x–6x).
- Rounds left (3 down to 0).

### 5.3 Overlays

- **Play button**: Before game starts (start flow).
- **Replay button**: After game over.
- **Mobile controls**: Optional overlay when showing initials on mobile (match Flutter behavior).

### 5.4 Backbox Displays

- Leaderboard (top 10: rank, initials, score, character icon).
- Initials input (score, character icon, submit).
- Game over info (score, share button).
- Share options (e.g. copy score text, share URL).
- Loading and failure states for leaderboard/initials.

### 5.5 Character Themes

- **Sparky, Dino, Dash, Android**: Each provides ball asset and leaderboard icon. Selection affects visuals for the session and may influence Store upgrades (e.g. themed upgrades per character).

---

## 6. Input

Input mapping (per requirements §2.4):

| Action | Desktop | Mobile |
|--------|---------|--------|
| Left flipper | Left Arrow, A | Touch left half of playfield/screen |
| Right flipper | Right Arrow, D | Touch right half of playfield/screen |
| Plunger / launch | Space, Down Arrow | Tap on plunger/launcher zone |
| Pause | Esc | (Optional) Pause button |

- **Replay**: Button or tap to go back to character select after game over. **Store**: Optional from leaderboard/game over screen.

---

## 7. Shopping & Progression

Player assets (coins, upgrades) are **persisted** (e.g. local storage) and **shared** across Classic and Level modes. See requirements §5 for full spec.

- **Store**: Accessible from main menu and after game over. Players spend **coins** on upgradable items.
- **Coins**: Earned from rounds completed, bonuses, score milestones, and level completion.
- **Upgradable items** (examples): Balls (steel, magnetic, lightweight), Flippers (size/strength), Plunger (control/auto), Bumpers (score multipliers), Multiplier Boost (start round with multiplier > 1), Extra Ball (additional round). Items may be permanent (unlocked) or consumable (per game).
- **Character theme** may affect available or themed upgrades (e.g. Dino-themed for Dino character).

---

## 8. Score Range Board

- **Access**: Main menu or overlay during gameplay.
- **Content**: Predefined score brackets (e.g. 0–100k, 100k–500k, 500k–1M, 1M–5M, 5M+) with rewards (coin bonuses, unlockable items).
- **Behavior**: On reaching a new bracket, show notification and grant reward post-game (e.g. coins added to player assets). Board updates in real time (progress bar or highlight toward next bracket). See requirements §6.

---

## 9. Level Mode

Level mode uses the **same physics and core mechanics** as Classic and the **same player assets** (coins, upgrades). See requirements §7.

- **Entry**: Main menu → Levels → Level Select.
- **Progression**: Levels in sequence (world map or list) with increasing difficulty.
- **Layout**: Each level has custom playfield (bumper placement, ramps, hazards); core components (flippers, drain, launcher) reused.
- **Objectives**: e.g. target score, tasks (light all Google letters, hit all bumpers), time limit.
- **Rewards**: Coins and unlocks applied to shared player assets; level progress and per-level high scores saved locally.

---

## 10. Camera

- **Waiting**: Zoom/focus on top of board (e.g. backbox area).
- **Playing**: Zoom/focus on playfield (e.g. center y ≈ -7.8).
- **Game Over**: Zoom/focus on top (e.g. backbox).

Exact zoom ratios and positions should match playability and aspect ratio (reference: Flutter camera focusing behavior). Level mode may show level-specific HUD (e.g. objectives).

---

## 11. Audio (Recommendations)

- Bumper hit, kicker hit, rollover, drain, ball launch, bonus, multiplier increase, and UI feedback. Use or adapt assets from Flutter pinball_audio / project assets.

---

## 12. Reference

- Design and behavior parity with Flutter I/O Pinball; see [flutter-reference/FLUTTER-PINBALL-PARSING.md](flutter-reference/FLUTTER-PINBALL-PARSING.md) and [details/Component-Specifications.md](details/Component-Specifications.md) for details.
- Requirements: [Requirements.md](../requirements/Requirements.md) (§0–§7 for flow, states, Store, Score Board, Level Mode).
