extends Node
## Coordinate conversion: Flutter Forge2D → Godot pixel coordinates.
## Used for bonus ball spawn position and other layout values.

const SCALE: float = 5.0
const CENTER_X: float = 400.0
const CENTER_Y: float = 300.0

static func flutter_to_godot(flutter_pos: Vector2) -> Vector2:
	return Vector2(flutter_pos.x * SCALE + CENTER_X, flutter_pos.y * SCALE + CENTER_Y)

static func flutter_impulse_to_godot(flutter_impulse: Vector2) -> Vector2:
	return flutter_impulse * SCALE
