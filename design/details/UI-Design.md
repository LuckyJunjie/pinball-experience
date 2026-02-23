# Pinball Game – UI/UX Design Specification

**Document ID:** 4_04

This document defines the **enhanced** UI/UX for the Pinball game, including all screens (main menu, character select, how to play, in-game HUD, backbox, store, level select, score range board), visual design, responsiveness, and feedback. It aligns with [../Technical-Design.md](../Technical-Design.md) and [../../requirements/Requirements.md](../../requirements/Requirements.md).

---

## 0. Design Evolution and Scope

### 0.1 Critique of the Original UI Design

The initial UI design was functional but too minimal for a modern pinball game with Store, Level Mode, and Score Range Board. Key gaps:

- **Lack of visual flair**: Flat colors, no textures, gradients, or shadows; did not convey the playful, energetic I/O Pinball theme.
- **Missing screens**: Only the in-game HUD was specified. Omitted: main menu (Play, Levels, Store), character selection, How to Play, Store, level selection, score range board, and backbox (leaderboard, initials, game over, share).
- **In-game HUD limitations**: Static instructions used too much space; no multiplier, rounds left, or bonus indicators; ball queue visual unclear and not tied to game state.
- **Poor adaptability**: Fixed positioning and no responsive design for different screen sizes (especially mobile).
- **No feedback or animation**: No visual feedback for scoring, bonuses, or state changes.

### 0.2 Scope of This Document

This specification replaces and extends the original with:

- **All core screens**: Main menu, character select, how to play, in-game HUD, backbox (leaderboard/initials/game over/share), store, level select, score range board.
- **Thematic, responsive, feedback-rich** design with animations and clear hierarchy.
- **Implementation-ready** details: fonts, colors, Godot node structure, animation and input handling.

---

## 1. Design Principles

1. **Immersive & thematic**: Use vibrant colors, gradients, and subtle animations that reflect the four character themes (Sparky, Dino, Dash, Android).
2. **Clarity & readability**: Information is organized hierarchically; critical data (score, multiplier, rounds) is prominent; secondary info is accessible but unobtrusive.
3. **Consistent navigation**: Clear transitions between screens, with back buttons and consistent styling.
4. **Mobile-friendly**: Touch targets are large enough; UI scales using anchors and Control nodes so it works on different aspect ratios and sizes.
5. **Feedback-rich**: Animated score popups, flashing indicators, and smooth transitions keep the player engaged.

---

## 2. Main Menu (Splash)

**Purpose**: Entry point with mode selection (Play, Levels, Store) and access to Score Range Board and Leaderboard.

**Layout**:
- Full-screen CanvasLayer with a **dynamic background** (character-themed art cycle or looping video, or parallax playfield elements).
- Centered vertical stack of large buttons:
  - **Play** (Classic mode)
  - **Levels** (Level mode)
  - **Store**
  - **Settings** (optional)
- Bottom row: **Score Range Board** (icon + text) and **Leaderboard** buttons.

**Visuals**:
- Buttons: rounded corners, gradient fills, subtle hover/press animations (scale up, glow).
- Each button has an icon (e.g. Play = pinball, Levels = map/mountain, Store = bag/coins).
- Background supports parallax or gentle motion to reinforce theme.

**Transitions**:
- Fade in on load; button press triggers slide or fade to the next screen.

**Behavior**:
- Play → Character Select (or directly to How to Play if character is remembered).
- Levels → Level Select.
- Store → Store scene.
- Score Range Board → Score Range Board overlay.
- Leaderboard → Backbox in leaderboard state (or dedicated leaderboard screen).

---

## 3. Character Selection

**Purpose**: Player chooses one of four themes (Sparky, Dino, Dash, Android) for ball asset and leaderboard icon; can affect Store upgrades.

**Layout**:
- Title: e.g. "Choose Your Character".
- **Grid of four cards** (2×2 or 1×4), each with:
  - Large character art
  - Theme name
  - Brief tagline (e.g. "Electric Speedster")
  - Select button or tap-to-select
