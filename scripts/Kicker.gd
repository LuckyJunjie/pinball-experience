extends Area2D
## Kicker - 5k on ball contact. Left/right at bottom of playfield.

const KICKER_POINTS := 5000

var _cooldown: float = 0.0

@export var is_left: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = true
	_update_sprite()

func _process(delta: float) -> void:
	if _cooldown > 0:
		_cooldown -= delta

func _update_sprite() -> void:
	var sprite = get_node_or_null("Sprite2D") as Sprite2D
	if sprite:
		var path = "res://assets/sprites/kicker/left/dimmed.png" if is_left else "res://assets/sprites/kicker/right/dimmed.png"
		sprite.texture = load(path) as Texture2D

func _on_body_entered(body: Node2D) -> void:
	if _cooldown > 0 or not body.is_in_group("ball"):
		return
	_cooldown = 0.3
	GameManager.add_score(KICKER_POINTS, name)
	if SoundManager:
		SoundManager.play_sound("obstacle_hit")
