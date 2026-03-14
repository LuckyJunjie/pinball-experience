extends Node
## GameManager - central game state (rounds, score, multiplier, bonuses).
## Spawns ball at launcher and notifies Launcher via set_ball(); Drain/ball pool trigger round_lost.

enum Status { WAITING, PLAYING, GAME_OVER }
enum Bonus { GOOGLE_WORD, DASH_NEST, SPARKY_TURBO_CHARGE, DINO_CHOMP, ANDROID_SPACESHIP }

signal scored(points: int)
signal round_lost()
signal bonus_activated(bonus: Bonus)
signal multiplier_increased()
signal game_over()
signal game_started()
signal zone_ramp_hit(zone_name: String, hit_count: int)
signal character_theme_changed(theme_key: String)

const MAX_SCORE: int = 9999999999
const INITIAL_ROUNDS: int = 3
const MAX_MULTIPLIER: int = 6
const BONUS_BALL_DELAY: float = 5.0
const RAMP_HITS_PER_MULTIPLIER: int = 5

const BallPoolScript := preload("res://scripts/BallPool.gd")
const DEBUG_LOGS := true

var round_score: int = 0
var total_score: int = 0
var multiplier: int = 1
var rounds: int = INITIAL_ROUNDS
var bonus_history: Array[Bonus] = []
var status: Status = Status.WAITING
var balls_container: Node2D = null
var ball_scene: PackedScene = null:
	set(value):
		ball_scene = value
		_ball_scene_ready = true
		if balls_container:
			call_deferred("_initialize_ball_pool")
var launcher_node: Node = null
var launcher_spawn_position: Vector2 = Vector2(400, 500)
var bonus_ball_spawn_position: Vector2 = Vector2(400, 300)
var bonus_ball_impulse: Vector2 = Vector2(-200, 0)
var bonus_ball_timer: float = -1.0
var selected_character_theme: String = "sparky"

var _ball_scene_ready: bool = false
var zone_ramp_hits: Dictionary = {
	"android_acres": 0,
	"dino_desert": 0,
	"google_gallery": 0,
	"flutter_forest": 0,
	"sparky_scorch": 0
}

func _ready() -> void:
	add_to_group("game_manager")
	_add_input_actions()
	call_deferred("_initialize_ball_pool")

func _process(delta: float) -> void:
	if bonus_ball_timer > 0.0:
		bonus_ball_timer -= delta
		if bonus_ball_timer <= 0.0:
			bonus_ball_timer = -1.0
			_spawn_bonus_ball()

func _add_input_actions() -> void:
	if not InputMap.has_action("flipper_left"):
		InputMap.add_action("flipper_left")
		InputMap.action_add_event("flipper_left", _key(KEY_LEFT))
		InputMap.action_add_event("flipper_left", _key(KEY_A))
	if not InputMap.has_action("flipper_right"):
		InputMap.add_action("flipper_right")
		InputMap.action_add_event("flipper_right", _key(KEY_RIGHT))
		InputMap.action_add_event("flipper_right", _key(KEY_D))
	if not InputMap.has_action("launch_ball"):
		InputMap.add_action("launch_ball")
		InputMap.action_add_event("launch_ball", _key(KEY_SPACE))
		InputMap.action_add_event("launch_ball", _key(KEY_DOWN))

func _key(keycode: int) -> InputEventKey:
	var e := InputEventKey.new()
	e.keycode = keycode
	return e

func _initialize_ball_pool() -> void:
	if not ball_scene or not balls_container:
		return
	var ball_pool = BallPoolScript.get_instance()
	if ball_pool and not ball_pool.is_initialized():
		ball_pool.initialize(ball_scene, balls_container)
	elif ball_pool and ball_pool.is_initialized():
		pass
	else:
		pass

func _ensure_ball_pool_initialized() -> void:
	if ball_scene and balls_container:
		var ball_pool = BallPoolScript.get_instance()
		if ball_pool:
			ball_pool.initialize(ball_scene, balls_container)

func display_score() -> int:
	return mini(round_score + total_score, MAX_SCORE)

func get_display_score() -> int:
	return display_score()

func add_score(points: int, _source: String = "") -> void:
	if status != Status.PLAYING:
		return
	round_score += points
	round_score = mini(round_score, MAX_SCORE)
	scored.emit(points)

func on_round_lost() -> void:
	if status != Status.PLAYING:
		return
	if DEBUG_LOGS:
		print("[Pinball][GameManager] on_round_lost (rounds was ", rounds, ")")
	var final_round = round_score * multiplier
	total_score = mini(total_score + final_round, MAX_SCORE)
	round_score = 0
	multiplier = 1
	rounds = maxi(0, rounds - 1)
	reset_zone_tracking()
	round_lost.emit()
	if rounds <= 0:
		status = Status.GAME_OVER
		game_over.emit()
	else:
		_spawn_ball_at_launcher()

func increase_multiplier() -> void:
	if status != Status.PLAYING or multiplier >= MAX_MULTIPLIER:
		return
	multiplier += 1
	multiplier_increased.emit()

