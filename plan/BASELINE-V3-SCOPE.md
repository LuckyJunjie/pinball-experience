# Baseline (v3.0-equivalent) Scope

**Document ID:** 1_03

This document defines what “Phase 0 baseline” means: a working game in **pinball-experience** that matches the **scope** of the legacy **archived v3.0** that worked.

**How we build it:** We do **not** implement everything at once. We start with a **primitive playable** main scene (launcher + flippers only), then add **drain**, **walls**, **obstacles**, **rounds**, and v3.0-style systems **step by step**. Each step keeps the game playable and adds a test where practical. The ordered steps are in [BASELINE-STEPS.md](BASELINE-STEPS.md).

### Alignment with target (minimize Phase 2 rework)

We shape the baseline so Phase 2 ([FEATURE-STEPS.md](FEATURE-STEPS.md)) and the [GDD](../design/GDD.md) extend it with **minimal refactor**:

- **Game state**: Use the **same state shape** as the target from the start: **roundScore**, **totalScore**, **multiplier** (1–6), **rounds** (3), **status** (waiting | playing | gameOver), **bonusHistory** (list). Round lost: totalScore += roundScore × multiplier; roundScore = 0; multiplier = 1; rounds -= 1. Scoring only when status == playing. Phase 2 then only aligns caps and signals, not data structure.
- **Obstacles / bumpers**: Use a **generic, reusable scoring component** (e.g. one scene/script with configurable points). Phase 2 reuses it inside zone nodes (e.g. AndroidBumperA) or replaces instances with I/O-specific nodes; no rewrite of scoring logic.
- **Multiplier trigger**: Use a **single pluggable source** (e.g. one target or placeholder “ramp” that calls increase_multiplier() every N hits). Phase 2 replaces that source with SpaceshipRamp; GameManager multiplier logic stays unchanged.
- **Skill shot**: Use **1M points** and a time window from the start; same node can be kept and repositioned in Phase 2.
- **Multiball**: **Parameterize spawn position** (launcher or a position); Phase 2 adds DinoWalls position and triggers (googleWord / dashNest) without changing spawn API.
- **Combo**: Not in target requirements or GDD. Implement in baseline as **optional** (v3.0 parity); Phase 2 does **not** show combo in HUD or use it in I/O rules — no code removal, just not exposed. Avoids building then deleting.
- **Scene structure**: Baseline playfield can stay **flat** (no zone containers). Phase 2 **adds** zone nodes (AndroidAcres, DinoDesert, etc.) and places I/O components inside them; baseline generic obstacles are removed or moved, not refactored in place.

---

## Legacy v3.0 reference