- **Back** button to Main Menu.

**Visuals**:
- Each card uses the character’s color palette; **glowing border** on hover/focus.
- **Selected** card pulses briefly before transitioning to How to Play.

**Behavior**:
- On selection: store theme in GameManager (or session state); transition to How to Play.

---

## 4. How to Play

**Purpose**: Explain objective, scoring, controls, and special moves before first game.

**Layout**:
- **Split layout**: left = simplified playfield diagram with numbered zones; right = instructions.
- Instructions include:
  - Objective (score, rounds, multiplier)
  - Scoring basics (points per hit type)
  - Controls (keyboard and touch)
  - Special moves (skill shot, bonuses, bonus ball)
- **"Got it!"** (or "Play") button at bottom.
- Optional **Back** to Character Select.

**Visuals**:
- Diagram can **animate** to highlight each zone as its description is shown.
- Icons for keys and touch gestures.

**Behavior**:
- Dismiss → start game (load playfield, status = playing).

---

## 5. In-Game HUD (Playing State)

**Purpose**: Show score, multiplier, rounds, bonus history, and launcher state without blocking the playfield.

**Layout**:
- **Top bar** (always visible, semi-transparent dark strip):
  - **Left**: **Score** (large, with optional digit roll-up animation).
  - **Center**: **Multiplier** badge (x1–x6).
  - **Right**: **Rounds left** (e.g. three ball icons; one dims per round lost).
- **Bottom bar** (semi-transparent, optional):
  - **Left**: **Bonus history** (small icons of earned bonuses).
  - **Right**: **Launcher charge meter** (only when ball is in launcher).
- **Floating score popups**: On hit, a short-lived "+5000" (or relevant amount) at the hit location, then fades and moves up.
- **Multiball indicators**: Four small lights (e.g. top-right) that **blink** when a bonus ball is pending (Google Word / Dash Nest).

**Visuals**:
- Score: digital-style font with subtle glow; high contrast on dark bar.
- Multiplier badge: color or intensity changes with value (e.g. yellow → orange → red as it increases).
- Rounds: use **themed ball sprites** (character theme).
- HUD background: dark translucent so playfield remains visible.

**Animations**:
- Score: optional counting-up on change.
- Multiplier: short pulse when increased.
- Bonus history: icons slide in from the side.
- Score popup: tween upward and fade out (~0.5 s).

**What to avoid**:
- Static, long instruction text that permanently occupies the center of the screen. Prefer a one-time How to Play screen and minimal or collapsible hints in HUD.

---

## 6. Backbox (Leaderboard & Game Over)

**Purpose**: Show top 10, collect initials after game over, show game over info, and offer Share, Replay, Store, and Main Menu. Per requirements §2.8.

**Layout** (separate UI layer, e.g. slides down from top or appears above playfield):
- **Leaderboard view**:
  - Title: e.g. "Top 10".
  - Scrollable list: **Rank**, **Initials** (3 chars), **Score**, **Character icon**.
  - Buttons: Close, Share (optional).
- **Initials entry** (after game over):
  - Final score and character icon.
  - **Three input fields** for initials (one character each, large touch targets).
  - On-screen keyboard (mobile) or physical keyboard (desktop).
  - **Submit** button.
- **Game over info** (after submit):
  - Final score; optional "New High Score!" badge.
  - Buttons: **Replay**, **Store**, **Main Menu**, **Share**.

**Visuals**:
- Backbox background can mimic an **LCD/arcade** look (e.g. scanlines, pixel font).
- Buttons: clear, readable; retro arcade style if it fits the theme.

**Behavior**:
- Game over (rounds == 0) → show initials; on submit → save to local leaderboard → game over info with Replay/Store/Main Menu/Share.

---

## 7. Store UI

**Purpose**: Spend coins on upgradable items (Balls, Flippers, Plunger, Bumpers, Multiplier Boost, Extra Ball); persistence and character-themed options per requirements §5.

