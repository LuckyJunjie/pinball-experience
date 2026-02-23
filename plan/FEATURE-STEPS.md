# Feature Steps: Baseline → Target (One Item per Step)

**Document ID:** 1_04

Evolve the **Phase 0 baseline** to **full requirements** ([../requirements/Requirements.md](../requirements/Requirements.md)) by introducing or changing **one item per step**. Each step keeps the game **playable** and should be covered by a **test** where practical. No step adds a whole zone at once — e.g. “first time we introduce ramp” is one step that only adds the ramp and its test.

---

**Assumptions about baseline (minimize rework):** Phase 2 assumes the baseline was built with **target-shaped state** and **reusable components** per [BASELINE-V3-SCOPE.md](BASELINE-V3-SCOPE.md) and [BASELINE-STEPS.md](BASELINE-STEPS.md): roundScore, totalScore, multiplier (1–6), rounds (3), status, bonusHistory; generic scoring component for bumpers/targets; single pluggable multiplier trigger; parameterized bonus-ball spawn (position + impulse). Step 2.2 then only aligns caps and signals; zone steps reuse or replace components without refactoring scoring or spawn logic.

## Principles

- **One item per step:** One mechanism, one zone component, or one UI change — not “whole Android Acres” in a single step.
- **Playable after each step:** The game always runs and can be played; no broken or half-finished states.
- **Test per step:** Each step includes a concrete test (automated or manual checklist) that proves the new item works.
- **Order:** Steps are ordered so dependencies come first (e.g. game state before I/O point values; ramp before multiplier-from-ramp).

---

## Start flow and state

### Step 2.1 – Start flow: initial → play

- **Item:** Initial screen (main menu) with **Play**; Play loads playfield and starts game (status = playing, spawn ball at launcher). Replay after game over returns to same start/play flow.
- **Refs:** FR-1.1.1, FR-1.1.4, FR-1.1.5 (partial).
- **Test:** From main menu, press Play → playfield loads, one ball spawns at launcher, status = playing. After game over, Replay → playfield loads again with new game.

### Step 2.2 – Game state and scoring (requirements shape)

- **Item:** State: roundScore, totalScore, multiplier (1–6), rounds (3), bonusHistory, status (waiting | playing | gameOver). Round lost: totalScore += roundScore × multiplier; roundScore = 0; multiplier = 1; rounds -= 1; if rounds == 0 → gameOver. Display score = roundScore + totalScore (capped). Scoring only when status == playing.
- **Refs:** FR-1.2.x, FR-1.5.x, TR-3.3, TR-3.4.
- **Test:** Round lost → totalScore increased by roundScore × multiplier; roundScore and multiplier reset; rounds decrement; at rounds == 0, status = gameOver.

### Step 2.3 – Point values and skill shot (I/O values)

- **Item:** Point values 5k, 20k, 200k, 1M. Skill shot awards 1,000,000. Existing rollovers/kicker/signpost (if any) 5,000. Optional score popups.
- **Refs:** FR-1.4.1, FR-1.4.2, FR-1.4.3, FR-1.4.6.
- **Test:** Hit skill shot → +1M to roundScore. Hit 5k target → +5k. No other point values change.

### Step 2.4 – Character selection

- **Item:** **Character selection** screen: four themes (Sparky, Dino, Dash, Android); selection stored for session; flow: Initial → Play → Character select → next (How to Play).
- **Refs:** FR-1.1.2, FR-1.9.1, FR-1.9.2.
- **Test:** Play → Character select appears; choose theme → selection stored; ball asset / leaderboard icon match theme for session.

### Step 2.5 – How to Play screen

- **Item:** **How to Play** screen after character select; dismiss → start game. Replay after game over returns to character select (not initial).
- **Refs:** FR-1.1.3, FR-1.9.3, FR-1.1.5.
- **Test:** Character selected → How to Play shown; dismiss → game starts. After game over, Replay → Character select (not main menu).

### Step 2.6 – HUD (score, multiplier, rounds)

- **Item:** **HUD** when playing: score (roundScore + totalScore), multiplier (1–6), rounds. Overlays: Play button (before play), Replay (after game over); optional mobile controls.
- **Refs:** FR-1.10.2, FR-1.10.3.
- **Test:** During play, HUD shows correct score, multiplier, rounds; Replay visible after game over.

