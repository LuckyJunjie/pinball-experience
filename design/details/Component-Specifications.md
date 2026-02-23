# Pinball Game – Component Specifications

**Document ID:** 4_01

## Overview

This document specifies each playfield zone and component for the I/O Pinball–inspired clone. Behaviors (scoring, bonus, multiplier, ball spawn) are mapped to Godot nodes and scripts. Flutter references: [../flutter-reference/FLUTTER-PINBALL-PARSING.md](../flutter-reference/FLUTTER-PINBALL-PARSING.md).

---

## 1. Launcher

**Flutter:** `lib/game/components/launcher.dart` – LaunchRamp, Flapper, Plunger(41, 43.7), RocketSpriteComponent(42.8, 62.3).

**Godot:**
- **Scene/node:** Launcher (Node2D) with children: LaunchRamp (collision/visual), Flapper, Plunger (RigidBody2D or kinematic), RocketSprite (Sprite2D).
- **Position:** Plunger at world (41, 43.7); Rocket at (42.8, 62.3) in Flutter coords; scale to Godot world as needed.
- **Behavior:** Ball spawns at plunger position on round start and after round lost. User action (tap/button) launches ball; plunger/rocket visual feedback.
- **Script:** Launcher.gd – exposes spawn position; handles launch input and notifies GameManager when ball is launched.

---

## 2. Drain

**Flutter:** `lib/game/components/drain/drain.dart`, `behaviors/draining_behavior.dart` – edge at board bottom, sensor; on Ball contact remove ball, if no balls left add RoundLost.

**Godot:**
- **Scene/node:** Drain (Area2D) with CollisionShape2D covering bottom edge of playfield (BoardDimensions.bounds.bottomLeft to bottomRight equivalent).
- **Behavior:** body_entered(Ball) → remove ball from tree; count balls in Balls container; if 0 → call GameManager.on_round_lost().
- **Script:** Drain.gd – connect body_entered to handler; get parent or autoload GameManager; on_round_lost().

---

## 3. Bottom Group

**Flutter:** `lib/game/components/bottom_group.dart` – left/right sides: Flipper, Baseboard, Kicker each. Flipper position (11.6*direction + centerXAdjustment, 43.6); Kicker 5k + KickerNoiseBehavior on bouncy_edge.

**Godot:**
- **Scene/node:** BottomGroup (Node2D) with FlipperLeft, FlipperRight, BaseboardLeft, BaseboardRight, KickerLeft, KickerRight.
- **Flippers:** Reuse Flipper.gd; left input = left flipper, right input = right flipper; on mobile left half of screen = left flipper, right half = right flipper.
- **Kickers:** Area2D or StaticBody2D with collision; on ball contact GameManager.add_score(5000); play kicker sound.
- **Script:** BottomGroup can be structural only; Flipper and Kicker scripts handle scoring.

---

## 4. Skill Shot

**Flutter:** `lib/game/pinball_game.dart` – SkillShot with ScoringContactBehavior(Points.oneMillion), RolloverNoiseBehavior.

**Godot:**
- **Scene/node:** SkillShot (Area2D) with CollisionShape2D covering rollover/target zone.
- **Behavior:** body_entered(Ball) → GameManager.add_score(1000000); play rollover sound.
- **Script:** SkillShot.gd – on body_entered, if body is Ball then add_score(1000000) and play sound.

---

## 5. Google Gallery

**Flutter:** `lib/game/components/google_gallery/google_gallery.dart` – GoogleWord(position -4.45, 1.8), GoogleRollover left/right 5k each; GoogleWordBonusBehavior when all letters lit → bonus + bonus ball + reset letters.

**Godot:**
- **Scene/node:** GoogleGallery (Node2D) with GoogleWord (sprite/letters), GoogleRolloverLeft (Area2D), GoogleRolloverRight (Area2D).
- **Rollovers:** Each body_entered(Ball) → add_score(5000), rollover sound, mark letter or segment lit (G, o, o, g, l, e).
- **Word:** Track which letters are lit; when all lit → GameManager.add_bonus("googleWord"), reset letters, trigger bonus ball (5s timer in GameManager).
- **Script:** GoogleGallery.gd – manage letter state; on all lit call add_bonus and request bonus ball spawn.

