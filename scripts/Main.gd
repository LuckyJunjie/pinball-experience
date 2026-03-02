extends Node2D
## Main - playfield scene. Wires GameManager, spawns ball, starts game.

@onready var balls_container: Node2D = $Balls
@onready var launcher: Node2D = $Launcher
@onready var ball_scene: PackedScene = preload("res://scenes/Ball.tscn")

func _ready() -> void:
	GameManager.balls_container = balls_container
	GameManager.launcher = launcher
	GameManager.ball_scene = ball_scene
	GameManager.start_game()