### Step 2.7 – Camera (waiting / playing / game over)

- **Item:** **Camera** focus/zoom: waiting → top of board; playing → playfield; game over → top. Tween on transition.
- **Refs:** FR-1.10.1.
- **Test:** Status waiting → camera at top; playing → camera on playfield; game over → camera at top.

---

## Zones and components (one item per step)

### Step 2.8 – Google rollovers (5k each)

- **Item:** **Google rollovers** left and right; ball enters → 5,000 points each. No Google Word yet.
- **Refs:** FR-1.4.3, FR-1.7.7.
- **Test:** Ball enters left rollover → +5k; right rollover → +5k; score updates.

### Step 2.9 – Google Word letters and spell “Google”

- **Item:** **Google Word** letters (e.g. 6); each can be “lit” on hit; when all lit → trigger googleWord bonus (bonus only; no bonus ball in this step if not yet implemented).
- **Refs:** FR-1.6.2, FR-1.7.7.
- **Test:** Light all letters → googleWord bonus recorded; bonusHistory contains googleWord.

### Step 2.10 – Bonus ball (5s) from Google Word / Dash Nest

- **Item:** When **googleWord** or **dashNest** bonus triggers → 5 s timer → spawn **bonus ball** at DinoWalls position with impulse toward center. Multiball indicators (4) animate when bonus ball earned.
- **Refs:** FR-1.3.4, FR-1.6.2, FR-1.6.3, FR-1.7.10.
- **Test:** Trigger googleWord (or dashNest) → after 5 s one extra ball spawns at DinoWalls; multiball indicators show active.

### Step 2.11 – Multiball indicators (4)

- **Item:** **Multiball indicators** (4) visible on playfield; light/animate when bonus ball is earned (Google Word or Dash Nest).
- **Refs:** FR-1.7.10, FR-1.6.5.
- **Test:** Bonus ball earned → all 4 indicators show lit/animated state.

### Step 2.12 – SpaceshipRamp (5k shot, ramp bonus, multiplier)

- **Item:** **SpaceshipRamp** only: ball enters ramp → 5,000 points; every 5 ramp hits in round → multiplier +1 (max 6); ramp bonus (e.g. 1M) when condition met. Multiplier reset on round lost (already in state).
- **Refs:** FR-1.5.2, FR-1.7.5, FR-1.4.5.
- **Test:** Hit ramp 5 times → multiplier increases by 1; hit 25 times → multiplier = 6 (capped). Round lost → multiplier = 1. Ramp awards 5k per hit; ramp bonus 1M when defined condition met.

### Step 2.13 – Android Acres rail

- **Item:** **Rail** in Android Acres (ball path/visual); no new scoring in this step unless rail has a defined trigger — if none, rail is layout/behavior only.
- **Refs:** FR-1.7.5.
- **Test:** Ball can travel along rail; no regression to ramp or bumpers.

### Step 2.14 – Android bumpers A / B / COW (20k each)

- **Item:** **Android bumpers** A, B, COW; ball contact → 20,000 points each.
- **Refs:** FR-1.4.4, FR-1.7.5.
- **Test:** Hit each bumper → +20k; score correct.

### Step 2.15 – AndroidSpaceship target (200k + bonus)

- **Item:** **AndroidSpaceship** target + animatronic: ball enters → 200,000 points + **androidSpaceship** bonus in bonusHistory.
- **Refs:** FR-1.6.4, FR-1.7.5.
- **Test:** Ball enters AndroidSpaceship → +200k and bonusHistory contains androidSpaceship.

### Step 2.16 – ChromeDino mouth (200k + dinoChomp)

- **Item:** **ChromeDino** mouth sensor: ball enters → 200,000 points + **dinoChomp** bonus.
- **Refs:** FR-1.6.4, FR-1.7.6.
- **Test:** Ball enters Dino mouth → +200k and dinoChomp in bonusHistory.

### Step 2.17 – DinoWalls (bonus ball spawn position)

- **Item:** **DinoWalls** area used as **bonus ball spawn position** (with impulse toward center). Already used in Step 2.10; ensure position and impulse match design.
- **Refs:** FR-1.3.4, FR-1.7.6.
- **Test:** Bonus ball spawns at DinoWalls with correct impulse; ball count increases.

### Step 2.18 – Dino slingshots (optional)

