# Baseline Steps: Primitive → v3.0-Equivalent

**Document ID:** 1_03b

Phase 0 is built **incrementally**: each step adds (or changes) **one thing** and leaves the game **playable**. We start with a minimal main-scene game (launcher + flippers only), then add drain, walls, obstacles, rounds, and v3.0-style systems step by step.

**Principle:** After every step, the game runs and is playable; add a test where practical so later steps don’t break it.

---

## Step 0.1 – Primitive playable (launcher + flippers)

**Goal:** One main scene where the player can launch a ball and use flippers. No scoring, no rounds, no drain — just “ball in play.”

- **Main scene:** Playfield (simple board or background), **Launcher** (plunger/tap to launch), **Flippers** (left/right), **Ball** (spawn at launcher, physics).
- **Input:** Launch ball (e.g. Space / tap); left flipper (A/Left); right flipper (D/Right).
- **Physics:** Ball responds to gravity and bounces off flippers; no drain yet (ball can stay in play or fall off — acceptable for this step).
- **Deliverable:** Run game → launch ball → flip; game is playable in a minimal form.
- **Test (optional):** Launch ball, assert ball exists and is moving; or manual “ball launches and bounces on flippers.”

---

## Step 0.2 – Drain

**Goal:** Add drain so the ball is removed when it hits the drain; when no balls remain, trigger “round lost” (no rounds count yet — just one ball per “session” or single round).

- **Drain:** Area or body at bottom; on ball contact → remove ball.
- **Round-lost logic:** When no balls remain (ball count in Balls container = 0, or equivalent) → emit round_lost (or equivalent); can show a simple “round over” or restart ball at launcher for now.
- **Deliverable:** Ball drains → removed; no balls left → round-lost event; game stays playable (e.g. respawn one ball for next “round” or simple restart).
- **Test:** Ball enters drain → ball count becomes 0; round_lost (or game_over) fires.

---

## Step 0.3 – Walls and boundaries

**Goal:** Confine the ball to the playfield with walls/boundaries so it doesn’t leave the board (except via drain).

- **Walls / boundaries:** Static bodies or areas around the playfield edges (and optionally top/sides); ball bounces off.
- **Deliverable:** Ball stays on board except when it enters drain; no escape through sides/top.
- **Test:** Ball bounces off walls; only way to lose ball is drain (or explicit out-of-bounds if used).

---

## Step 0.4 – Obstacles / bumpers (basic scoring)

**Goal:** Add one or a few obstacles (bumpers or targets) that give points on hit; show score in UI. Use a **generic, reusable scoring component** so Phase 2 can reuse it inside zone nodes (e.g. AndroidBumperA) or replace instances without refactoring scoring logic.

- **Obstacles:** One or more bumpers/targets using a **single scene or script** with **configurable points** (e.g. 5k, 20k). Use `export var points` in the scoring component so each instance can set 5000, 20000, etc. Each instance calls GameManager.add_score(points) on ball contact. No zone containers yet — flat under Playfield.
- **Scoring:** GameManager holds **roundScore** (and optionally totalScore from the start); obstacles call add_score(points) → roundScore += points when status == playing; UI shows score. This matches target state shape and avoids a later split of "score" into roundScore/totalScore.
- **Deliverable:** Hitting an obstacle increases roundScore; score visible; game still playable with drain and flippers.
- **Test:** Hit obstacle N times → roundScore equals N × points per hit.

---

## Step 0.5 – Rounds and game over

**Goal:** Introduce rounds (e.g. 3); one ball per round; when ball drains, round ends; when rounds reach 0, game over. Use **target-shaped state** (see Alignment section below) so Phase 2 does not refactor GameManager.

- **State:** roundScore, totalScore, multiplier (1–6), rounds (3), **status** (waiting | playing | gameOver), **bonusHistory** (list). On round_lost: totalScore += roundScore × multiplier; roundScore = 0; multiplier = 1; rounds -= 1; if rounds == 0 then status = gameOver. Scoring only when status == playing.
- **Rounds:** e.g. rounds = 3; each round: spawn one ball at launcher; when ball drains, round_lost → rounds -= 1; if rounds > 0, spawn next ball; if rounds == 0, game_over.
- **Game over:** Show simple game-over state (e.g. “Game Over” + final score); option to replay (restart game).
- **Deliverable:** Full loop: launch → play → drain → round lost → next round or game over → replay.
- **Test:** Drain 3 times (3 rounds) → game_over; replay restarts rounds.

---

## Step 0.6 – Skill shot

**Goal:** One skill-shot target: active for a short window after launch; hitting it awards 1,000,000 points (target value); visual/audio feedback. Same node can be kept and repositioned in Phase 2.

- **Skill shot:** Target (area or body) that is “active” for 2–3 s after launch; if ball hits while active, call add_score(1000000); then inactive until next launch.
- **Feedback:** Simple popup or sound on hit.
- **Deliverable:** Skill shot works; game still playable with rounds, drain, obstacles.
- **Test:** Launch → hit skill shot within window → +1M roundScore; hit after window → no bonus.

---

## Step 0.7 – Multiplier

**Goal:** Multiplier value (1–6); increases on a **single pluggable trigger** (e.g. one target or placeholder ramp); reset to 1 on round lost; apply at round end. Phase 2 replaces trigger with SpaceshipRamp.

