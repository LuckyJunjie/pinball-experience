extends Node
## LevelManager - manages game levels and progression.
## Loads level configurations and handles level transitions.

signal level_started(level: int)
signal level_completed(level: int, score: int)
signal all_levels_completed()

const LEVEL_CONFIG_PATH := "res://config/levels.json"

var current_level: int = 1
var max_levels: int = 3
var level_scores: Array[int] = []
var _level_data: Array = []

func _ready() -> void:
	_load_level_data()

func _load_level_data() -> void:
	# Default level configurations
	_level_data = [
		{
			"id": 1,
			"name": "Beginner",
			"obstacle_count": 2,
			"multiplier_start": 1,
			"ball_speed": 500,
			"description": "入门级别 - 学习基础操作"
		},
		{
			"id": 2,
			"name": "Intermediate", 
			"obstacle_count": 3,
			"multiplier_start": 2,
			"ball_speed": 600,
			"description": "中级挑战 - 更多障碍物"
		},
		{
			"id": 3,
			"name": "Expert",
			"obstacle_count": 4,
			"multiplier_start": 3,
			"ball_speed": 700,
			"description": "专家难度 - 极限挑战"
		}
	]
	max_levels = _level_data.size()

func get_current_level_data() -> Dictionary:
	if current_level <= _level_data.size():
		return _level_data[current_level - 1]
	return {}

func start_level(level: int) -> void:
	if level > max_levels:
		all_levels_completed.emit()
		return
	current_level = level
	level_started.emit(current_level)

func complete_level(score: int) -> void:
	level_scores.append(score)
	level_completed.emit(current_level, score)
	if current_level < max_levels:
		current_level += 1
	else:
		all_levels_completed.emit()

func get_total_level_score() -> int:
	var total := 0
	for s in level_scores:
		total += s
	return total

func reset_progress() -> void:
	current_level = 1
	level_scores.clear()