- **Item:** **Slingshots** in Dino Desert (if in scope); behavior per design (e.g. kick back). Optional step.
- **Refs:** FR-1.7.6.
- **Test:** Ball hits slingshot → deflects as designed.

### Step 2.19 – Signpost (5k)

- **Item:** **Signpost** (Flutter Forest): ball contact → 5,000 points.
- **Refs:** FR-1.4.3, FR-1.7.8.
- **Test:** Ball hits signpost → +5k.

### Step 2.20 – Dash bumpers (main 200k, A/B 20k) and animatronic

- **Item:** **Dash bumpers:** main 200,000; A and B 20,000 each; Dash animatronic (visual/behavior per design).
- **Refs:** FR-1.4.4, FR-1.7.8.
- **Test:** Hit main Dash bumper → +200k; hit A or B → +20k each.

### Step 2.21 – Dash Nest bonus + bonus ball

- **Item:** When **all Dash bumpers** are lit in the round → **dashNest** bonus + same bonus ball logic as Google Word (5 s, spawn at DinoWalls). Multiball indicators already in place.
- **Refs:** FR-1.6.3, FR-1.7.8.
- **Test:** Light all Dash bumpers → dashNest in bonusHistory; 5 s later bonus ball spawns.

### Step 2.22 – Sparky bumpers A/B/C (20k) and animatronic

- **Item:** **Sparky bumpers** A, B, C: 20,000 each; Sparky animatronic.
- **Refs:** FR-1.4.4, FR-1.7.9.
- **Test:** Hit each Sparky bumper → +20k.

### Step 2.23 – Sparky computer (200k + sparkyTurboCharge)

- **Item:** **Sparky computer** target: ball enters → 200,000 points + **sparkyTurboCharge** bonus.
- **Refs:** FR-1.6.4, FR-1.7.9.
- **Test:** Ball enters Sparky computer → +200k and sparkyTurboCharge in bonusHistory.

### Step 2.24 – Multiplier targets x2–x6 (visual)

- **Item:** **Multiplier targets** x2–x6 at fixed positions; visual indicators show current multiplier (lit 1..multiplier). Logic already in Step 2.12 (ramp); this step is placement and visuals.
- **Refs:** FR-1.5.x, FR-1.7.7.
- **Test:** Multiplier 3 → first 3 multiplier targets lit; multiplier 6 → all 6 lit.

### Step 2.25 – Bonus history display

- **Item:** **Bonus history** recorded and shown (e.g. in backbox or HUD); used for multiball indicator logic. Ensure all five bonuses (googleWord, dashNest, sparkyTurboCharge, dinoChomp, androidSpaceship) are recorded and visible.
- **Refs:** FR-1.6.5.
- **Test:** Trigger each bonus → bonusHistory contains it; UI shows list.

---

## Backbox and input

### Step 2.26 – Backbox: leaderboard and initials

- **Item:** **Backbox** displays: loading, **leaderboard** (top 10: rank, initials, score, character icon), **initials form** after game over; on submit → store entry (local/mock) → **game over info**.
- **Refs:** FR-1.8.1, FR-1.8.2, FR-1.8.3.
- **Test:** Game over → backbox shows initials; submit → entry saved, game over info shown; leaderboard shows top 10.

### Step 2.27 – Backbox: share and mobile overlay

- **Item:** **Share:** copy score text or share URL (local dialog). Optional mobile overlay for controls when entering initials.
- **Refs:** FR-1.8.4, FR-1.10.3.
- **Test:** Share button → copy/share dialog; on mobile, initials screen has acceptable overlay behavior.

### Step 2.28 – Bottom group: kickers (5k each)

- **Item:** **Kickers** left and right: ball contact → 5,000 points each. Flippers and baseboard already present; this step adds kicker scoring.
- **Refs:** FR-1.4.3, FR-1.7.4.
- **Test:** Ball hits left/right kicker → +5k each.

### Step 2.29 – Launcher and input (I/O spec)

- **Item:** **Launcher:** launch ramp, flapper, plunger, rocket sprite; ball spawn at launcher on round start; user launches ball. **Input:** Desktop (keyboard); mobile: left/right half = flippers, tap plunger = launch; Pause Esc / optional button.
- **Refs:** FR-1.7.2, FR-1.7.4, NFR-2.3.
- **Test:** Round start → ball at launcher; Space/tap launches; input mapping per requirements table.

