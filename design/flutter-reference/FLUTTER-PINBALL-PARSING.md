# Flutter I/O Pinball – Parsing Summary

**Document ID:** 4_05

This document lists components, state machines, playfield hierarchy, scoring, and references to the open-source Flutter pinball project at `/Users/junjiepan/github/pinball` (I/O Pinball, Google I/O 2022).

---

## 1. Repository Structure

| Path | Purpose |
|------|---------|
| `lib/` | App and game logic (68 Dart files) |
| `lib/app/` | App widget, providers |
| `lib/game/` | Game bloc, pinball game, behaviors, components |
| `lib/start_game/` | Start flow (play → character → how to play → play) |
| `lib/select_character/` | Character theme selection |
| `lib/assets_manager/` | Asset loading before game |
| `lib/how_to_play/` | How to play dialog |
| `lib/more_information/` | Info dialog (game over) |
| `lib/leaderboard/` | Leaderboard entry model |
| `packages/pinball_components/` | Physical components (ball, flipper, bumper, etc.) |
| `packages/pinball_flame/` | Flame/Forge2D helpers, layers, shapes |
| `packages/pinball_theme/` | Character themes (Sparky, Dino, Dash, Android) |
| `packages/pinball_audio/` | Audio player, sounds |
| `packages/pinball_ui/` | UI widgets |
| `packages/leaderboard_repository/` | Firestore leaderboard |
| `packages/share_repository/` | Share text/URL |
| `packages/authentication_repository/` | Firebase anonymous auth |
| `packages/platform_helper/` | Mobile vs desktop |
| `assets/images/` | Images (bonus_animation, components, loading_game, score) |

---

## 2. State Machines

### 2.1 StartGameBloc

**File:** `lib/start_game/bloc/start_game_bloc.dart`, `start_game_state.dart`, `start_game_event.dart`

| State | Event | Next state |
|-------|--------|------------|
| initial | PlayTapped | selectCharacter |
| selectCharacter | CharacterSelected | howToPlay |
| howToPlay | HowToPlayFinished | play |
| play | (none) | — |
| (any) | ReplayTapped | selectCharacter |

**States:** `initial`, `selectCharacter`, `howToPlay`, `play`.

### 2.2 GameBloc

**File:** `lib/game/bloc/game_bloc.dart`, `game_state.dart`, `game_event.dart`

| Event | Effect |
|-------|--------|
| GameStarted | status = playing |
| RoundLost | totalScore += roundScore * multiplier (capped 9999999999); roundScore = 0; multiplier = 1; rounds -= 1; if rounds == 0 then status = gameOver |
| Scored | roundScore += points (only when playing) |
| MultiplierIncreased | multiplier = min(multiplier + 1, 6) (only when playing) |
| BonusActivated(bonus) | bonusHistory += bonus |
| GameOver | status = gameOver |

**State:** `roundScore`, `totalScore`, `multiplier` (1–6), `rounds` (initial 3), `bonusHistory` (list of GameBonus), `status` (waiting | playing | gameOver).

**Display score:** `roundScore + totalScore`. **Max score:** 9999999999.

### 2.3 BackboxBloc

**File:** `lib/game/components/backbox/bloc/backbox_bloc.dart`, `backbox_state.dart`, `backbox_event.dart`

| State | Trigger |
|-------|---------|
| LeaderboardSuccessState(entries) | Initial load with prefetched entries |
| LeaderboardFailureState | Initial load failed or no entries |
| LoadingState | Submitting initials |
| InitialsFormState(score, character) | Game over: request initials |
| InitialsSuccessState(score) | Initials submitted successfully |
| InitialsFailureState(score, character) | Submit failed |
| ShareState(score) | User tapped share |

**Events:** PlayerInitialsRequested, PlayerInitialsSubmitted, ShareScoreRequested, LeaderboardRequested.

---

## 3. Playfield Hierarchy

**File:** `lib/game/pinball_game.dart` – `onLoad()` adds children under a ZCanvasComponent:

