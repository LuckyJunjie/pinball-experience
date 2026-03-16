extends Node2D
## Sparky Scorch - SparkyBumperA/B/C (20k), SparkyComputer (200k + sparkyTurboCharge bonus).

const BUMPER_POINTS := 20000
const COMPUTER_POINTS := 200000

var _computer_cooldown: float = 0.0
var _bumper_cooldowns: Dictionary = {}

@onready var _computer: Area2D = $SparkyComputer
@onready var _bumper_a: Area2D = $BumperA
@onready var _bumper_b: Area2D = $BumperB
@onready var _bumper_c: Area2D = $BumperC

func _ready() -> void:
	if _computer:
		_computer.body_entered.connect(_on_computer_entered)
	for b in [_bumper_a, _bumper_b, _bumper_c]:
		if b:
			b.body_entered.connect(_on_bumper_entered.bind(b))

func _process(delta: float) -> void:
	if _computer_cooldown > 0:
		_computer_cooldown -= delta
	for k in _bumper_cooldowns.keys():
		_bumper_cooldowns[k] -= delta
		if _bumper_cooldowns[k] <= 0:
			_bumper_cooldowns.erase(k)

func _on_computer_entered(body: Node2D) -> void:
	if _computer_cooldown > 0 or not body.is_in_group("ball"):
		return
	_computer_cooldown = 0.5
	GameManager.add_score(COMPUTER_POINTS, "SparkyComputer")
	GameManager.add_bonus(GameManager.Bonus.SPARKY_TURBO_CHARGE)
	if SoundManager:
		SoundManager.play_sound("hold_entry")

func _on_bumper_entered(body: Node2D, bumper: Area2D) -> void:
	if body.is_in_group("ball") and bumper not in _bumper_cooldowns:
		_bumper_cooldowns[bumper] = 0.3
		GameManager.add_score(BUMPER_POINTS, bumper.name)
		if SoundManager:
			SoundManager.play_sound("obstacle_hit")
