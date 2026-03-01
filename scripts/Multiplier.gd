extends Node
## Multiplier - 倍率管理器
## 管理游戏倍率(1-6)，回合结束时应用倍率

signal multiplier_changed(value: int)

@export var max_multiplier: int = 6
@export var trigger_interval: int = 5  # 每5次触发增加倍率

var current_multiplier: int = 1
var trigger_count: int = 0

func _ready():
	reset()

func increase_multiplier() -> void:
	"""增加倍率"""
	if current_multiplier < max_multiplier:
		current_multiplier += 1
		multiplier_changed.emit(current_multiplier)
		print("[Multiplier] Increased to ", current_multiplier)
	else:
		print("[Multiplier] Already at max (", max_multiplier, ")")

func decrease_multiplier() -> void:
	"""减少倍率"""
	if current_multiplier > 1:
		current_multiplier -= 1
		multiplier_changed.emit(current_multiplier)

func reset() -> void:
	"""重置倍率到1"""
	current_multiplier = 1
	trigger_count = 0
	multiplier_changed.emit(current_multiplier)
	print("[Multiplier] Reset to 1")

func add_trigger() -> void:
	"""添加一次触发，每trigger_interval次增加倍率"""
	trigger_count += 1
	
	# 每trigger_interval次触发增加倍率
	if trigger_count >= trigger_interval:
		increase_multiplier()
		trigger_count = 0
		print("[Multiplier] Trigger count reset, multiplier: ", current_multiplier)

func get_multiplier() -> int:
	"""获取当前倍率"""
	return current_multiplier

func apply_to_score(round_score: int) -> int:
	"""将倍率应用到回合得分"""
	return round_score * current_multiplier
