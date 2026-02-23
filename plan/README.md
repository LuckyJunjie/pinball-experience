# Pinball Experience – Iteration Plan

**Document ID:** 1_01

This folder describes how we iterate from the **legacy project** to the **target** (requirements and design), in a single codebase, without keeping separate version branches.

## Purpose

- **Source:** Legacy project at [https://github.com/LuckyJunjie/pin-ball](https://github.com/LuckyJunjie/pin-ball) (archived v3.0 that worked, plus v4.0 in root).
- **Target:** [../requirements/Requirements.md](../requirements/Requirements.md) and [../design/](../design/) (I/O Pinball–aligned).
- **Strategy:** One codebase in this repo; we implement step by step and update the same code (no archived version folders in this project).

## Documents

| ID | Document | Description |
|----|----------|-------------|
| 1_02 | [ITERATION-PLAN.md](ITERATION-PLAN.md) | Main plan: Phase 0 (baseline), Phase 1 (tests), Phase 2 (feature steps to target). |
| 1_03 | [BASELINE-V3-SCOPE.md](BASELINE-V3-SCOPE.md) | What “v3.0-equivalent baseline” means; reference to legacy v3.0 design and code. |
| 1_03b | [BASELINE-STEPS.md](BASELINE-STEPS.md) | Phase 0 **incremental steps**: primitive (launcher + flippers) → drain → walls → obstacles → rounds → skill shot → multiplier → multiball → combo → polish. Each step playable + test. |
| 1_04 | [FEATURE-STEPS.md](FEATURE-STEPS.md) | Phase 2 **one item per step**: playfield, backbox, **Store** (2.31–2.37), **Score Range Board** (2.38), **Level Mode** (2.39–2.44); playable + test after every step. |
| **1 – Reviews** | | |
| 1_05 | [reviews/REVIEW-AND-OPTIMIZATIONS.md](reviews/REVIEW-AND-OPTIMIZATIONS.md) | Document review and suggested optimizations for requirements, design, and each plan step. |
| 1_06 | [reviews/COMPREHENSIVE-DOCUMENT-REVIEW.md](reviews/COMPREHENSIVE-DOCUMENT-REVIEW.md) | Full review: consistency, feasibility, AI/Agent-friendliness; builds on REVIEW-AND-OPTIMIZATIONS. |
| 1_07 | [GLOSSARY.md](GLOSSARY.md) | Key terms (round, bonus, player assets, etc.); link from Requirements §0.1. |

## How to use

1. **Phase 0:** Build the baseline incrementally using [BASELINE-STEPS.md](BASELINE-STEPS.md): start with a primitive playable main scene (launcher + flippers), then add drain, walls, obstacles, rounds, and v3.0-style systems step by step. After each step the game must stay playable; add a test where practical.
2. **Phase 1:** Add tests for that baseline so we can refactor and extend safely.
3. **Phase 2:** Implement [FEATURE-STEPS.md](FEATURE-STEPS.md) **one item per step** (e.g. first time we introduce the ramp, that step only adds the ramp and its test). After each step the game stays runnable and tests pass.

**Recommended order:** Phase 0 → Phase 1 → Phase 2. Do not start Phase 2 before Phase 1 tests exist.

**Definition of done (per step):** A step is done when the game runs, the new behavior works, and any new test for that step is added and passing.

All work happens in the main project (`scripts/`, `scenes/`, `assets/`); we do not copy or maintain versioned copies of code.