**Layout**:
- **Top**: **Coin balance** (with coin icon).
- **Tabs**: e.g. Balls, Flippers, Plunger, Bumpers, Power-ups (Multiplier Boost, Extra Ball).
- **Content**: Grid or list of items per tab; each item shows:
  - Icon
  - Name
  - Short description (e.g. "Steel Ball: +10% restitution")
  - **Price** (coins)
  - **Buy** (or **Equip** if already owned)
- **Back** button (to Main Menu or Leaderboard).

**Visuals**:
- Card-style items with hover/press feedback.
- **Purchased** items: checkmark or "Equip" state.
- Coin balance updates immediately after purchase.

**Behavior**:
- Purchases write to PlayerAssets (persisted); items affect both Classic and Level modes. Character theme can filter or theme available items.

---

## 8. Level Select

**Purpose**: Choose a level for Level Mode; show progression and locked/unlocked state. Per requirements §7.

**Layout**:
- **World map** or **level list** as background.
- **Level nodes**: Each shows level number, difficulty (e.g. 1–3 stars), and **lock icon** if not unlocked.
- **Tap/click level** → popup with:
  - Level name
  - **Objective** (e.g. "Reach 500k points", "Light all Google letters")
  - **Reward** (e.g. coins)
  - **Play** button
- **Back** to Main Menu.

**Visuals**:
- Map or list scrolls (horizontal or vertical).
- **Unlocked** levels: highlighted or glowing; **locked**: grayed out.
- Current progress or high score per level can be shown on the node or in the popup.

**Behavior**:
- Play → load level playfield (same physics as Classic); completion grants coins and unlocks next level per requirements.

---

## 9. Score Range Board

**Purpose**: Show score brackets, rewards, and progress toward the next bracket. Per requirements §6.

**Layout**:
- **Overlay** (from Main Menu or in-game; in-game can pause or be non-blocking).
- **Vertical list** of score brackets (e.g. 0–100k, 100k–500k, 500k–1M, 1M–5M, 5M+) with:
  - **Progress bar** for current bracket (or progress to next).
  - **Reward** text (e.g. "+100 coins", unlock).
- If opened during play: highlight **current** bracket and **next** target.

**Visuals**:
- **Reached** brackets: one color (e.g. green); **current**: another (e.g. blue); **future**: muted (e.g. gray).
- Progress bar fills smoothly.

**Behavior**:
- Reaching a new bracket in game: show a short **notification**; reward granted post-game (e.g. coins added to PlayerAssets).

---

## 10. UI Component Specifications (Implementation)

### 10.1 Fonts and Colors

**Fonts**:
- **Primary**: Bold font for scores and headings (e.g. Roboto Bold or similar free font).
- **Secondary**: Regular for body text and descriptions.

**Color palette** (suggested; can be tuned per theme):
- Background dark: `#0A0F1E`
- Accent blue: `#3B82F6`
- Accent orange: `#F97316`
- Score glow: white with ~20% opacity
- Success green: `#10B981`
- Warning red: `#EF4444`
- UI overlay: dark with alpha (e.g. `Color(0.05, 0.05, 0.15, 0.85)`)

**Legacy reference** (for compatibility with existing docs):
- Playfield dark: `Color(0.1, 0.1, 0.2, 1)`
- Score text: white; instructions/secondary: light gray.

### 10.2 Godot Node Structure

Use **Control** nodes with **anchors** and **containers** for responsiveness.

**Main Menu** (example):
```
MainMenu (Control) - full rect
├── Background (TextureRect) - full screen
├── VBoxContainer (center)
│   ├── Button (Play)
│   ├── Button (Levels)
│   ├── Button (Store)
│   └── Button (Settings)
├── HBoxContainer (bottom)
│   ├── Button (ScoreRangeBoard)
│   └── Button (Leaderboard)
└── AnimationPlayer (transitions)
```