func add_bonus(bonus: Bonus) -> void:
	bonus_history.append(bonus)
	bonus_activated.emit(bonus)
	match bonus:
		Bonus.GOOGLE_WORD, Bonus.DASH_NEST:
			bonus_ball_timer = BONUS_BALL_DELAY
		Bonus.ANDROID_SPACESHIP:
			add_score(200000)
		Bonus.DINO_CHOMP:
			add_score(150000)
		Bonus.SPARKY_TURBO_CHARGE:
			add_score(100000)

func register_zone_ramp_hit(zone_name: String) -> void:
	if status != Status.PLAYING:
		return
	if zone_ramp_hits.has(zone_name):
		zone_ramp_hits[zone_name] += 1
	else:
		zone_ramp_hits[zone_name] = 1
	var hit_count = zone_ramp_hits[zone_name]
	zone_ramp_hit.emit(zone_name, hit_count)
	var total_ramp_hits = 0
	for z in zone_ramp_hits:
		total_ramp_hits += zone_ramp_hits[z]
	if total_ramp_hits % RAMP_HITS_PER_MULTIPLIER == 0:
		increase_multiplier()

func set_character_theme(theme_key: String) -> void:
	if theme_key in ["sparky", "dino", "dash", "android"]:
		selected_character_theme = theme_key
		character_theme_changed.emit(theme_key)

func get_character_theme() -> String:
	return selected_character_theme

func reset_zone_tracking() -> void:
	for z in zone_ramp_hits:
		zone_ramp_hits[z] = 0

func _return_all_balls_to_pool() -> void:
	var ball_pool = BallPoolScript.get_instance()
	if ball_pool and ball_pool.is_initialized() and balls_container:
		for child in balls_container.get_children():
			if child is RigidBody2D and child.is_in_group("balls"):
				ball_pool.return_ball(child)

func start_game() -> void:
	if DEBUG_LOGS:
		print("[Pinball][GameManager] start_game launcher_spawn_position=%s" % launcher_spawn_position)
	round_score = 0
	total_score = 0
	multiplier = 1
	rounds = INITIAL_ROUNDS
	bonus_history.clear()
	reset_zone_tracking()
	status = Status.PLAYING
	_return_all_balls_to_pool()
	game_started.emit()
	_spawn_ball_at_launcher()

func get_ball_count() -> int:
	var ball_pool = BallPoolScript.get_instance()
	if ball_pool and ball_pool.is_initialized():
		return ball_pool.get_active_ball_count()
	if not balls_container:
		return 0
	var n := 0
	for c in balls_container.get_children():
		if c is RigidBody2D and c.is_in_group("balls"):
			n += 1
	return n

func _spawn_ball_at_launcher() -> void:
	if not ball_scene or not balls_container:
		if DEBUG_LOGS:
			print("[Pinball][GameManager] _spawn_ball_at_launcher skipped: no ball_scene or balls_container")
		return
	_ensure_ball_pool_initialized()
	var ball_pool = BallPoolScript.get_instance()
	var ball: RigidBody2D = null
	if ball_pool and ball_pool.is_initialized():
		ball = ball_pool.spawn_ball_at_position(launcher_spawn_position, Vector2.ZERO, true)
		if DEBUG_LOGS:
			print("[Pinball][GameManager] _spawn_ball_at_launcher pos=%s ball_valid=%s rounds=%d" % [launcher_spawn_position, ball != null, rounds])
	if not ball:
		ball = ball_scene.instantiate()
		balls_container.add_child(ball)
		if ball.has_signal("ball_lost"):
			ball.ball_lost.connect(_on_ball_lost)
		if DEBUG_LOGS:
			print("[Pinball][GameManager] spawn direct instantiate")
	if ball:
		ball.freeze = true
		ball.global_position = launcher_spawn_position
		ball.visible = true
		if ball.has_method("reset_ball"):
			ball.reset_ball()
		if ball.get("initial_position") != null:
			ball.initial_position = launcher_spawn_position
		if launcher_node and launcher_node.has_method("set_ball"):
			launcher_node.set_ball(ball)
			if DEBUG_LOGS:
				print("[Pinball][GameManager] set_ball called on launcher")
		elif DEBUG_LOGS:
			print("[Pinball][GameManager] WARNING: no launcher_node or set_ball")

func _spawn_bonus_ball() -> void:
	if not ball_scene or not balls_container:
		return
	var ball_pool = BallPoolScript.get_instance()
	var ball: RigidBody2D = null
	if ball_pool and ball_pool.is_initialized():
		ball = ball_pool.spawn_ball_at_position(bonus_ball_spawn_position, bonus_ball_impulse)
	if not ball:
		ball = ball_scene.instantiate() as RigidBody2D
		balls_container.add_child(ball)
		ball.global_position = bonus_ball_spawn_position
		if ball.has_method("reset_ball"):
			ball.reset_ball()
		if ball.get("initial_position") != null:
			ball.initial_position = bonus_ball_spawn_position
		if ball.has_signal("ball_lost"):
			ball.ball_lost.connect(_on_ball_lost)
	ball.freeze = false
	ball.apply_central_impulse(bonus_ball_impulse)

func _on_ball_lost() -> void:
	if DEBUG_LOGS:
		print("[Pinball][GameManager] _on_ball_lost signal received")