- **Design:** [archived/v3.0/design/](https://github.com/LuckyJunjie/pin-ball/tree/main/archived/v3.0/design) in the legacy repo.  
  Key files: `GDD-v3.0.md`, `Technical-Design-v3.0.md`, `Game-Flow-v3.0.md`, `V3.0-IMPLEMENTATION-SUMMARY.md`, `Component-Specifications-v3.0.md`, `Physics-Specifications-v3.0.md`, `Asset-Requirements-v3.0.md`.
- **Legacy code (v1–v3 scenes/scripts):** [archived/legacy/](https://github.com/LuckyJunjie/pin-ball/tree/main/archived/legacy) in the legacy repo.  
  Scenes: Main.tscn, MainMenu.tscn, ShopScene.tscn, Obstacle.tscn, Hold.tscn, BallQueue.tscn.  
  Scripts: GameManager.gd, BallQueue.gd, Obstacle.gd, Hold.gd, MainMenuManager.gd, ShopManager.gd, UI.gd, ObstacleSpawner.gd, MultiballManager.gd, MultiballTarget.gd.
- **v3.0 implementation (was in pin-ball root):** SkillShot.gd, MultiballManager.gd, MultiplierSystem.gd, ComboSystem.gd, AnimationManager.gd, ParticleManager.gd; and changes to Flipper.gd, Ball.gd, GameManager.gd, Obstacle.gd, UI.gd, SoundManager.gd (see archived v3.0 implementation summary).

## What “v3.0-equivalent” means for the baseline

We do **not** copy the legacy repo into this project. We implement (or selectively port) behavior so that **pinball-experience** has:

### 1. Core gameplay (must have)

- **Playfield:** Board with boundaries; ball, flippers, launcher, drain.
- **Ball:** Single or multiple balls; spawn at launcher (or from a simple queue); physics (gravity, bounce, friction).
- **Flippers:** Left/right; keyboard and (optionally) touch; enhanced physics (strength, elasticity, return) in line with v3.0.
- **Launcher:** Plunger/charge or tap to launch; ball enters playfield from launcher.
- **Drain:** Ball removal on contact; when no balls left → round lost (or ball count decrement).
- **Rounds / ball life:** Either 3 rounds (one ball per round) or a small ball queue (e.g. 3–4 balls) with “round lost” when queue empty; game over when no rounds/balls left.
- **Scoring:** Basic points on hits (obstacles/bumpers/targets); score displayed. Use **roundScore** (during round) and **totalScore** (accumulated); on round lost: totalScore += roundScore × multiplier. Matches target state shape.

### 2. v3.0-style systems (must have for baseline)

- **Skill shot:** One or more targets active for a short window (e.g. 2–3 s) after launch; hitting them awards bonus points; visual/audio feedback.
- **Multiplier:** Multiplier value (e.g. 1–6 or 1–10); increases on certain hits or ramp; applied to score (e.g. on round end or per hit); optional decay timer; shown in UI.
- **Multiball:** Trigger (e.g. specific target combo or manual for baseline); multiple balls in play; optional scoring multiplier during multiball; multiball end when balls drain.
- **Combo:** Consecutive hits within a time window increase combo; combo affects score or multiplier; UI shows combo.

### 3. Polish (should have, can be minimal)

- **Physics:** Flipper strength/elasticity, playfield friction/bounce in line with v3.0 or design docs.
- **Animation:** Score popups, multiplier pulse, simple UI transitions.
- **Particles:** Bumper/hit effects, optional ball trail.
- **Audio:** Bumper, drain, launch, flipper, skill shot, multiball, combo; pitch variation optional.

### 4. Out of scope for baseline (add in Phase 2)

- I/O Pinball–specific zones (Google Gallery, Android Acres, Dino Desert, Flutter Forest, Sparky Scorch) as full implementations.
- Character selection (4 themes).
- How to Play screen.
- Backbox (leaderboard, initials, share).
- Exact I/O scoring (5k, 20k, 200k, 1M) and five named bonuses; bonus ball 5s spawn.
- Shop, currency, battle pass (excluded by current requirements).

### 5. Playfield layout for baseline

- We can use a **simplified** playfield: e.g. flat board with walls, drain, launcher, flippers, and a small set of **generic** obstacles/bumpers/skill-shot targets so that core + v3.0 systems are testable.
- Use **one reusable scoring component** (e.g. scene with configurable points) for bumpers/targets so Phase 2 can reuse it in zone nodes or swap instances without refactoring scoring logic.
- Maze pipe, hold spawners, and complex v1/v2 layouts are **optional**; prefer a layout that we can later replace or extend into I/O zones rather than a large port of legacy-specific content.

## Deliverable

Phase 0 is done when:

- The game runs in Godot (launch → play → drain → round lost → game over or replay).
- Core + skill shot + multiplier + multiball + combo (+ polish) behave and are visible/audible.
- One main scene and one set of scripts (no version branches in this repo).
- We can run Phase 1 tests against this baseline.

**Order of implementation:** Follow [BASELINE-STEPS.md](BASELINE-STEPS.md): 0.1 (primitive launcher + flippers) → 0.2 (drain) → 0.3 (walls) → 0.4 (obstacles + scoring) → 0.5 (rounds + game over) → 0.6–0.10 (skill shot, multiplier, multiball, combo, polish). After each step the game must remain playable.

Implementation should follow [../design/Technical-Design.md](../design/Technical-Design.md) and [../design/Game-Flow.md](../design/Game-Flow.md) where they don’t conflict with the above (e.g. we can already use GameManager-style state and signals so Phase 2 is a natural extension).
