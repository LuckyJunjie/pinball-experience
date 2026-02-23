# Pinball Experience – Glossary

**Document ID:** 1_07

Key terms used across requirements, design, and plan documents. Use consistent terminology when implementing or discussing the game.

---

| Term | Definition |
|------|------------|
| **round** | One ball life; starts when ball spawns at launcher, ends when ball drains. A game typically has 3 rounds. |
| **roundScore** | Score accumulated during the current round; reset to 0 on round lost; multiplied by multiplier and added to totalScore at round end. |
| **totalScore** | Cumulative score across rounds; display score = roundScore + totalScore (capped at 9999999999). |
| **bonus** | A named achievement (e.g. googleWord, dashNest, sparkyTurboCharge, dinoChomp, androidSpaceship) recorded in bonusHistory. |
| **bonus ball** | Extra ball spawned after 5 s when googleWord or dashNest bonus triggers; spawns at DinoWalls with impulse toward center. |
| **player assets** | Coins, purchased upgrades, unlocks, level progress; persisted (e.g. `user://player_assets.json`) and shared across Classic and Level modes. |
| **bracket** | Score range (e.g. 0–100k, 100k–500k, 500k–1M, 1M–5M, 5M+) used by Score Range Board for rewards. |
| **status** | Session state: `waiting` \| `playing` \| `gameOver`. |
| **drain** | Area at bottom of playfield; ball contact removes ball; when no balls remain, triggers round lost. |
| **launcher** | Position where ball spawns at round start; includes plunger, flapper, launch ramp; user launches ball from here. |
| **multiball indicator** | One of four lights (A, B, C, D) that animate when a bonus ball is earned (Google Word or Dash Nest). |
| **multiplier** | Value 1–6 applied to roundScore at round end; increases every 5 ramp hits; resets to 1 on round lost. |
| **backbox** | UI area above playfield; displays leaderboard, initials form, game over info, share; state-driven. |
| **zone** | Playfield region (e.g. Android Acres, Dino Desert, Google Gallery) containing components and scoring logic. |

---

## References

- Requirements: [../requirements/Requirements.md](../requirements/Requirements.md) §0.1 Definitions
- Technical Design: [../design/Technical-Design.md](../design/Technical-Design.md)
- Game Design: [../design/GDD.md](../design/GDD.md)
