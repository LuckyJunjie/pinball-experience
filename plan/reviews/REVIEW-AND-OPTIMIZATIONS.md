# Pinball Experience – Document Review & Optimizations

This document reviews the **requirements**, **design**, and **iteration implementation** docs and suggests optimizations for each step. Use it to refine planning and reduce rework.

---

## 1. Requirements (Requirements.md)

### What's strong
- Clear state machine (§1) and system flow diagram (§0).
- Point values and trigger→points table (§2.4) are unambiguous.
- FR/NFR/TR numbering and JSON state shape support traceability and automation.
- Shopping, Score Range Board, and Level Mode are integrated with player assets.

### Optimizations

| Area | Suggestion | Benefit |
|------|------------|---------|
| **FR-1.3.4** | Explicitly state: "Bonus ball spawn uses **one** shared 5s timer; if a second bonus triggers before spawn, extend/reset or queue per design." | Avoids conflicting timers (e.g. Google Word + Dash Nest in same round). |
| **§2.6 Bonuses** | Add a single table: Bonus ID → trigger condition → effect (points/bonus ball). | One place for all five bonuses; easier to implement and test. |
| **NFR-2.1** | Specify "60 FPS" (or your target) explicitly. | Matches FEATURE-STEPS 2.30 and gives a clear performance bar. |
| **Score cap** | FR-1.2.2 already says 9999999999; ensure TR-3.4 `scored` and display_score are defined as capped in one place. | Prevents overflow and inconsistent UI. |
| **Level Mode** | Add one sentence: "Level data format (e.g. JSON schema or Godot resource) is defined in Technical Design." | Links requirements to implementation. |

### Optional
- Add a short "Definitions" section: *round*, *bonus*, *player assets*, *bracket* so all docs use the same terms.
- Consider a "Testability" note: "Each FR is verifiable by automated test, manual checklist, or inspection."

---

## 2. Design Documents

### 2.1 Technical-Design.md

