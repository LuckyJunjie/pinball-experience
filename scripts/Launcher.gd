extends Node2D
## Launcher - handles ball spawn and launch with power charging.
## Hold Space/Down to charge, release to launch.

signal power_changed(power: float)  # 0.0 to 1.0

@onready var spawn_point: Node2D = $SpawnPoint
@onready var plunger_visual: Sprite2D = $PlungerVisual

# Launch parameters
const MIN_LAUNCH_FORCE := 500.0
const MAX_LAUNCH_FORCE := 2000.0
const CHARGE_TIME := 2.0  # seconds to reach max power

var _ball: RigidBody2D = null
var _launch_ready: bool = false
var _is_charging: bool = false
var _current_power: float = 0.0  # 0.0 to 1.0

func _ready() -> void:
	GameManager.ball_spawn_requested.connect(_on_spawn_requested)

func _process(delta: float) -> void:
	# Handle charging
	if _launch_ready and _ball != null:
		if Input.is_action_pressed("launch_ball"):
			if not _is_charging:
				_is_charging = true
				_current_power = 0.0
			_charge_power(delta)
		elif _is_charging and not Input.is_action_pressed("launch_ball"):
			# Release to launch
			_launch_ball()
			_is_charging = false
			_current_power = 0.0
			power_changed.emit(0.0)
		
		# Update visual
		_update_plunger_visual()

func _charge_power(delta: float) -> void:
	_current_power = min(_current_power + delta / CHARGE_TIME, 1.0)
	power_changed.emit(_current_power)

func _update_plunger_visual() -> void:
	if plunger_visual:
		# Visual feedback: pull back plunger based on power
		var pull_distance := _current_power * 50.0
		plunger_visual.position.y = pull_distance

func get_spawn_position() -> Vector2:
	if spawn_point:
		return spawn_point.global_position
	return global_position

func get_current_power() -> float:
	return _current_power

func _on_spawn_requested() -> void:
	_spawn_ball()

func _spawn_ball() -> void:
	if GameManager.ball_scene == null or GameManager.balls_container == null:
		return
	var ball := GameManager.ball_scene.instantiate() as RigidBody2D
	ball.global_position = get_spawn_position()
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0
	ball.freeze = true
	GameManager.balls_container.add_child(ball)
	_ball = ball
	_launch_ready = true
	_current_power = 0.0
	if SoundManager:
		SoundManager.play_sound("ball_launch")

func _launch_ball() -> void:
	if _ball == null:
		return
	
	# Calculate launch force based on power
	var launch_force := lerp(MIN_LAUNCH_FORCE, MAX_LAUNCH_FORCE, _current_power)
	
	_ball.freeze = false
	_ball.apply_central_impulse(Vector2(0, -launch_force))
	
	# Play launch sound with pitch based on power
	if SoundManager:
		SoundManager.play_sound("ball_launch", 0.8 + _current_power * 0.4)
	
	# 激活技能射击
	_activate_skill_shot()
	
	_ball = null
	_launch_ready = false
	_current_power = 0.0

func _activate_skill_shot() -> void:
	# 查找并激活 SkillShot
	var skill_shot = get_tree().get_first_node_in_group("skill_shot")
	if skill_shot and skill_shot.has_method("activate"):
		skill_shot.activate()
		print("Launcher: SkillShot 已激活")