1. **ArcadeBackground** (desktop only)
2. **BoardBackgroundSpriteComponent**
3. **Boundaries**
4. **Backbox** – position (0, -87), anchor bottomCenter
5. **GoogleGallery**
6. **Multipliers**
7. **Multiballs**
8. **SkillShot** – children: ScoringContactBehavior(Points.oneMillion), RolloverNoiseBehavior
9. **AndroidAcres**
10. **DinoDesert**
11. **FlutterForest**
12. **SparkyScorch**
13. **Drain**
14. **BottomGroup** – left/right sides: Flipper, Baseboard, Kicker each side
15. **Launcher** – LaunchRamp, Flapper, Plunger(41, 43.7), RocketSpriteComponent(42.8, 62.3)

**Board dimensions:** `packages/pinball_components/lib/src/components/board_dimensions.dart` – size (101.6, 143.8), bounds from center, perspectiveAngle, perspectiveShrinkFactor.

---

## 4. Components and Behaviors

### 4.1 Launcher

**File:** `lib/game/components/launcher.dart`

- LaunchRamp, Flapper, Plunger (initialPosition 41, 43.7), RocketSpriteComponent (42.8, 62.3).

### 4.2 Drain

**File:** `lib/game/components/drain/drain.dart`, `behaviors/draining_behavior.dart`

- Body: edge at board bottom (BoardDimensions.bounds.bottomLeft to bottomRight), sensor.
- DrainingBehavior: on Ball contact, remove ball; if no balls left, GameBloc.add(RoundLost).

### 4.3 BottomGroup

**File:** `lib/game/components/bottom_group.dart`

- Left/right sides. Each side: Flipper (position (11.6*direction + centerXAdjustment, 43.6)), Baseboard, Kicker (ScoringContactBehavior 5k, KickerNoiseBehavior on 'bouncy_edge'; position (22.44*direction + centerXAdjustment, 25.1)).

### 4.4 SkillShot

**File:** `lib/game/pinball_game.dart` (SkillShot wrapper), `packages/pinball_components/` skill_shot.

- ScoringContactBehavior(points: Points.oneMillion) = 1,000,000.
- RolloverNoiseBehavior.

### 4.5 GoogleGallery

**File:** `lib/game/components/google_gallery/google_gallery.dart`

- GoogleWordCubit + GoogleWord(position -4.45, 1.8).
- GoogleRollover left and right: ScoringContactBehavior 5k, RolloverNoiseBehavior.
- GoogleWordBonusBehavior: when all letters lit → BonusActivated(googleWord), reset letters, add BonusBallSpawningBehavior, GoogleWordAnimatingBehavior.

### 4.6 Multipliers

**File:** `lib/game/components/multipliers/multipliers.dart`

- Multiplier x2 (-19.6, -2, angle -15°), x3 (12.8, -9.4, 15°), x4 (-0.3, -21.2, 3°), x5 (-8.9, -28, -3°), x6 (9.8, -30.7, 8°).
- MultipliersBehavior: listens to ball contact, lights next multiplier; on contact sends MultiplierIncreased (handled in game_bloc).

**File:** `packages/pinball_components/` multiplier – MultiplierCubit, states for each multiplier lit.

### 4.7 Multiballs

**File:** `lib/game/components/multiballs/multiballs.dart`, `behaviors/multiballs_behavior.dart`

- Multiball.a(), .b(), .c(), .d() – 4 indicators.
- MultiballsBehavior: when bonusHistory last is dashNest or googleWord → animate multiball indicators (blinking).

### 4.8 AndroidAcres

**File:** `lib/game/components/android_acres/android_acres.dart`

- SpaceshipRamp: RampShotBehavior(5k), RampBonusBehavior(1M), RampProgressBehavior, RampMultiplierBehavior, RampResetBehavior.
- SpaceshipRail.
- AndroidBumper.a (-25.2, 1.5): 20k, BumperNoiseBehavior.
- AndroidBumper.b (-32.9, -9.3): 20k, BumperNoiseBehavior.
- AndroidBumper.cow (-20.7, -13): 20k, BumperNoiseBehavior, CowBumperNoiseBehavior.
- AndroidSpaceshipCubit + AndroidSpaceship (-26.5, -28.5), AndroidAnimatronic (-26, -28.25): ScoringContactBehavior 200k, AndroidSpaceshipBonusBehavior (BonusActivated(androidSpaceship)).

