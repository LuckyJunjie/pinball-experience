extends Node
## ComboManager - 连击系统核心逻辑
## 快速连续击中目标时触发连击，提供额外分数加成

signal combo_increased(new_combo: int)
signal combo_reset()
signal combo_timeout()

# Combo 状态
var combo_count: int = 0          # 当前连击数 (0 = 无连击)
var combo_timer: float = 0.0       # 倒计时计时器

# 配置
const COMBO_TIMEOUT: float = 2.0  # 连击超时时间 (秒)
const MAX_COMBO: int = 10         # 最大连击数上限

# 引用
var game_manager: Node = null

func _ready() -> void:
	# 获取 GameManager 引用
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager == null:
		# 尝试直接获取
		game_manager = get_node_or_null("/root/Main/GameManager")
	
	# 注意: scored 信号连接由 Main.gd 负责，避免重复连接


func _process(delta: float) -> void:
	# 更新 Combo 计时器
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			_reset_combo()


func _on_scored(_points: int, source: String) -> void:
	# 忽略某些不计入 Combo 的来源 (如 Skill Shot)
	if _should_count_combo(source):
		_increase_combo()


func _should_count_combo(_source: String) -> bool:
	# 可以在这里过滤某些不计 Combo 的得分来源
	# 目前所有来源都计入 Combo
	return true


func _increase_combo() -> void:
	if combo_count < MAX_COMBO:
		combo_count += 1
	else:
		# Combo 已满，保持最大值但刷新计时器
		pass
	
	# 重置计时器
	combo_timer = COMBO_TIMEOUT
	
	# 发出信号
	combo_increased.emit(combo_count)

# 公开方法: 由 GameManager 在得分前调用
func increase_combo() -> void:
	"""增加连击数 (由 GameManager 在 add_score 时调用)"""
	_increase_combo()


func _reset_combo() -> void:
	if combo_count > 0:
		combo_timeout.emit()
		combo_count = 0
		combo_timer = 0.0
		combo_reset.emit()


func get_combo_multiplier() -> int:
	"""返回当前 Combo 倍率
	combo_count=0 → x1 (无连击)
	combo_count=1 → x2 (1次连击后)
	combo_count=2 → x3 (2次连击后)
	"""
	return combo_count + 1


func get_combo_count() -> int:
	"""返回当前 Combo 计数"""
	return combo_count


func get_combo_timer() -> float:
	"""返回当前剩余计时器时间"""
	return combo_timer


func get_combo_timeout() -> float:
	"""返回 Combo 超时时间"""
	return COMBO_TIMEOUT


func force_reset() -> void:
	"""强制重置 Combo (如回合结束时)"""
	_reset_combo()


# 用于计算带 Combo 加成的分数
func calculate_combo_score(base_points: int) -> int:
	"""计算带 Combo 加成的分数"""
	return base_points * get_combo_multiplier()