---

## 6. Multipliers

**Flutter:** `lib/game/components/multipliers/multipliers.dart` – Multiplier x2 (–19.6, –2), x3 (12.8, –9.4), x4 (–0.3, –21.2), x5 (–8.9, –28), x6 (9.8, –30.7); MultipliersBehavior lights next on contact and sends MultiplierIncreased.

**Godot:**
- **Scene/node:** Multipliers (Node2D) with five Multiplier targets (Area2D or collision bodies) at positions above (scale to Godot world).
- **Behavior:** Multiplier increase is driven by **ramp** (every 5 ramp hits), not by these targets in Flutter game logic; these are **visual indicators** (x2–x6 lit in sequence). On ball contact with next unlit target, light it and optionally emit multiplier_increased if tied to ramp. (Flutter: ramp drives multiplier; multiplier components are lit by MultiplierCubit/state.) So: ramp zone sends increase_multiplier every 5 hits; Multipliers node just displays current multiplier (1–6) or lights 1..multiplier.
- **Script:** Multipliers.gd – listen to GameManager.multiplier_increased; update visual (e.g. sprites for x2–x6).

---

## 7. Multiballs (Indicators)

**Flutter:** `lib/game/components/multiballs/multiballs.dart` – Multiball.a(), .b(), .c(), .d(); MultiballsBehavior when last bonus is dashNest or googleWord animates (blinks) indicators.

**Godot:**
- **Scene/node:** Multiballs (Node2D) with four indicator sprites/nodes (e.g. MultiballA, B, C, D).
- **Behavior:** When GameManager emits bonus_activated("googleWord") or bonus_activated("dashNest"), animate indicators (blink). No ball spawning here; bonus ball is spawned by GameManager after 5s.
- **Script:** Multiballs.gd – connect to bonus_activated; if bonus is googleWord or dashNest, start blink animation on all four.

---

## 8. Android Acres

**Flutter:** `lib/game/components/android_acres/android_acres.dart` – SpaceshipRamp (5k shot, 1M bonus, progress, multiplier every 5 hits, reset), SpaceshipRail, AndroidBumper A/B/COW (20k), AndroidSpaceship + Animatronic (200k), AndroidSpaceshipBonusBehavior.

**Godot:**
- **Scene/node:** AndroidAcres (Node2D) with SpaceshipRamp (Area2D or ramp body), SpaceshipRail (visual/collision), AndroidBumperA, B, Cow (bumpers), AndroidSpaceship (target), AndroidAnimatronic (visual).
- **Ramp:** On ball entry: add_score(5000); increment ramp hit count; every 5 hits call GameManager.increase_multiplier() (if multiplier < 6); if "ramp bonus" condition (e.g. N hits in round) add_score(1000000) and reset progress.
- **Bumpers:** Each bumper ball contact → add_score(20000), bumper sound.
- **Spaceship target:** Ball enters sensor → add_score(200000), GameManager.add_bonus("androidSpaceship").
- **Script:** AndroidAcres.gd – ramp hit counter; call add_score, increase_multiplier, add_bonus as above.

---

## 9. Dino Desert

**Flutter:** `lib/game/components/dino_desert/dino_desert.dart` – ChromeDino(12.2, -6.9) 200k inside_mouth, ChromeDinoBonusBehavior; DinoWalls, Slingshots; _BarrierBehindDino.

**Godot:**
- **Scene/node:** DinoDesert (Node2D) with ChromeDino (sprite + mouth Area2D), DinoWalls (collision), Slingshots (left/right), barrier behind dino (StaticBody2D).
- **Dino mouth:** body_entered(Ball) on mouth sensor → add_score(200000), GameManager.add_bonus("dinoChomp").
- **DinoWalls:** Used as spawn position for bonus ball (e.g. 29.2, -24.5) with impulse (-40, 0); GameManager spawns ball there after 5s when Google Word or Dash Nest bonus.
- **Slingshots:** Visual/collision; optional slingshot behavior (bounce).
- **Script:** DinoDesert.gd – mouth contact → add_score(200000), add_bonus("dinoChomp"). Bonus ball spawn is in GameManager.

---

## 10. Flutter Forest

