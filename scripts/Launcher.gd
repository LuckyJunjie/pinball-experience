extends Node2D
## Launcher - handles ball spawn and launch. Space/Down to launch.

@onready var spawn_point: Node2D = $SpawnPoint
@onready var plunger_visual: Sprite2D = $PlungerVisual

var _ball: RigidBody2D = null
var _launch_ready: bool = false

const PLUNGER_SHEET_PATH := "res://assets/sprites/plunger/plunger.png"
const PLUNGER_FRAME_COUNT := 20

func _ready() -> void:
	GameManager.ball_spawn_requested.connect(_on_spawn_requested)
	_setup_plunger_visual()

func _setup_plunger_visual() -> void:
	if not plunger_visual:
		return
	var sheet := load(PLUNGER_SHEET_PATH) as Texture2D
	if sheet == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var fw := sheet.get_width() / PLUNGER_FRAME_COUNT
	atlas.region = Rect2i(0, 0, fw, sheet.get_height())
	plunger_visual.texture = atlas

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

func _launch_ball() -> void:
	if _ball == null:
		return
	_ball.freeze = false
	# Impulse tuned so ball stays on playfield (~200px peak); mass 0.5, g=980
	_ball.apply_central_impulse(Vector2(0, -320))
	
	# 激活技能射击
	_activate_skill_shot()
	
	_ball = null
	_launch_ready = false

func _activate_skill_shot() -> void:
	# 查找并激活 SkillShot
	var skill_shot = get_tree().get_first_node_in_group("skill_shot")
	if skill_shot and skill_shot.has_method("activate"):
		skill_shot.activate()
		print("Launcher: SkillShot 已激活")
