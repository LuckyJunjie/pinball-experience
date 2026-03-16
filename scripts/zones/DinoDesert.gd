extends Node2D
## Dino Desert - ChromeDino mouth (200k + dinoChomp bonus).

const MOUTH_POINTS := 200000

var _mouth_cooldown: float = 0.0

@onready var _mouth_sensor: Area2D = $ChromeDino/MouthSensor

func _ready() -> void:
	if _mouth_sensor:
		_mouth_sensor.body_entered.connect(_on_mouth_entered)

func _process(delta: float) -> void:
	if _mouth_cooldown > 0:
		_mouth_cooldown -= delta

func _on_mouth_entered(body: Node2D) -> void:
	if _mouth_cooldown > 0 or not body.is_in_group("ball"):
		return
	_mouth_cooldown = 0.5
	GameManager.add_score(MOUTH_POINTS, "ChromeDino")
	GameManager.add_bonus(GameManager.Bonus.DINO_CHOMP)
	if SoundManager:
		SoundManager.play_sound("hold_entry")