**RampMultiplierBehavior:** every 5 ramp hits → MultiplierIncreased (if not max multiplier). **File:** `lib/game/components/android_acres/behaviors/ramp_multiplier_behavior.dart`.

### 4.9 DinoDesert

**File:** `lib/game/components/dino_desert/dino_desert.dart`

- ChromeDino (12.2, -6.9): ScoringContactBehavior 200k (applyTo 'inside_mouth'), ChromeDinoBonusBehavior (BonusActivated(dinoChomp)).
- _BarrierBehindDino (edge shape), DinoWalls, Slingshots.

### 4.10 FlutterForest

**File:** `lib/game/components/flutter_forest/flutter_forest.dart`

- SignpostCubit, DashBumpersCubit.
- Signpost (7.95, -58.35): 5k, BumperNoiseBehavior.
- DashBumper.main (18.55, -59.35): 200k, BumperNoiseBehavior.
- DashBumper.a (8.95, -51.95), .b (21.8, -46.75): 20k, BumperNoiseBehavior.
- DashAnimatronic (20, -66): AnimatronicLoopingBehavior(11s).
- FlutterForestBonusBehavior: when all dash bumpers lit → BonusActivated(dashNest), add BonusBallSpawningBehavior.

### 4.11 SparkyScorch

**File:** `lib/game/components/sparky_scorch/sparky_scorch.dart`

- SparkyBumper.a (-22.9, -41.65), .b (-21.25, -57.9), .c (-3.3, -52.55): 20k, BumperNoiseBehavior.
- SparkyAnimatronic (-14, -58.2): AnimatronicLoopingBehavior(8).
- SparkyComputer: ScoringContactBehavior 200k (applyTo 'turbo_charge_sensor'), SparkyComputerBonusBehavior (BonusActivated(sparkyTurboCharge)).

### 4.12 Backbox

**File:** `lib/game/components/backbox/backbox.dart`

- Position (0, -87), anchor bottomCenter. Displays: LoadingDisplay, LeaderboardDisplay(top 10), LeaderboardFailureDisplay, InitialsInputDisplay, InitialsSubmissionSuccessDisplay, InitialsSubmissionFailureDisplay, GameOverInfoDisplay, ShareDisplay.
- When game over: BackboxBloc receives PlayerInitialsRequested → InitialsFormState; after submit → InitialsSuccessState → GameOverInfoDisplay; ShareScoreRequested → ShareState → ShareDisplay.

---

## 5. Point Values and Bonus Triggers

| Points enum | Value | Use |
|-------------|--------|-----|
| fiveThousand | 5000 | Rollovers, Kicker, Signpost, Ramp shot |
| twentyThousand | 20000 | Android/Dash/Sparky bumpers |
| twoHundredThousand | 200000 | Android animatronic, Sparky computer sensor, Chrome dino mouth, Dash main bumper |
| oneMillion | 1000000 | Skill shot, Ramp bonus |

**Bonuses (GameBonus):** googleWord, dashNest, sparkyTurboCharge, dinoChomp, androidSpaceship.

**Bonus ball:** Triggered by googleWord or dashNest. **File:** `lib/game/behaviors/bonus_ball_spawning_behavior.dart` – TimerComponent period 5s, then spawn Ball at (29.2, -24.5) with BallImpulsingBehavior(impulse (-40, 0)); add to ZCanvasComponent. (DinoWalls area; Flutter comment says "from DinoWalls".)

**Multiplier:** 1–6. Increased by MultiplierIncreased event (ramp: every 5 ramp hits via RampMultiplierBehavior; multiplier targets in pinball_components also drive lighting/state).

