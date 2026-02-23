# Pinball Experience – Iteration Plan

**Document ID:** 1_02

## Overview

We iterate **from the legacy project’s archived v3.0 (working)** **to the target** (current [requirements](../requirements/Requirements.md) and [design](../design/)), in **one codebase**. We do not keep separate version branches or archived code in this repo; we implement and update the same code step by step.

---

## Legacy reference

- **Legacy project:** [https://github.com/LuckyJunjie/pin-ball](https://github.com/LuckyJunjie/pin-ball)
- **Archived v3.0:** [archived/v3.0](https://github.com/LuckyJunjie/pin-ball/tree/main/archived/v3.0) (design, assets) and [archived/legacy](https://github.com/LuckyJunjie/pin-ball/tree/main/archived/legacy) (v1–v3 scenes/scripts). The v3.0 *implementation* (SkillShot, MultiballManager, MultiplierSystem, ComboSystem, AnimationManager, ParticleManager, and changes to GameManager, Flipper, Ball, Obstacle, UI, SoundManager) lived in the **root** of the repo and was the “working” version before v4.0.
- **Use of legacy:** Reference only (design docs, code structure, behavior). We implement in **pinball-experience** from scratch or by selective copy, then evolve the same code toward the target.

---

## Phase 0 – Baseline (v3.0-equivalent)

**Goal:** A working game in this repo that matches the **scope and behavior** of the legacy archived v3.0 (the version that worked).

**Approach:** Build **incrementally** so the game is **playable after every step**. Start with a **primitive main scene** (launcher + flippers only), then add **drain**, **walls**, **obstacles**, **rounds**, and v3.0-style systems (skill shot, multiplier, multiball, combo, polish) **step by step**. Each step adds or changes one thing and keeps the game runnable; add a test where practical.

**Outcome:**

- One playable build: launch → play → rounds/ball life → drain → game over (or equivalent loop).
- Core systems: playfield, ball, flippers, launcher, drain, scoring, rounds (or ball count).
- v3.0-style systems: skill shot, multiplier (1–6), multiball, combo, and enhanced physics/polish (animation, particles, audio) where they align with v3.0.
- No requirement yet to match I/O Pinball layout (zones can be simplified or placeholder).

**Details:** Scope in [BASELINE-V3-SCOPE.md](BASELINE-V3-SCOPE.md); **ordered steps** in [BASELINE-STEPS.md](BASELINE-STEPS.md) (0.1 primitive playable → 0.2 drain → 0.3 walls → 0.4 obstacles → … → 0.10 polish).

**Principle:** Implement or port behavior here; do not copy versioned folders. Prefer a single Main (or equivalent) scene and one set of scripts that we will later extend.

---

## Phase 1 – Tests for baseline

**Goal:** Automated tests for the Phase 0 baseline so we can change code safely.

**Outcome:**

- Test suite (unit and/or integration) that runs in CI or locally (e.g. Godot test framework or script runner).
- Coverage of: game state (score, rounds, multiplier), drain/round-lost, skill shot, multiplier, multiball, combo (if present), and critical UI/flow.
- Documented how to run tests and what they cover.

**Minimum test set** (prefer at least): one test for round_lost/game_over; one for scoring (add_score → roundScore); one for multiplier increase and reset; one for bonus ball spawn (if applicable).

**Minimum test set (prefer at least):** one test for round_lost/game_over; one for scoring (add_score → roundScore); one for multiplier increase and reset; one for bonus ball spawn (if applicable).

**Principle:** Tests protect the baseline; every Phase 2 step should keep or extend tests, not remove them.

---

## Phase 2 – Feature steps to target

**Goal:** Evolve the baseline to full requirements and design by introducing or changing **one item at a time** (e.g. “first time we introduce ramp” = one step that only adds the ramp and its test). Every step keeps the game **playable** and should be covered by a **test**.

**Outcome:**

- Start flow: initial → character select → how to play → play (and replay); main menu with **Play**, **Levels**, **Store**.
- Game state and scoring aligned with requirements: roundScore, totalScore, multiplier 1–6 (ramp-driven), rounds 3, bonusHistory, status (waiting | playing | gameOver).
- All playfield zones and components from requirements, **each added in its own step**: e.g. ramp alone, then rail, then Android bumpers, then AndroidSpaceship; Google rollovers, then Google Word, then bonus ball; etc.
- Bonuses, backbox, character themes, camera and HUD per requirements.
- **Shopping & Progression:** Store (main menu + post-game), coins, upgradable items, **player assets** persisted and shared across Classic and Level. See [FEATURE-STEPS.md](FEATURE-STEPS.md) steps 2.31–2.37.
- **Score Range Board:** Score brackets, rewards, progress display; see step 2.38.
- **Level Mode:** Level Select, level playfields with custom layouts and objectives, same physics and player assets as Classic; level progress and rewards; see steps 2.39–2.44.

**Order of work:** See [FEATURE-STEPS.md](FEATURE-STEPS.md). Each step = **one mechanism or one component** + test; we update the same codebase after each step. If a step is too large, split into sub-steps (e.g. 2.26a Backbox layout, 2.26b Leaderboard data, 2.26c Initials submit); keep one item per sub-step. If a step is too large, split into sub-steps (e.g. 2.26a Backbox layout, 2.26b Leaderboard data, 2.26c Initials submit); keep one item per sub-step.

**Principle:** No separate “v3” vs “target” branches in this repo. One main line of development; each step keeps the game runnable and tests passing.

---

## Summary

| Phase | Goal | Deliverable |
|-------|------|-------------|
| **0** | v3.0-equivalent working game | Incremental steps: primitive (launcher + flippers) → drain → walls → obstacles → rounds → skill shot → multiplier → multiball → combo → polish. See [BASELINE-STEPS.md](BASELINE-STEPS.md). |
| **1** | Safety net for changes | Test suite for baseline; docs for running tests |
| **2** | Full requirements/design | One-item-per-step from [FEATURE-STEPS.md](FEATURE-STEPS.md) (playfield, backbox, **Store**, **Score Range Board**, **Level Mode**); each step playable + test; single codebase |

All implementation and iteration happen in **this project** (`pinball-experience`). The legacy project is used only as reference.
