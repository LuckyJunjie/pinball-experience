# Pinball Game – Asset Requirements

**Document ID:** 4_02

## Overview

The game reuses the same game design as Flutter I/O Pinball. Art and sounds should match or closely mirror the Flutter project. This document lists required assets and references Flutter paths. Existing assets under `assets/sprites/` can be reused where they align.

---

## 1. Flutter Source Reference

**Flutter repo:** `/Users/junjiepan/github/pinball`

| Path | Content |
|------|---------|
| `assets/images/bonus_animation/` | android_spaceship.png, dash_nest.png, dino_chomp.png, google_word.png, sparky_turbo_charge.png |
| `assets/images/components/` | key.png, space.png |
| `assets/images/loading_game/` | io_pinball.png |
| `assets/images/score/` | mini_score_background.png |
| `packages/pinball_components/` | Component sprites (bumpers, flipper, plunger, ball, etc.) – see package assets |
| `packages/pinball_theme/` | Character theme assets (ball, background, icon, leaderboardIcon, animation) per theme |

---

## 2. Board and Background

- **Board background:** Playfield background sprite. Flutter: BoardBackgroundSpriteComponent. Use or adapt from project assets.
- **Arcade background:** Optional; Flutter uses ArcadeBackground on desktop. Can use a simple background.
- **Boundaries:** Invisible or simple wall sprites; collision defined in code/shapes.

---

## 3. Zones and Components

### 3.1 Launcher

- **Launch ramp:** Ramp visual and collision.
- **Plunger:** Plunger sprite.
- **Rocket sprite:** Rocket/ball launcher visual (Flutter RocketSpriteComponent).
- **Flapper:** Flapper visual if separate from plunger.

### 3.2 Ball

- **Ball sprites (4 themes):** Sparky, Dino, Dash, Android. Flutter: character theme ball asset. May need four variants or tint for each character theme.
- **Ball trail (optional):** For multiball or polish.

### 3.3 Bumpers and Targets

- **Android bumpers (A, B, COW):** Bumper visuals; dimmed/lit states.
- **Dash bumpers (main, A, B):** Same or similar bumper set.
- **Sparky bumpers (A, B, C):** Same or similar.
- **Signpost:** Flutter Forest signpost; use or create small sprite.
- **Kickers:** Left/right kicker visuals (optional; can use bumper or simple shape).

### 3.4 Ramp and Rail

- **Spaceship ramp:** Android Acres ramp visual and collision. Use or create ramp sprite.
- **Spaceship rail:** Rail visual next to ramp.
- **Dino:** Chrome Dino sprite; mouth open/closed if animated.
- **Slingshots:** Left/right slingshot visuals (optional).

### 3.5 Google Gallery

- **Google Word:** "Google" letters (G, o, o, g, l, e) – lit/unlit states.
- **Rollovers:** Left/right rollover visuals (can be part of word or separate).

### 3.6 Multipliers and Multiballs

- **Multiplier indicators:** x2, x3, x4, x5, x6 – lit/unlit or single sprite with frame. Flutter: multiplier component assets from pinball_components.
- **Multiball indicators:** Four lights or icons (A, B, C, D); dimmed/lit or blink. Flutter: multiball component assets.

### 3.7 Skill Shot

- **Skill shot target:** Rollover or target zone visual; can reuse rollover or a dedicated sprite.

### 3.8 Animatronics

- **Android animatronic:** Android character near spaceship.
- **Dash animatronic:** Dash character.
- **Sparky animatronic:** Sparky character.
- **Chrome Dino:** dino_chomp style.

### 3.9 Backbox

- **Backbox marquee:** Top marquee image. Flutter: Assets.images.backbox.marquee; check pinball_theme or pinball_components for path.
- **Leaderboard display:** Background or panel; text for rank, initials, score, character icon.
- **Initials input:** Input field, submit button, character icon.
- **Game over info:** Score, share button.
- **Share display:** Share options (copy, native share).
- **Loading/failure:** Simple loading spinner and error message.

---

## 4. Score Popups

- **Score popup sprites:** 5000, 20000, 200000, 1000000. Flutter: `assets/images/score/` (mini_score_background.png) and pinball_components score_component assets (fiveThousand, twentyThousand, twoHundredThousand, oneMillion). Use or add sprites for 5k, 20k, 200k, 1M.

---

## 5. Character Selection and How to Play

- **Character select screen:** Background; four character options (Sparky, Dino, Dash, Android) with ball preview and leaderboard icon per theme. Flutter: pinball_theme character assets (icon, leaderboardIcon, animation).
- **How to Play:** Panel or screen with instructions; dismiss button.
- **Play / Replay buttons:** UI buttons. Flutter: PinballGame playButtonOverlay, replayButtonOverlay.

---

## 6. Audio

**Flutter:** `packages/pinball_audio/` – MP3s for bumper, kicker, rollover, drain, launch, bonus, etc.

Reuse or adapt from `assets/sounds/`:

- **ball_launch.wav** – Plunger/launch.
- **ball_lost.wav** – Drain.
- **flipper_click.wav** – Flipper.
- **obstacle_hit.wav** – Bumper/kicker.
- **hold_entry.wav** – Rollover or target entry (e.g. skill shot).

Add or rename as needed: bumper, kicker, rollover, bonus, multiplier_up. Format: WAV or OGG for Godot.

---

## 7. Asset List Summary

| Category | Assets | Source / Notes |
|----------|--------|-----------------|
| Board | background.png | Flutter or project |
| Launcher | launcher_base, plunger, rocket | Flutter, project |
| Ball | ball x4 (themes) | Theme assets |
| Bumpers | bumper, dimmed, lit | project bumpers/ |
| Ramp/Rail | ramp, rail | Create or Flutter |
| Dino | dino_chomp | project |
| Google Word | google_word | project |
| Animatronics | android_spaceship, dash_nest, sparky_turbo_charge | project |
| Multiplier/Multiball | x2–x6, 4 lights | Create or Flutter package |
| Backbox | marquee, panels | Flutter / create |
| Score popups | 5k, 20k, 200k, 1M | Flutter score assets |
| UI | Play, Replay, character icons, how to play | Create or Flutter |
| Audio | launch, drain, flipper, bumper, kicker, rollover, bonus | project sounds, Flutter pinball_audio |

---

## 8. Implementation Notes

- **Reuse:** Prefer `assets/sprites/` and `assets/sounds/` where assets match (android_spaceship, dino_chomp, google_word, sparky_turbo_charge, dash_nest, key, space, ball, bumper, flipper, plunger, launcher_base).
- **Scale:** Flutter board 101.6 x 143.8; Godot world scale can match or use different units with same aspect.
- **Character themes:** Store theme id (Sparky, Dino, Dash, Android) and select ball sprite + leaderboard icon from theme.
- **Missing assets:** Use placeholders (ColorRect, simple shapes) until final art; replace with references above.