- **Multiplier:** State 1–6; **one** designated target or area calls GameManager.increase_multiplier() every 5 hits (cap 6); on round_lost set to 1; totalScore += roundScore × multiplier at round end.
- **UI:** Show current multiplier (e.g. “2x”).
- **Deliverable:** Multiplier increases and resets per round; round score multiplied at end of round.
- **Test:** Trigger N multiplier increases → multiplier = min(6, N+1); round lost → multiplier = 1; totalScore includes multiplier.

---

## Step 0.8 – Multiball

**Goal:** A way to get multiple balls in play (e.g. trigger a target); when all balls drain, round ends. Parameterize spawn position so Phase 2 can use DinoWalls. Multiball indicators optional.

- **Trigger:** e.g. hit a specific target X times or a “multiball” target → spawn extra ball(s). **Spawn API:** `spawn_bonus_ball(position: Vector2, impulse: Vector2 = Vector2.ZERO)`; default position = launcher; Phase 2 passes DinoWalls position and impulse for bonus ball.
- **Logic:** Multiple balls in play; round_lost only when all balls have drained.
- **Deliverable:** Can trigger multiball; multiple balls in play; round ends when all drain.
- **Test:** Trigger multiball → ball count > 1; drain all → round_lost once.

---

## Step 0.9 – Combo (optional; not in target)

**Goal:** Consecutive hits within a time window increase combo; combo affects score or multiplier; UI shows combo. Combo is **not** in target requirements or GDD; implement for v3.0 parity. Phase 2 does not show or use combo in I/O mode — hide combo from HUD in Classic I/O mode (e.g. visibility flag), do not remove combo code.

- **Combo:** Timer (e.g. 2 s); each hit resets timer; combo count increases; after timeout, combo resets. Option: score = base × (1 + combo) or similar.
- **UI:** Show combo count (e.g. “3x combo”).
- **Deliverable:** Combo builds and resets; score or multiplier reflects combo; game playable.
- **Test:** N hits within window → combo = N; after timeout → combo = 0.

---

## Step 0.10 – Polish (physics, animation, audio)

**Goal:** Align physics (flipper strength, bounce, friction), add simple animation (score popups, multiplier pulse) and audio (bumper, drain, launch, flipper, skill shot, multiball, combo).

- **Physics:** Tune flipper elasticity/strength, playfield friction/bounce per design or v3.0 reference.
- **Animation:** Score popups, multiplier change feedback, simple UI transitions.
- **Audio:** Events for bumper, drain, launch, flipper, skill shot, multiball, combo (pitch variation optional).
- **Deliverable:** Baseline feels and sounds like v3.0-equivalent; one main scene, one set of scripts; ready for Phase 1 tests.

---

## Summary table

| Step | Focus | Depends on | Playable after | Test idea |
|------|--------|------------|----------------|-----------|
| 0.1 | Launcher + flippers | — | Yes | Ball launches, bounces |
| 0.2 | Drain | 0.1 | Yes | Ball removed, round_lost |
| 0.3 | Walls | 0.1 | Yes | Ball confined |
| 0.4 | Obstacles + score | 0.1 | Yes | Hit → score |
| 0.5 | Rounds + game over | 0.2, 0.4 | Yes | 3 drains → game over |
| 0.6 | Skill shot | 0.5 | Yes | Hit in window → bonus |
| 0.7 | Multiplier | 0.5 | Yes | Multiplier up/down, applied |
| 0.8 | Multiball | 0.5 | Yes | Multiball trigger, all drain |
| 0.9 | Combo | 0.5 | Yes | Combo build/reset |
| 0.10 | Polish | 0.1–0.9 | Yes | Physics, audio, animation |

**Next:** Phase 1 adds tests for this baseline; Phase 2 ([FEATURE-STEPS.md](FEATURE-STEPS.md)) evolves to full requirements one item at a time.

---

## Baseline–target alignment (minimize Phase 2 rework)

- **0.4:** Use a **generic, reusable scoring component** (configurable points); GameManager uses **roundScore** (and totalScore when 0.5 lands). Phase 2 reuses the component in zones or swaps instances.
- **0.5:** Introduce full **target-shaped state**: roundScore, totalScore, multiplier (1–6), rounds (3), **status** (waiting | playing | gameOver), **bonusHistory**. Round lost: totalScore += roundScore × multiplier; roundScore = 0; multiplier = 1; rounds -= 1. Phase 2 (Step 2.2) then only aligns caps/signals.
- **0.6:** Skill shot awards **1M** from the start; same node can be repositioned in Phase 2.
- **0.7:** Use a **single pluggable** multiplier trigger (one target calling increase_multiplier() every 5 hits). Phase 2 replaces that source with SpaceshipRamp.
- **0.8:** **Parameterize** bonus-ball spawn (position + optional impulse). Phase 2 passes DinoWalls position and impulse for googleWord/dashNest.
- **0.9:** **Combo** is not in target/GDD. Implement for v3.0 parity; Phase 2 does not show or use combo in I/O — hide combo from HUD in Classic I/O mode (e.g. visibility flag), do not remove combo code.
- **Scene:** Keep playfield **flat** in baseline; Phase 2 adds zone containers and I/O components; generic obstacles are replaced or moved, not refactored in place.
