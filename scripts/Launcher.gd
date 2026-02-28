extends Node2D
## Launcher - handles ball spawn and launch. Space/Down to launch.

@onready var spawn_point: Node2D = $SpawnPoint
@onready var plunger_visual: Sprite2D = $PlungerVisual

var _ball: RigidBody2D = null
var _launch_ready: bool = false

func _ready() -> void:
	GameManager.ball_spawn_requested.connect(_on_spawn_requested)

func _physics_process(_delta: float) -> void:
	if _ball != null and _launch_ready and Input.is_action_just_pressed("launch_ball"):
		_launch_ball()

func get_spawn_position() -> Vector2:
	if spawn_point:
		return spawn_point.global_position
	return global_position

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
	if SoundManager:
		SoundManager.play_sound("ball_launch")
	# 截图：球生成
	_get_screenshot_manager().capture_on_event(4) # BALL_SPAWN

func _launch_ball() -> void:
	if _ball == null:
		return
	_ball.freeze = false
	_ball.apply_central_impulse(Vector2(300, -400))
	_ball = null
	_launch_ready = false
	# 截图：球发射
	_get_screenshot_manager().capture_on_event(2) # BALL_LAUNCH

func _get_screenshot_manager() -> Node:
	# 尝试获取ScreenshotManager节点
	var sm = get_tree().get_first_node_in_group("screenshot_manager")
	if sm:
		return sm
	# 尝试从场景中查找
	var main = get_tree().current_scene
	if main and main.has_node("ScreenshotManager"):
		return main.get_node("ScreenshotManager")
	return null
