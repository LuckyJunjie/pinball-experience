# Pinball Game - Physics Specifications

**Document ID:** 4_03

## 1. Physics Engine Configuration

### 1.1 Engine Settings

**Physics Engine**: Godot 4.5 Built-in Physics (Bullet-based)

**Global Physics Settings**:
- Gravity: 980.0 units/s² (standard Earth gravity)
- Default Angular Damp: 0.1
- Physics FPS: 60 (matches display FPS)

**Physics Process**:
- All physics calculations in `_physics_process(delta)`
- Delta time: ~0.016s at 60 FPS
- Fixed timestep for consistent physics

## 2. Physics Layers

### 2.1 Layer Definitions

**Layer 1 - Ball**:
- Bit: 0
- Value: 1
- Used by: Ball RigidBody2D

**Layer 2 - Flippers**:
- Bit: 1
- Value: 2
- Used by: Flipper RigidBody2D

**Layer 4 - Walls**:
- Bit: 2
- Value: 4
- Used by: Wall StaticBody2D, MazePipe TileMapLayer

**Layer 8 - Obstacles**:
- Bit: 3
- Value: 8
- Used by: Obstacle StaticBody2D

### 2.2 Collision Masks

**Ball (Layer 1)**:
- `collision_mask = 14` (2 + 4 + 8)
- Collides with: Flippers, Walls, Obstacles
- Does NOT collide with: Other balls (single ball system)

**Flippers (Layer 2)**:
- `collision_mask = 1`
- Collides with: Ball only
- Does NOT collide with: Walls, Obstacles, Other flippers

**Walls (Layer 4)**:
- `collision_mask = 0`
- Static bodies, no mask needed
- Collision handled by Ball's mask

**Obstacles (Layer 8)**:
- `collision_mask = 0`
- Static bodies, collision via Area2D
- Collision handled by Ball's mask and Area2D

## 3. Ball Physics

### 3.1 Ball Properties

**RigidBody2D Configuration**:
```gdscript
mass = 0.5
gravity_scale = 1.0
linear_damp = 0.05
angular_damp = 0.05
collision_layer = 1
collision_mask = 14
```

**Shape**:
- Type: CircleShape2D
- Radius: 8.0 pixels

**Physics Material**:
```gdscript
bounce = 0.8  # High bounce for pinball feel
friction = 0.3  # Low friction for smooth movement
```

### 3.2 Ball Behavior

**Gravity**:
- Standard Earth gravity (980.0 units/s²)
- Always active (gravity_scale = 1.0)
- Pulls ball downward

**Damping**:
- Linear damping: 0.05 (minimal air resistance)
- Angular damping: 0.05 (minimal spin decay)
- Prevents infinite bouncing while maintaining energy

**Collision Response**:
- Elastic collisions with bounce coefficient 0.8
- Energy conservation with slight damping
- Realistic pinball physics feel

### 3.3 Boundary Enforcement

**Boundary Limits**:
- Left: x = 20.0
- Right: x = 780.0
- Top: y = 20.0
- Bottom: y = 580.0

**Enforcement Method**:
- Check position in `_physics_process()`
- Clamp position if outside boundaries
- Apply correction impulse if escaped
- Prevents ball from leaving playfield

## 4. Flipper Physics

### 4.1 Flipper Properties

**RigidBody2D Configuration**:
```gdscript
mass = 1.0
gravity_scale = 0.0  # No gravity
freeze = true  # Kinematic control
freeze_mode = FREEZE_MODE_KINEMATIC
collision_layer = 2
collision_mask = 1
```

**Shape**:
- Type: RectangleShape2D
- Size: Vector2(60, 12) pixels

**Physics Material**:
```gdscript
bounce = 0.6  # Medium bounce
friction = 0.5  # Medium friction for grip
```

### 4.2 Flipper Rotation

**Control Method**:
- Kinematic control (freeze = true)
- Direct rotation_degrees manipulation
- No torque or force application

**Rotation Parameters**:
- Rest angle: 0.0°
- Pressed angle: ±45.0° (negative for left, positive for right)
- Rotation speed: 20.0 degrees/second

**Rotation Behavior**:
- Only rotates when button is pressed
- Smooth interpolation to target angle
- Returns to rest when button released
- No automatic cycling

**Implementation**:
```gdscript
# Calculate angle difference
var angle_diff = target_angle - rotation_degrees

# Interpolate towards target
if abs(angle_diff) > 0.1:
    var rotation_dir = sign(angle_diff)
    var rotation_amount = min(abs(angle_diff), rotation_speed * delta * 60.0)
    rotation_degrees += rotation_dir * rotation_amount
```

## 5. Wall Physics

### 5.1 Wall Properties

**StaticBody2D Configuration**:
```gdscript
collision_layer = 4
collision_mask = 0  # Static, no mask needed
```

**Shapes**:
- Top/Bottom: RectangleShape2D (800x20)
- Left/Right: RectangleShape2D (20x600)

**Physics Material**:
```gdscript
bounce = 0.7  # Good bounce for walls
friction = 0.3  # Low friction
```

### 5.2 Wall Behavior

**Static Bodies**:
- No movement or rotation
- Fixed position
- Collision only (no physics response)

**Collision Response**:
- Ball bounces off walls
- Bounce coefficient: 0.7
- Energy loss on collision

## 6. Obstacle Physics

### 6.1 Obstacle Types

**Bumper**:
- Shape: CircleShape2D (radius: 30)
- Bounce: 0.95 (very high)
- Friction: 0.2 (low)
- Points: 20

**Peg**:
- Shape: CircleShape2D (radius: 8)
- Bounce: 0.8 (high)
- Friction: 0.3 (medium)
- Points: 5