**Flutter:** `lib/game/components/flutter_forest/flutter_forest.dart` – Signpost 5k, DashBumper main 200k/A/B 20k, DashAnimatronic; FlutterForestBonusBehavior when all dash bumpers lit → dashNest bonus + bonus ball.

**Godot:**
- **Scene/node:** FlutterForest (Node2D) with Signpost (Area2D 5k), DashBumperMain (200k), DashBumperA, DashBumperB (20k each), DashAnimatronic (visual).
- **Signpost:** body_entered(Ball) → add_score(5000), bumper sound.
- **Dash bumpers:** Each contact → add_score(20000 or 200000 for main); track "lit" state; when all three lit → GameManager.add_bonus("dashNest"), trigger bonus ball (5s in GameManager), reset lit state.
- **Script:** FlutterForest.gd – track bumper lit; on all lit add_bonus("dashNest") and request bonus ball.

---

## 11. Sparky Scorch

**Flutter:** `lib/game/components/sparky_scorch/sparky_scorch.dart` – SparkyBumper A/B/C (20k), SparkyAnimatronic, SparkyComputer (200k turbo_charge_sensor), SparkyComputerBonusBehavior.

**Godot:**
- **Scene/node:** SparkyScorch (Node2D) with SparkyBumperA, B, C (20k each), SparkyAnimatronic (visual), SparkyComputer (Area2D sensor).
- **Bumpers:** body_entered(Ball) → add_score(20000), bumper sound.
- **Computer sensor:** body_entered(Ball) → add_score(200000), GameManager.add_bonus("sparkyTurboCharge").
- **Script:** SparkyScorch.gd – forward contacts to add_score and add_bonus.

---

## 12. Backbox

**Flutter:** `lib/game/components/backbox/backbox.dart` – position (0, -87); displays: Loading, Leaderboard, InitialsInput, InitialsSuccess/Failure, GameOverInfo, Share.

**Godot:**
- **Scene/node:** Backbox (CanvasLayer or Node2D above playfield) with child "Display" that is swapped per state: LoadingDisplay, LeaderboardDisplay, InitialsInputDisplay, GameOverInfoDisplay, ShareDisplay, FailureDisplay.
- **Behavior:** BackboxManager state drives which display is visible. On game over, request_initials(score, character); user submits → save to local leaderboard → show game over info → share option.
- **Script:** Backbox.gd – listens to BackboxManager.state_changed; shows/hides or instantiates correct display. BackboxManager handles load_leaderboard (local), submit_initials (save), request_share (copy or native).

---

## 13. Ball

**Flutter:** Ball from pinball_components; spawn at plunger; asset from CharacterThemeCubit (ball.keyName).

**Godot:**
- Reuse Ball.tscn/Ball.gd where possible. Spawn at Launcher spawn position; add to Balls container. Character theme selects ball sprite (Sparky, Dino, Dash, Android).
- **Bonus ball:** Same Ball scene; spawn at DinoWalls position (29.2, -24.5) with initial velocity/impulse (-40, 0) (scale to Godot units).

---

## 14. Behaviors Summary

| Behavior | Flutter | Godot |
|----------|---------|-------|
| Scoring | ScoringContactBehavior(points) | Zone script calls GameManager.add_score(points) |
| Bonus | BonusActivated(bonus) | Zone script calls GameManager.add_bonus(bonus) |
| Multiplier (ramp) | RampMultiplierBehavior every 5 hits | AndroidAcres ramp counter → increase_multiplier() |
| Bonus ball | BonusBallSpawningBehavior 5s, spawn at DinoWalls | GameManager 5s timer → spawn Ball at (29.2,-24.5) with impulse |
| Round lost | DrainingBehavior → RoundLost | Drain body_entered → if no balls → on_round_lost() |
| Ball spawn (round) | BallSpawningBehavior on round start/lost | GameManager on_round_lost (if rounds>0) or game_started → Launcher spawn position |

---

## 15. Reference

- Flutter paths: [../flutter-reference/FLUTTER-PINBALL-PARSING.md](../flutter-reference/FLUTTER-PINBALL-PARSING.md) sections 4–4.12.
- Technical design: [../Technical-Design.md](../Technical-Design.md).
