extends Area2D
## Obstacle - generic scoring component. Configurable points per instance.
## Phase 2 reuses this in zone nodes (e.g. AndroidBumperA).

@export var points: int = 5000
@export var cooldown: float = 0.3

var _cooldown_timer: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = true

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

func _on_body_entered(body: Node2D) -> void:
	if _cooldown_timer > 0:
		return
	if body.is_in_group("ball"):
		GameManager.add_score(points, name)
		_cooldown_timer = cooldown
		if SoundManager:
			SoundManager.play_sound("obstacle_hit")