**Wall**:
- Shape: RectangleShape2D (40x10)
- Bounce: 0.85 (high)
- Friction: 0.3 (medium)
- Points: 15
- Rotation: Random (0-360°)

### 6.2 Obstacle Collision

**Detection Method**:
- StaticBody2D for physics collision
- Area2D for hit detection and scoring
- Cooldown system (0.5s) prevents rapid hits

**Collision Response**:
- Ball bounces with obstacle-specific bounce coefficient
- Points awarded on collision
- Visual/audio feedback (future)

## 7. Collision Detection

### 7.1 Collision Methods

**Physics Collision** (RigidBody2D):
- Automatic collision detection
- Physics response (bounce, friction)
- Used for: Ball-Flipper, Ball-Wall, Ball-Obstacle

**Area Detection** (Area2D):
- Trigger-based detection
- No physics response
- Used for: Obstacle hit detection and scoring

### 7.2 Collision Events

**Ball-Flipper**:
- Physics collision (automatic)
- Bounce with 0.6 coefficient
- Flipper rotation affects trajectory

**Ball-Wall**:
- Physics collision (automatic)
- Bounce with 0.7 coefficient
- Boundary enforcement

**Ball-Maze Pipe**:
- Physics collision via TileMapLayer (automatic)
- Bounce with 0.3 coefficient (low bounce for smooth guidance)
- Friction: 0.1 (very low for smooth sliding through channels)
- Channel walls guide ball path through maze

**Ball-Obstacle**:
- Physics collision (automatic bounce)
- Area2D detection (scoring trigger)
- Cooldown prevents multiple rapid hits

## 8. Physics Materials

### 8.1 Material Properties

**Bounce (Restitution)**:
- Range: 0.0 to 1.0
- 0.0 = No bounce (inelastic)
- 1.0 = Perfect bounce (elastic)
- Values > 1.0 possible but unrealistic

**Friction**:
- Range: 0.0 to 1.0
- 0.0 = No friction (slippery)
- 1.0 = Maximum friction (sticky)
- Affects sliding and rolling

### 8.2 Material Assignments

**Ball**:
- Bounce: 0.8 (high, realistic pinball)
- Friction: 0.3 (low, smooth movement)

**Flippers**:
- Bounce: 0.6 (medium, good control)
- Friction: 0.5 (medium, grip ball)

**Walls**:
- Bounce: 0.7 (good bounce)
- Friction: 0.3 (medium)

**Maze Pipe Walls** (TileMapLayer):
- Bounce: 0.3 (low bounce for smooth guidance)
- Friction: 0.1 (very low for smooth sliding)
- Collision layer: 4 (Walls layer)
- Friction: 0.3 (low, smooth)

**Bumpers**:
- Bounce: 0.95 (very high, exciting)
- Friction: 0.2 (very low)

**Pegs**:
- Bounce: 0.8 (high)
- Friction: 0.3 (low)

**Obstacle Walls**:
- Bounce: 0.85 (high)
- Friction: 0.3 (low)

## 9. Performance Considerations

### 9.1 Physics Optimization

**Collision Shapes**:
- Use simple shapes (circles, rectangles)
- Avoid complex polygons
- Minimal collision shapes per object

**Physics Bodies**:
- StaticBody2D for walls and obstacles (no physics calculations)
- RigidBody2D only for dynamic objects (ball, flippers)
- Freeze inactive objects (queued balls)

**Update Frequency**:
- Physics in `_physics_process()` (fixed timestep)
- Visual updates in `_process()` (variable timestep)
- Separate concerns for performance

### 9.2 Collision Optimization

**Layer System**:
- Efficient layer-based filtering
- Only check relevant collisions
- Reduce collision pairs

**Sleeping Bodies**:
- Queued balls set to sleeping
- Reduces physics calculations
- Wake when activated

## 10. Physics Debugging

### 10.1 Debug Visualization

**Godot Debug Features**:
- Physics debug overlay
- Collision shape visualization
- Force/velocity vectors
- Contact points

**Custom Debug**:
- Print position/velocity on collision
- Log physics events
- Visualize boundary limits

### 10.2 Common Issues

**Ball Escaping Boundaries**:
- Solution: Boundary enforcement in `_physics_process()`
- Check position every frame
- Apply correction if needed

**Flipper Not Rotating**:
- Check: freeze = true
- Check: Input action mapping
- Check: Rotation interpolation logic

**Ball Not Bouncing**:
- Check: Physics material bounce value
- Check: Collision layers/masks
- Check: Collision shape size

**Performance Issues**:
- Reduce number of physics bodies
- Use simpler collision shapes
- Freeze inactive objects
- Optimize collision layers

## 11. Physics Testing

### 11.1 Test Cases

**Ball Physics**:
- [ ] Ball falls with correct gravity
- [ ] Ball bounces correctly off walls
- [ ] Ball bounces correctly off flippers
- [ ] Ball bounces correctly off obstacles
- [ ] Ball doesn't escape boundaries

**Flipper Physics**:
- [ ] Flippers rotate when button pressed
- [ ] Flippers return to rest when released
- [ ] Flippers don't cycle automatically
- [ ] Flippers affect ball trajectory

**Collision Detection**:
- [ ] All collisions detected correctly
- [ ] Scoring triggers on obstacle hit
- [ ] Cooldown prevents rapid hits
- [ ] No false collisions

### 11.2 Physics Validation

**Realism Check**:
- Ball movement feels natural
- Bounce coefficients feel right
- Friction doesn't feel too sticky/slippery
- Energy conservation feels appropriate

**Performance Check**:
- 60 FPS maintained
- No physics lag
- Smooth ball movement
- Responsive flippers