**Rounds:** 3. Decremented on RoundLost. When 0 → gameOver.

---

## 6. Ball Spawning

**File:** `lib/game/behaviors/ball_spawning_behavior.dart`

- When GameBloc: status is playing AND (just started game OR just lost round), spawn one Ball.
- Position: plunger.body.position.x, plunger.body.position.y - Ball.size.y.
- Layer launcher, zIndex ballOnLaunchRamp.
- Ball asset from CharacterThemeCubit (characterTheme.ball.keyName).

---

## 7. Camera

**File:** `lib/game/behaviors/camera_focusing_behavior.dart`

- waiting: zoom = size.y/175, position (0, -112).
- playing: zoom = size.y/160, position (0, -7.8).
- gameOver: zoom = size.y/100, position (0, -111).
- CameraZoom effect used when transitioning; camera moves to focus position.

---

## 8. Character Themes

**File:** `packages/pinball_theme/lib/src/themes/character_theme.dart`, and themes: sparky_theme, dino_theme, dash_theme, android_theme.

- CharacterTheme: name, ball (AssetGenImage), background, icon, leaderboardIcon, animation.
- Used in: Ball asset (ball.keyName), Backbox initials/leaderboard (character.leaderboardIcon), bonus animations.

---

## 9. Input

**File:** `lib/game/pinball_game.dart` – MultiTouchTapDetector, HasKeyboardHandlerComponents.

- Touch: if playing, tap on rocket bounds → Plunger autoPulled; else left/right half of board → move flippers on that side up on tap down, down on tap up/cancel.
- Keyboard: flipper keys (from pinball_components FlipperKeyControllingBehavior).

---

## 10. Physics

**File:** `lib/game/pinball_game.dart` – extends Forge2DGame, `gravity: Vector2(0, 30)`.

- Board: BoardDimensions.size (101.6, 143.8). Boundaries component defines playfield edges.

---

## 11. File Reference Index

| Feature | Flutter path |
|---------|--------------|
| Game state | lib/game/bloc/game_bloc.dart, game_state.dart, game_event.dart |
| Start flow | lib/start_game/bloc/start_game_bloc.dart, *_state.dart, *_event.dart |
| Backbox state | lib/game/components/backbox/bloc/backbox_bloc.dart, *_state.dart, *_event.dart |
| Pinball game root | lib/game/pinball_game.dart |
| Ball spawning | lib/game/behaviors/ball_spawning_behavior.dart |
| Bonus ball spawn | lib/game/behaviors/bonus_ball_spawning_behavior.dart |
| Drain | lib/game/components/drain/drain.dart, behaviors/draining_behavior.dart |
| Launcher | lib/game/components/launcher.dart |
| BottomGroup | lib/game/components/bottom_group.dart |
| SkillShot | lib/game/pinball_game.dart (SkillShot children) |
| GoogleGallery | lib/game/components/google_gallery/google_gallery.dart, behaviors/google_word_bonus_behavior.dart |
| Multipliers | lib/game/components/multipliers/multipliers.dart, behaviors/multipliers_behavior.dart |
| Multiballs | lib/game/components/multiballs/multiballs.dart, behaviors/multiballs_behavior.dart |
| AndroidAcres | lib/game/components/android_acres/android_acres.dart, behaviors/*.dart |
| DinoDesert | lib/game/components/dino_desert/dino_desert.dart, behaviors/*.dart |
| FlutterForest | lib/game/components/flutter_forest/flutter_forest.dart, behaviors/*.dart |
| SparkyScorch | lib/game/components/sparky_scorch/sparky_scorch.dart, behaviors/*.dart |
| Backbox | lib/game/components/backbox/backbox.dart, displays/*.dart |
| Camera | lib/game/behaviors/camera_focusing_behavior.dart |
| Board dimensions | packages/pinball_components/lib/src/components/board_dimensions.dart |
| Points enum | packages/pinball_components/lib/src/components/score_component/score_component.dart |
| Character themes | packages/pinball_theme/lib/src/themes/character_theme.dart, *_theme.dart |