**Strengths:** Layer diagram, Flutter→Godot mapping, scene structure with visible-items index, signals summary.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **Backbox location** | Scene structure lists Backbox under Playfield; UI-Design uses a separate layer. Add one line: "Backbox can be CanvasLayer above playfield or a child of Playfield in UI space; position per UI-Design." | Clarifies where Backbox lives in the node tree. |
| **PlayerAssets** | Name the single source of truth: "PlayerAssets (or SaveManager) is the only writer for coins, upgrades, level progress; Store and Level only read/write via it." | Prevents duplicate persistence logic. |
| **File layout** | Add "ScoreRangeBoardManager" to the suggested file list (it's optional in §6); mention where level layout JSON/resources live (e.g. `resources/levels/`). | Easier onboarding and file discovery. |
| **Signals** | Add `bracket_reached(score_bracket)` or similar if Score Range Board notifies mid-game; document in Signals table. | Aligns with FR-6.3 and FEATURE-STEPS 2.38. |

### 2.2 UI-Design.md

**Strengths:** Design evolution critique, principles, per-screen layout, implementation checklist, Godot node examples.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **§10.2 HUD** | Add "Multiball indicators" to the HUD node structure (four TextureRects or similar under TopBar or a small container). | Matches §5 and ensures they're not forgotten in implementation. |
| **Checklist** | Add: "Connect Score Range Board to GameManager/PlayerAssets for current score and bracket; connect bracket_reached to notification." | Completes the Score Range Board integration. |
| **Main menu** | Clarify: "Play = Classic mode; label may be 'Play' or 'Classic' per requirements." | Avoids UI copy ambiguity. |

### 2.3 Game-Flow.md

**Strengths:** Mirrors requirements flow; state transition table; round life cycle; camera table.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **§4.4 Events** | Add "BracketReached(bracket)" if Score Range Board triggers in-game notification; effect: "show notification; queue reward for post-game." | Keeps flow doc in sync with FR-6.3. |
| **LevelSelect** | One line: "LevelSelect may show CharacterSelect before LevelPlaying, or skip to LevelPlaying; choose one and document in UI-Design." | Single place for that product decision. |

---

## 3. Iteration Plan (plan/)

### 3.1 README.md

**Strengths:** Purpose, source/target, strategy (one codebase), document index, how to use.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **Order** | Add: "Recommended order: Phase 0 → Phase 1 → Phase 2. Do not start Phase 2 before Phase 1 tests exist." | Prevents skipping the safety net. |
| **Definition of done** | Add one line: "A step is done when: game runs, new behavior works, and any new test is added and passing." | Clear DoD for each step. |

### 3.2 ITERATION-PLAN.md

**Strengths:** Phase 0/1/2 goals, legacy references, summary table.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **Phase 1** | Add: "Prefer at least: one test for round_lost/game_over, one for scoring, one for multiplier, one for bonus ball spawn (if applicable)." | Gives a minimal test checklist. |
| **Phase 2** | Add: "If a step is too large, split into sub-steps (e.g. 2.26a Backbox layout, 2.26b Leaderboard data, 2.26c Initials submit). Keep one item per sub-step." | Supports splitting without losing the one-item-per-step rule. |

### 3.3 BASELINE-V3-SCOPE.md

**Strengths:** Alignment with target, legacy references, "v3.0-equivalent" definition, out-of-scope list.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **Deliverable** | Add: "Phase 0 is also done when BASELINE-STEPS 0.1–0.10 are complete and playable in order." | Ties deliverable to the step list. |
| **§4 Out of scope** | Add: "Shop, currency, battle pass" → "Shop and currency are in scope for Phase 2 (FEATURE-STEPS 2.31–2.37); battle pass is out of scope." | Aligns with requirements (Store is in scope). |

### 3.4 BASELINE-STEPS.md

**Strengths:** One thing per step, playable after each, test ideas, baseline–target alignment section.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **0.2 Drain** | Clarify: "When no balls remain" means "ball count in Balls container = 0 (or equivalent)." | Unambiguous for multiball (0.8). |
| **0.4 Obstacles** | Add: "Use export var points in the scoring component so each instance can set 5000, 20000, etc." | Makes "configurable points" implementation-ready. |
| **0.8 Multiball** | Add: "Spawn API: spawn_bonus_ball(position: Vector2, impulse: Vector2 = Vector2.ZERO). Default position = launcher; Phase 2 passes DinoWalls position." | Matches FEATURE-STEPS 2.10/2.17. |
| **0.9 Combo** | Add: "Combo is not used in Phase 2 I/O rules; hide combo from HUD in Classic I/O mode (e.g. visibility flag), do not remove combo code." | Reduces risk of deleting code. |
| **Summary table** | Add a "Depends on" column (e.g. 0.5 depends on 0.2, 0.4; 0.7 depends on 0.5). | Quick dependency check. |

### 3.5 FEATURE-STEPS.md

**Strengths:** One item per step, refs to FR/TR, test per step, dependency order summary, assumptions about baseline.

**Optimizations:**

| Area | Suggestion | Benefit |
|------|------------|---------|
| **Step 2.2** | Add: "Display score = roundScore + totalScore capped at 9999999999 (per FR-1.2.2)." | Explicit cap in implementation steps. |
| **Step 2.10** | Add: "If both googleWord and dashNest trigger before the 5s spawn, use one timer and one spawn (no double spawn); document behavior in Game-Flow or GDD." | Prevents duplicate bonus balls. |
| **Step 2.11 vs 2.10** | Consider merging 2.10 and 2.11 into one step: "Bonus ball (5s) from Google Word / Dash Nest + multiball indicators (4)." Rationale: indicators are meaningless without bonus ball. Alternatively, keep 2.11 but note "can be implemented in same PR as 2.10." | Fewer steps or clearer grouping. |
| **Step 2.30** | Add: "60 FPS" explicitly and "input latency &lt; 100 ms (or measure and document)." | Matches NFRs. |
| **Step 2.31** | Add: "Use a single save file or key (e.g. user://player_assets.json) so Classic and Level read/write the same data." | Single persistence contract. |
| **Dependency summary** | Add: "2.31 before 2.32, 2.33, 2.39 (player assets and persistence are required for Store and Level)." | Already implied; making it explicit helps. |
| **Test format** | Optionally standardize tests as: "Given … When … Then …" for a few critical steps (e.g. 2.2, 2.5, 2.26) as examples. | Improves test clarity over time. |

---

## 4. Cross-Cutting Recommendations

1. **Traceability:** Keep "Refs: FR-x.y" in FEATURE-STEPS and BASELINE-STEPS; add "Implements: FR-x.y" in Technical-Design for major components (GameManager, Backbox, Store, LevelManager, Score Range Board).
2. **Glossary:** Add a one-page `GLOSSARY.md` under `plan/` or `design/` with: round, roundScore, totalScore, bonus, bonus ball, player assets, bracket, status, drain, launcher, multiball indicator. Link from README and Requirements.
3. **Definition of done (per step):** "Game runs; new item works; test added and passing; no regression in existing tests."
4. **Phase 1 scope:** Document "Minimum test set" in ITERATION-PLAN or BASELINE-STEPS: e.g. round_lost, scoring, multiplier, bonus ball, game_over. Expand in Phase 2 per FEATURE-STEPS.

---

## 5. Summary Table

| Document | Priority optimizations |
|----------|-------------------------|
| **Requirements** | Bonus table; 60 FPS in NFR; bonus-ball timer rule (single timer). |
| **Technical-Design** | Backbox placement; PlayerAssets as single writer; Score Range Board signal. |
| **UI-Design** | Multiball in HUD node structure; Score Range Board checklist item. |
| **Game-Flow** | BracketReached event; LevelSelect → CharacterSelect vs skip. |
| **plan/README** | Phase order; definition of done per step. |
| **ITERATION-PLAN** | Phase 1 minimal tests; splitting rule for large steps. |
| **BASELINE-V3-SCOPE** | Deliverable = steps 0.1–0.10; Shop in Phase 2 (not "excluded"). |
| **BASELINE-STEPS** | 0.2 "no balls" definition; 0.8 spawn API signature; dependency column. |
| **FEATURE-STEPS** | 2.10 single timer; 2.30 60 FPS; 2.31 single save key; optional 2.10+2.11 merge. |

Applying the high-priority items above will reduce ambiguity and rework while keeping your one-item-per-step and playable-after-each-step discipline.
