extends Area2D
## Obstacle - generic scoring component. Configurable points per instance.
## Phase 2 reuses this in zone nodes (e.g. AndroidBumperA).

@export var points: int = 5000
@export var cooldown: float = 0.3

var _cooldown_timer: float = 0.0
var _sprite: Sprite2D = null
var _original_modulate: Color = Color.WHITE

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = true
	# Get sprite for visual feedback
	_sprite = get_child(0) as Sprite2D
	if _sprite:
		_original_modulate = _sprite.modulate

func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

func _on_body_entered(body: Node2D) -> void:
	if _cooldown_timer > 0:
		return
	if body.is_in_group("ball"):
		GameManager.add_score(points, name)
		_cooldown_timer = cooldown
		SoundManager.play_sound("obstacle_hit")
		# Visual feedback - flash
		_flash_effect()

func _flash_effect() -> void:
	if _sprite == null:
		return
	var tween := create_tween()
	_sprite.modulate = Color(2.0, 2.0, 2.0)  # Bright flash
	tween.tween_property(_sprite, "modulate", _original_modulate, 0.15)