### Step 2.30 – Polish and NFRs

- **Item:** **Performance:** 60 FPS target; low input latency. **Audio:** Bumper, kicker, rollover, drain, launch, bonus, multiplier; optional score popups and UI feedback. **Assets:** Align with Asset-Requirements where missing; placeholders OK.
- **Refs:** NFR-2.1, NFR-2.2, NFR-2.4; design Asset-Requirements.
- **Test:** FPS and latency acceptable; sounds play on correct events.

---

## Shopping & Progression (Store, coins, player assets)

### Step 2.31 – Player assets and persistence

- **Item:** **Player assets** (coins, purchased upgrades, level progress) with **persistence**: load on session start, save on change. Single data layer shared by Classic and Level modes. No Store UI yet — just data + save/load (e.g. JSON or Godot save).
- **Refs:** FR-5.1.3, FR-5.2.2, FR-7.5, FR-7.6.
- **Test:** Change coins/upgrades in memory → save → restart app → load → same values. Classic and Level read/write same asset instance.

### Step 2.32 – Main menu: Play, Levels, Store

- **Item:** **Main menu (Splash)** offers three actions: **Play** (Classic), **Levels** (Level Mode), **Store**. Play → existing flow (character select → how to play → play). Levels → Level Select (can be placeholder). Store → Store scene (can be placeholder). Post-game: optional Store entry from leaderboard.
- **Refs:** FR-1.1.1, FR-5.1.1, FR-7.1.
- **Test:** Main menu shows three options; each navigates to correct flow or placeholder; back from Store/Level Select returns to menu.

### Step 2.33 – Coin earning (Classic)

- **Item:** **Coins** earned in Classic: completing rounds (e.g. 100 per round survived), bonuses (e.g. 500 per bonus type), score milestones (e.g. 1,000 coins at 1M points). Coins added to player assets and persisted.
- **Refs:** FR-5.1.2.
- **Test:** Complete one round → coins increase by round reward; hit bonus → coins increase; reach 1M score → milestone coins added; persist and reload → coin total correct.

### Step 2.34 – Store scene and access

- **Item:** **Store** scene/UI: accessible from main menu and after game over (from leaderboard). Display coin balance; list of items (placeholder or real). Back/Done returns to Splash or Leaderboard. No purchase logic yet if 2.35 is separate.
- **Refs:** FR-5.1.1.
- **Test:** Open Store from menu → see balance and list; open from leaderboard after game over → same; Back returns correctly.

### Step 2.35 – Store: upgradable items and purchase

- **Item:** **Upgradable items** in Store: Balls (e.g. steel, magnetic, lightweight), Flippers (size/strength), Plunger (control/auto), Bumpers (score multipliers), Multiplier Boost, Extra Ball. Purchase with coins; permanent or consumable per design. Persist purchased state in player assets.
- **Refs:** FR-5.2.1, FR-5.2.2.
- **Test:** Purchase an upgrade → coins decrease, upgrade unlocked; restart → upgrade still unlocked. Apply upgrade in Classic (e.g. extra round or multiplier boost) and verify effect.

### Step 2.36 – Store: character-themed upgrades

- **Item:** **Character theme** affects Store: available or themed upgrades (e.g. Dino-themed for Dino character). Store filters or labels items by character where applicable.
- **Refs:** FR-5.2.3, FR-1.9.2.
- **Test:** Select Dino → open Store → Dino-themed items visible or highlighted; purchase and use in game with Dino theme.

### Step 2.37 – Post-game coin grant and Score Range Board hook

- **Item:** **Post-game:** Grant coins for round/bonus/milestone to player assets when game ends (if not already granted during play). Ensure Score Range Board can read current score and bracket for next step.
- **Refs:** FR-5.1.2, FR-6.3.
- **Test:** Finish game → coins updated; reload → coins persisted. (Score Range Board notification in 2.38.)

---

## Score Range Board

### Step 2.38 – Score Range Board

- **Item:** **Score Range Board:** Accessible from main menu or overlay. Displays score brackets (e.g. 0–100k, 100k–500k, 500k–1M, 1M–5M, 5M+) and rewards (coin bonuses, unlockables). On reaching a new bracket during a game, show notification; post-game grant reward to player assets. Board updates in real time (progress bar or highlight toward next bracket).
- **Refs:** FR-6.1, FR-6.2, FR-6.3, FR-6.4.
- **Test:** Open board → see brackets and current progress. Reach new bracket in game → notification; after game over → reward coins added. Progress bar reflects current score vs next bracket.

