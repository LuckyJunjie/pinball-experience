# REQ-010 Polish - Design Document

**Project:** pinball-experience  
**Requirement:** REQ-010 Polish  
**Version:** 1.0  
**Last Updated:** 2026-03-01

---

## 1. Overview

REQ-010 Polish focuses on refining the pinball game through:
- **Game Details Improvement** - Complete missing game elements
- **Performance Optimization** - Ensure 60 FPS target
- **UI Fine-tuning** - Enhance visual feedback and HUD
- **Sound Effects** - Add audio feedback for game events

---

## 2. Current State Analysis

### 2.1 Implemented Features (Baseline 0.5)
- ✅ Launcher with plunger mechanics
- ✅ Left/Right flippers with keyboard input
- ✅ Drain detection and round management
- ✅ Basic obstacles with scoring (5k, 20k points)
- ✅ Combo system with multiplier
- ✅ Basic HUD (score, multiplier, rounds)
- ✅ Game over panel with replay
- ✅ Sound files exist (5 sound effects)

### 2.2 Missing Polish Items
| Category | Item | Priority |
|----------|------|----------|
| Sound | Integrate sound effects to game events | P0 |
| UI | Score popups for scoring events | P1 |
| UI | Visual feedback on bumpers | P1 |
| Game | Google letters rollover targets | P2 |
| Game | Multiball indicator lights | P2 |
| Game | Skill shot visual | P2 |
| UI | Start screen / Main menu | P2 |
| Performance | Physics optimization | P1 |

---

## 3. Design Details

### 3.1 Sound Effects Integration (P0)

**Current State:**
- SoundManager.gd exists with 5 sound files
- Sounds not yet triggered by game events

**Implementation:**
```
Sound Events Mapping:
├── ball_launch    → Ball spawns at launcher
├── flipper_click → Flipper activated
├── obstacle_hit  → Ball hits bumper/obstacle
├── ball_lost     → Ball drains
└── hold_entry    → Bonus/special event
```

**Technical Approach:**
- Connect GameManager signals to SoundManager
- Add play_sound() calls in appropriate scripts
- Ensure audio doesn't stack inappropriately

### 3.2 UI Polish (P1)

**Score Popups:**
- Create floating text when scoring
- Animation: fade up and out (0.5s)
- Colors: 5k=yellow, 20k=orange, 200k=pink, 1M=purple

**Bumper Visual Feedback:**
- Flash/bounce animation on obstacle hit
- Duration: 100ms
- Color tint change (optional)

**HUD Enhancement:**
- Better typography and spacing
- Score counter animation (rolling numbers)
- Combo text with glow effect

### 3.3 Game Details (P2)

**Google Letters Rollover:**
- Add 6 rollover sensors (G-O-O-G-L-E)
- Each lights up on ball contact
- Full word = bonus ball

**Multiball Indicator:**
- 4 indicator lights
- One lights per bonus ball earned
- Visual feedback during gameplay

**Skill Shot:**
- Visual indicator at launch lane top
- Awards 1M points if reached

### 3.4 Performance Optimization (P1)

**Target:** 60 FPS (NFR-2.1)

**Optimization Areas:**
1. **Physics Bodies** - Use appropriate collision layers
2. **Object Pooling** - Reuse ball objects
3. **Signal Optimization** - Reduce unnecessary emissions
4. **Tween Management** - Clean up completed tweens

---

## 4. Implementation Plan

### Phase 1: Sound Integration (Priority: P0)
1. Connect GameManager signals to SoundManager
2. Add sound playback in Ball.gd, Flipper.gd, Obstacle.gd, Drain.gd
3. Test audio playback

### Phase 2: UI Polish (Priority: P1)
1. Create ScorePopup.tscn (floating text)
2. Update UI.gd to spawn score popups
3. Add bumper animation on hit
4. Improve HUD styling

### Phase 3: Game Details (Priority: P2)
1. Add Google letters rollover targets
2. Implement multiball indicators
3. Add skill shot visual
4. Create start screen

### Phase 4: Performance (Priority: P1)
1. Profile current performance
2. Optimize physics collisions
3. Add object pooling for balls

---

## 5. File Changes Summary

### New Files
- `scenes/ScorePopup.tscn` - Floating score text
- `scenes/GoogleLetter.tscn` - Rollover target
- `scenes/MultiballIndicator.tscn` - Bonus light
- `scenes/StartScreen.tscn` - Main menu

### Modified Files
- `scripts/SoundManager.gd` - Trigger from signals
- `scripts/UI.gd` - Score popups, styling
- `scripts/Obstacle.gd` - Visual feedback
- `scripts/GameManager.gd` - Signal connections
- `scenes/Main.tscn` - Add polish elements

---

## 6. Testing Strategy

1. **Sound Test** - Verify each sound plays at correct event
2. **UI Test** - Score popups appear and animate correctly
3. **Performance Test** - Maintain 60 FPS during gameplay
4. **Gameplay Test** - All new features functional

---

## 7. Success Criteria

- [ ] All 5 sound effects trigger correctly
- [ ] Score popups display on scoring events
- [ ] Bumpers show visual feedback on hit
- [ ] Performance maintains 60 FPS
- [ ] Game feel is polished and responsive
