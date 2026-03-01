extends Node2D
## Main - playfield scene. Wires GameManager, spawns ball, starts game.

@onready var balls_container: Node2D = $Balls
@onready var launcher: Node2D = $Launcher
@onready var ball_scene: PackedScene = preload("res://scenes/Ball.tscn")
@onready var screenshot_manager: Node = $ScreenshotManager
@onready var combo_manager: Node = $ComboManager

func _ready() -> void:
	# 设置GameManager引用 (GameManager 是 autoload singleton)
	GameManager.balls_container = balls_container
	GameManager.launcher = launcher
	GameManager.ball_scene = ball_scene
	
	# 连接GameManager信号到ScreenshotManager
	GameManager.game_started.connect(_on_game_started)
	GameManager.ball_spawn_requested.connect(_on_ball_spawn_requested)
	GameManager.round_lost.connect(_on_round_lost)
	GameManager.game_over.connect(_on_game_over)
	GameManager.scored.connect(_on_scored)
	GameManager.multiplier_increased.connect(_on_multiplier_increased)
	
	# 连接 GameManager 信号到 ComboManager
	GameManager.game_started.connect(combo_manager.force_reset)
	GameManager.round_lost.connect(combo_manager.force_reset)
	
	# 开始游戏
	GameManager.start_game()

func _on_game_started() -> void:
	screenshot_manager.capture_on_event(1) # GAME_START

func _on_ball_spawn_requested() -> void:
	screenshot_manager.capture_on_event(4) # BALL_SPAWN

func _on_round_lost(_final_round_score: int, _multiplier_val: int) -> void:
	screenshot_manager.capture_on_event(3) # BALL_DRAIN
	screenshot_manager.capture_on_event(11) # ROUND_END

func _on_game_over(_final_score: int) -> void:
	screenshot_manager.capture_on_event(7) # GAME_OVER

func _on_scored(_points: int, source: String) -> void:
	screenshot_manager.capture_on_event(5, source) # SCORE

func _on_multiplier_increased(new_value: int) -> void:
	screenshot_manager.capture_on_event(6, str(new_value)) # MULTIPLIER
