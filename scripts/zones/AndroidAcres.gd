extends Node2D
## Android Acres - SpaceshipRamp (5k, multiplier every 5 hits), bumpers (20k), spaceship (200k + bonus).

const RAMP_POINTS := 5000
const BUMPER_POINTS := 20000
const SPACESHIP_POINTS := 200000
const RAMP_HITS_PER_MULTIPLIER := 5

var _ramp_cooldown: float = 0.0
var _spaceship_cooldown: float = 0.0
var _bumper_cooldowns: Dictionary = {}

@onready var _ramp: Area2D = $SpaceshipRamp
@onready var _spaceship: Area2D = $AndroidSpaceship
@onready var _bumper_a: Area2D = $BumperA
@onready var _bumper_b: Area2D = $BumperB
@onready var _bumper_cow: Area2D = $BumperCow

func _ready() -> void:
	if _ramp:
		_ramp.body_entered.connect(_on_ramp_entered)
	if _spaceship:
		_spaceship.body_entered.connect(_on_spaceship_entered)
	for b in [_bumper_a, _bumper_b, _bumper_cow]:
		if b:
			b.body_entered.connect(_on_bumper_entered.bind(b))

func _process(delta: float) -> void:
	if _ramp_cooldown > 0:
		_ramp_cooldown -= delta
	if _spaceship_cooldown > 0:
		_spaceship_cooldown -= delta
	for k in _bumper_cooldowns.keys():
		_bumper_cooldowns[k] -= delta
		if _bumper_cooldowns[k] <= 0:
			_bumper_cooldowns.erase(k)

func _on_ramp_entered(body: Node2D) -> void:
	if _ramp_cooldown > 0 or not body.is_in_group("ball"):
		return
	_ramp_cooldown = 0.3
	GameManager.add_score(RAMP_POINTS, "SpaceshipRamp")
	if GameManager:
		GameManager.register_zone_ramp_hit("android_acres")
	if SoundManager:
		SoundManager.play_sound("obstacle_hit")

func _on_spaceship_entered(body: Node2D) -> void:
	if _spaceship_cooldown > 0 or not body.is_in_group("ball"):
		return
	_spaceship_cooldown = 0.5
	GameManager.add_score(SPACESHIP_POINTS, "AndroidSpaceship")
	GameManager.add_bonus(GameManager.Bonus.ANDROID_SPACESHIP)
	if SoundManager:
		SoundManager.play_sound("hold_entry")

func _on_bumper_entered(body: Node2D, bumper: Area2D) -> void:
	if body.is_in_group("ball") and bumper not in _bumper_cooldowns:
		_bumper_cooldowns[bumper] = 0.3
		GameManager.add_score(BUMPER_POINTS, bumper.name)
		if SoundManager:
			SoundManager.play_sound("obstacle_hit")
