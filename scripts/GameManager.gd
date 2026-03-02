extends Node
## GameManager - central game state (BASELINE 0.5 target-shaped state).
## roundScore, totalScore, multiplier (1-6), rounds (3), status, bonusHistory.
## Implements: FR-1.2.x, FR-1.5.x, TR-3.3, TR-3.4

signal scored(points: int, source: String)
signal round_lost(final_round_score: int, multiplier_val: int)
signal bonus_activated(bonus_type: String)
signal multiplier_increased(new_value: int)
signal game_over(final_score: int)
signal game_started()
signal ball_spawn_requested

# State (target-shaped for Phase 2)
var round_score: int = 0
var total_score: int = 0
var multiplier: int = 1
var rounds: int = 3
var status: String = "waiting"  # waiting | playing | gameOver
var bonus_history: Array[String] = []

# Multiplier tracking
var _ramp_shot_count: int = 0
const RAMP_SHOTS_FOR_MULTIPLIER := 5

# References (set by Main)
var balls_container: Node2D
var launcher: Node2D
var ball_scene: PackedScene
var combo_manager: Node = null  # ComboManager reference

const MAX_SCORE := 9999999999

func _ready() -> void:
	_add_input_actions()
	# 延迟获取 ComboManager 引用 (确保场景加载完成)
	call_deferred("_get_combo_manager_ref")

func _get_combo_manager_ref() -> void:
	combo_manager = get_node_or_null("../ComboManager")
	if combo_manager == null:
		combo_manager = get_node_or_null("/root/Main/ComboManager")

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
	e.keycode = keycode as Key
	return e

func start_game() -> void:
	round_score = 0
	total_score = 0
	multiplier = 1
	rounds = 3
	status = "playing"
	bonus_history.clear()
	game_started.emit()
	spawn_ball_at_launcher()

func spawn_ball_at_launcher() -> void:
	ball_spawn_requested.emit()

func get_ball_count() -> int:
	if balls_container == null:
		return 0
	return balls_container.get_child_count()

func on_ball_removed() -> void:
	if get_ball_count() <= 0:
		on_round_lost()

func on_round_lost() -> void:
	var final_round := round_score
	var mult := multiplier
	total_score += final_round * mult
	total_score = mini(total_score, MAX_SCORE)
	round_score = 0
	multiplier = 1
	rounds -= 1
	round_lost.emit(final_round, mult)
	if rounds <= 0:
		status = "gameOver"
		game_over.emit(total_score)
	else:
		spawn_ball_at_launcher()

func add_score(points: int, source: String = "") -> void:
	if status != "playing":
		return
	
	# 先增加 Combo (如果在连击中)
	var combo_multiplier := 1
	if combo_manager != null and combo_manager.has_method("increase_combo"):
		combo_manager.increase_combo()
		combo_multiplier = combo_manager.get_combo_multiplier()
	
	var final_points := points * combo_multiplier
	round_score += final_points
	round_score = mini(round_score, MAX_SCORE)
	scored.emit(final_points, source)

func get_display_score() -> int:
	return mini(round_score + total_score, MAX_SCORE)

func increase_multiplier() -> void:
	if multiplier < 6:
		multiplier += 1
		multiplier_increased.emit(multiplier)

func add_bonus(bonus_type: String) -> void:
	if bonus_type not in bonus_history:
		bonus_history.append(bonus_type)
	bonus_activated.emit(bonus_type)

# Called when player completes a ramp shot - increases multiplier
func on_ramp_shot() -> void:
	if status != "playing":
		return
	_ramp_shot_count += 1
	if _ramp_shot_count >= RAMP_SHOTS_FOR_MULTIPLIER:
		_ramp_shot_count = 0
		increase_multiplier()