**In-game HUD**:
```
HUD (CanvasLayer)
├── TopBar (MarginContainer) - anchors top
│   ├── ScoreLabel (Label)
│   ├── MultiplierBadge (PanelContainer + Label)
│   └── RoundsContainer (HBoxContainer of TextureRect - ball icons)
├── BottomBar (MarginContainer) - anchors bottom, optional
│   ├── BonusHistory (HBoxContainer of TextureRect)
│   └── ChargeMeter (ProgressBar) - visible only when ball in launcher
└── PopupManager (Node) - spawns floating score Labels at hit positions
```

**Backbox** can be a single Control with swapped child content (LeaderboardDisplay, InitialsInputDisplay, GameOverInfoDisplay, ShareDisplay) or separate scenes loaded into a container.

### 10.3 Animation Details

- **Screen transitions**: Use `AnimationPlayer` or `Tween`: fade or slide (e.g. Store slides from right).
- **Button hover/press**: Scale to ~1.1, modulate color or glow.
- **Score popup**: Instantiate `Label` at hit position (world or screen space); tween position upward and modulate alpha to 0 over ~0.5 s; then free.
- **Multiplier increase**: Pulse badge (scale to ~1.2 then back); optional "ding" sound.
- **Ball drain**: Optional short screen shake.
- **Bonus history**: New icon slides in from the side.

### 10.4 Input Handling

- **Desktop**: Mouse for UI buttons; keyboard for flippers (A/Left, D/Right) and plunger (Space/Down).
- **Mobile**: Touch for UI; **left half** of playfield = left flipper, **right half** = right flipper; **tap on plunger/launcher** = launch. Touch targets at least 44×44 pt.
- **Initials (mobile)**: Use system **Virtual Keyboard** where available, or custom on-screen keyboard Control.

---

## 11. Responsive and Accessibility

### 11.1 Responsive Design

- **Anchors**: Top bar anchored to top, bottom bar to bottom, side elements to sides; center content uses center anchors.
- **Scaling**: Font sizes and margins can scale with viewport size or use theme overrides.
- **Aspect ratio**: Playfield may letterbox or scale to fit; UI bars and buttons remain visible and tappable on narrow and wide screens.

### 11.2 Accessibility

- **Contrast**: High contrast for score and critical labels (e.g. white on dark).
- **Color**: Do not rely on color alone; use icons and shapes (e.g. multiplier badge shows "x3" and a distinct shape).
- **Input**: Support both keyboard and touch; optional on-screen control hints.

---

## 12. Implementation Checklist

- [ ] Main Menu scene: animated background, Play / Levels / Store / Settings, Score Range Board and Leaderboard buttons.
- [ ] Character Select scene: four theme cards, selection stored, transition to How to Play.
- [ ] How to Play scene: playfield diagram and instructions, "Got it!" → start game.
- [ ] In-game HUD: top bar (score, multiplier, rounds), optional bottom bar (bonus history, charge meter), floating score popups, multiball indicators; anchors for different resolutions.
- [ ] Backbox: Leaderboard (top 10), Initials entry, Game Over info, Share; Replay, Store, Main Menu.
- [ ] Store UI: coin balance, tabs (Balls, Flippers, Plunger, Bumpers, Power-ups), item cards, Buy/Equip, Back.
- [ ] Level Select: map or list, level nodes (locked/unlocked), level popup (objective, reward, Play), Back.
- [ ] Score Range Board: overlay with brackets, progress bars, rewards; accessible from menu and optionally in-game.
- [ ] Connect all UI to game state via signals (GameManager, BackboxManager, StoreManager, LevelManager, PlayerAssets).
- [ ] Add animations and sound effects for transitions and feedback (score popup, multiplier pulse, button press).

---

## 13. Reference

- Requirements: [../../requirements/Requirements.md](../../requirements/Requirements.md) (§2.8 Backbox, §5 Store, §6 Score Range Board, §7 Level Mode).
- Technical design: [../Technical-Design.md](../Technical-Design.md).
- Asset requirements: [Asset-Requirements.md](Asset-Requirements.md).