---

## Level Mode

### Step 2.39 – Level Mode: entry and Level Select screen

- **Item:** **Level Select** screen: entry from main menu **Levels**. Shows level list or world map; levels locked/unlocked by progression. Select a level → start level (next step) or character select then level. Back → main menu.
- **Refs:** FR-7.1, FR-7.2.
- **Test:** Main menu → Levels → Level Select; see at least one playable level; select level → proceeds to level flow or placeholder; Back → menu.

### Step 2.40 – Level data and progression

- **Item:** **Level data:** Each level has id, layout reference, objectives (e.g. target score, tasks), rewards (coins, unlocks). Progression: complete level N → unlock N+1 (or defined next). Level progress (completed, stars, high score) persisted in player assets.
- **Refs:** FR-7.2, FR-7.4, FR-7.5, FR-7.6.
- **Test:** Complete level 1 → level 2 unlocked; progress saved; restart → level 2 still unlocked. Per-level high score saved.

### Step 2.41 – Level playfield (custom layout)

- **Item:** **Level playfield:** Reuse same physics and core components (flippers, drain, launcher, ball). Level-specific **layout** (bumper positions, ramp angles, hazards) loaded from level data. One or two example levels with different layouts.
- **Refs:** FR-7.3, FR-7.7.
- **Test:** Start level → playfield matches level layout; physics identical to Classic; ball drains and round/level logic runs.

### Step 2.42 – Level objectives

- **Item:** **Level objectives:** Reach target score; or complete tasks (e.g. light all Google letters, hit all bumpers); or survive time limit. Success → LevelComplete; fail (e.g. rounds == 0) → GameOver → Leaderboard. Level-specific HUD or overlay for objective (e.g. “Score 500k”).
- **Refs:** FR-7.4.
- **Test:** Level with “reach 500k” → at 500k level completes; level with “hit all bumpers” → when all hit, level completes; fail condition → game over.

### Step 2.43 – Level completion rewards

- **Item:** **Level completion:** On LevelComplete, grant coins and optional unlocks to **player assets** (same as Store/Classic). Unlock next level. Persist completion and rewards.
- **Refs:** FR-7.5, FR-5.1.2.
- **Test:** Complete level → coins increase, next level unlocked; reopen Store → same coin balance; restart → progress and coins persisted.

### Step 2.44 – Level progress and high scores persistence

- **Item:** **Level progress and per-level high scores** saved locally. Level Select shows completed state and best score per level. Same persistence layer as player assets.
- **Refs:** FR-7.6.
- **Test:** Complete level with score X → Level Select shows completed and score X; beat score later → high score updates and persists.

---

## Dependency order (summary)

- **2.1 → 2.2 → 2.3:** Start flow, then state/scoring, then I/O point values.
- **2.4, 2.5:** Character select, then How to Play.
- **2.6, 2.7:** HUD, then camera (can be parallel).
- **2.8 → 2.11:** Google rollovers → Google Word → bonus ball + multiball indicators.
- **2.12 → 2.15:** Ramp only → rail → Android bumpers → AndroidSpaceship.
- **2.16 → 2.18:** Dino mouth → DinoWalls (spawn) → slingshots.
- **2.19 → 2.21:** Signpost → Dash bumpers → Dash Nest.
- **2.22 → 2.23:** Sparky bumpers → Sparky computer.
- **2.24, 2.25:** Multiplier visuals, bonus history display.
- **2.26 → 2.27:** Backbox leaderboard/initials, then share.
- **2.28 → 2.30:** Kickers, launcher/input, polish.
- **2.31:** Player assets + persistence (before Store and Level Mode).
- **2.32:** Main menu Play / Levels / Store (flow).
- **2.33 → 2.37:** Coin earning → Store scene → upgradable items → character-themed → post-game grant.
- **2.38:** Score Range Board (after coins and post-game).
- **2.39 → 2.44:** Level Select → level data/progression → level playfield → objectives → completion rewards → progress/high scores.

Steps can be renumbered or grouped in a single PR for convenience, but each **logical change** should remain one item so the game stays playable and testable after every step.
