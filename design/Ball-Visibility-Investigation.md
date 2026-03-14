# Ball Visibility Investigation

## Why no ball movement is visible (even with a wall to bounce)

If the ball went **up and right**, it would hit the wall and bounce — we would see it. The fact that we see **nothing** means the ball is **not** going up and right.

## Most likely cause: ball gets downward velocity

The ball is probably getting **downward velocity** instead of upward, so it falls straight into the drain in 1–2 frames and is returned to the pool (hidden) before we can see it.

- Launch at (700, 475) → drain at y 560–600
- Distance: ~105 px
- If velocity is (0, 650): ~10 frames to drain → we might see it briefly
- If velocity is (0, 6500+) or (0, 65000): 1 frame to drain → we never see it

So the ball is likely receiving a large downward velocity instead of the intended upward launch impulse.

## Why the wall doesn’t help

The wall only matters if the ball moves **up** (or at least sideways). If the ball moves **down** from the launcher, it never reaches the wall; it goes straight into the drain.

## Possible causes

1. **Physics sync when unfreezing** – When `freeze = false`, the physics server may apply accumulated gravity or use stale state.
2. **BallPool `get_ball()` sets `freeze = false`** – Ball is unfrozen before position is set; if a physics step runs between unfreeze and reposition, the ball could fall.
3. **Scene tree vs physics server timing** – `linear_velocity` and `apply_central_impulse` may not be applied in the same physics step as expected.

## Difference from original pin-ball

The original project uses the same pattern (`freeze = false`, `apply_impulse(force)`) and it works. The difference may be:

- Different scene/initialization order
- Different BallPool usage or timing
- Different Godot version or physics settings

## Suggested next steps

1. Add debug logs to confirm the ball’s velocity in the first few frames after launch.
2. Reintroduce the `_integrate_forces` approach to force the correct launch velocity and position.
3. Or: avoid unfreezing in `get_ball()` until the ball is positioned and ready to launch.
