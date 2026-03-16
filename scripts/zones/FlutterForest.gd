extends Node2D
## Flutter Forest - Signpost (5k), DashBumperMain (200k), DashBumperA/B (20k), dashNest bonus when all lit.

const SIGNPOST_POINTS := 5000
const DASH_MAIN_POINTS := 200000
const DASH_BUMPER_POINTS := 20000

var _signpost_cooldown: float = 0.0
var _dash_main_lit: bool = false
var _dash_a_lit: bool = false
var _dash_b_lit: bool = false
var _bumper_cooldowns: Dictionary = {}

@onready var _signpost: Area2D = $Signpost
@onready var _dash_main: Area2D = $DashBumperMain
@onready var _dash_a: Area2D = $DashBumperA
@onready var _dash_b: Area2D = $DashBumperB

func _ready() -> void:
	if _signpost:
		_signpost.body_entered.connect(_on_signpost_entered)
	if _dash_main:
		_dash_main.body_entered.connect(_on_dash_main_entered)
	for b in [_dash_a, _dash_b]:
		if b:
			b.body_entered.connect(_on_dash_bumper_entered.bind(b))

func _process(delta: float) -> void:
	if _signpost_cooldown > 0:
		_signpost_cooldown -= delta
	for k in _bumper_cooldowns.keys():
		_bumper_cooldowns[k] -= delta
		if _bumper_cooldowns[k] <= 0:
			_bumper_cooldowns.erase(k)

func _check_dash_nest() -> void:
	if _dash_main_lit and _dash_a_lit and _dash_b_lit:
		GameManager.add_bonus(GameManager.Bonus.DASH_NEST)
		_dash_main_lit = false
		_dash_a_lit = false
		_dash_b_lit = false
		_update_dash_visuals()

func _update_dash_visuals() -> void:
	var main_sprite = _dash_main.get_node_or_null("Sprite2D") as Sprite2D
	var a_sprite = _dash_a.get_node_or_null("Sprite2D") as Sprite2D
	var b_sprite = _dash_b.get_node_or_null("Sprite2D") as Sprite2D
	if main_sprite:
		main_sprite.texture = load("res://assets/sprites/dash/bumper/main/active.png" if _dash_main_lit else "res://assets/sprites/dash/bumper/main/inactive.png") as Texture2D
	if a_sprite:
		a_sprite.texture = load("res://assets/sprites/dash/bumper/a/active.png" if _dash_a_lit else "res://assets/sprites/dash/bumper/a/inactive.png") as Texture2D
	if b_sprite:
		b_sprite.texture = load("res://assets/sprites/dash/bumper/b/active.png" if _dash_b_lit else "res://assets/sprites/dash/bumper/b/inactive.png") as Texture2D

func _on_signpost_entered(body: Node2D) -> void:
	if _signpost_cooldown > 0 or not body.is_in_group("ball"):
		return
	_signpost_cooldown = 0.3
	GameManager.add_score(SIGNPOST_POINTS, "Signpost")
	if SoundManager:
		SoundManager.play_sound("obstacle_hit")

func _on_dash_main_entered(body: Node2D) -> void:
	if not body.is_in_group("ball"):
		return
	GameManager.add_score(DASH_MAIN_POINTS, "DashBumperMain")
	_dash_main_lit = true
	_update_dash_visuals()
	_check_dash_nest()
	if SoundManager:
		SoundManager.play_sound("obstacle_hit")

func _on_dash_bumper_entered(body: Node2D, bumper: Area2D) -> void:
	if body.is_in_group("ball") and bumper not in _bumper_cooldowns:
		_bumper_cooldowns[bumper] = 0.3
		GameManager.add_score(DASH_BUMPER_POINTS, bumper.name)
		if bumper == _dash_a:
			_dash_a_lit = true
		elif bumper == _dash_b:
			_dash_b_lit = true
		_update_dash_visuals()
		_check_dash_nest()
		if SoundManager:
			SoundManager.play_sound("obstacle_hit")
