extends Node
## ScreenshotManager - 自动截图管理器
## 可以在游戏关键事件时自动截图：球发射、球掉落、得分等
## 支持命令行参数触发截图

signal screenshot_captured(path: String, event: String)

var screenshot_dir: String = "user://screenshots"
var enabled: bool = true
var capture_on_events: bool = true

# 截图事件类型
enum ScreenshotEvent {
	NONE = 0,
	GAME_START = 1,          # 游戏开始
	BALL_LAUNCH = 2,        # 球发射
	BALL_DRAIN = 3,         # 球掉落
	BALL_SPAWN = 4,         # 球生成
	SCORE = 5,              # 得分
	MULTIPLIER = 6,         # 倍率变化
	GAME_OVER = 7,          # 游戏结束
	FLIPPER = 8,            # 挡板动作
	OBSTACLE_HIT = 9,       # 障碍物碰撞
	ROUND_START = 10,        # 回合开始
	ROUND_END = 11           # 回合结束
}

# 当前待捕获的事件队列
var pending_events: Array = []

func _ready() -> void:
	# 创建目录
	截图DirAccess.make_dir_recursive_absolute(screenshot_dir)
	
	# 检查命令行参数
	_check_command_line_args()
	
	print("[ScreenshotManager] 已初始化，截图目录: ", screenshot_dir)

func _check_command_line_args() -> void:
	var args = OS.get_cmdline_args()
	
	for arg in args:
		if arg == "--screenshot" or arg == "-s":
			# 立即截图
			await get_tree().process_frame
			capture_screenshot("command_line")
		elif arg.begins_with("--screenshot-on="):
			# 指定事件截图
			var event_name = arg.replace("--screenshot-on=", "")
			_enable_event_capture(event_name)
		elif arg.begins_with("--screenshot-after="):
			# 延迟截图（毫秒）
			var delay_ms = arg.replace("--screenshot-after=", "").to_int()
			await get_tree().create_timer(delay_ms / 1000.0).timeout
			capture_screenshot("delayed")

func _enable_event_capture(event_name: String) -> void:
	capture_on_events = true
	print("[ScreenshotManager] 启用事件截图: ", event_name)

func capture_screenshot(event: String = "manual") -> String:
	if not enabled:
		return ""
	
	# 获取当前时间戳
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_")
	var filename = "screenshot_" + event + "_" + timestamp + ".png"
	var filepath = screenshot_dir + "/" + filename
	
	# 截取viewport图像
	var viewport = get_viewport()
	if viewport:
		var image = viewport.get_texture().get_image()
		if image:
			var error = image.save_png(filepath)
			if error == OK:
				print("[ScreenshotManager] 截图已保存: ", filepath)
				screenshot_captured.emit(filepath, event)
				return filepath
			else:
				print("[ScreenshotManager] 截图失败，错误码: ", error)
	
	return ""

# ==================== 公开接口 ====================

func capture_on_event(event: ScreenshotEvent, tag: String = "") -> void:
	if not capture_on_events:
		return
	
	var event_name = ScreenshotEvent.keys()[event]
	if tag:
		event_name += "_" + tag
	
	# 延迟一帧确保渲染完成
	await get_tree().process_frame
	capture_screenshot(event_name)

# ==================== 游戏事件监听 ====================

func _on_game_started() -> void:
	capture_on_event(ScreenshotEvent.GAME_START)

func _on_ball_launched() -> void:
	capture_on_event(ScreenshotEvent.BALL_LAUNCH)

func _on_ball_drained() -> void:
	capture_on_event(ScreenshotEvent.BALL_DRAIN)

func _on_ball_spawned() -> void:
	capture_on_event(ScreenshotEvent.BALL_SPAWN)

func _on_score_changed(points: int, source: String) -> void:
	capture_on_event(ScreenshotEvent.SCORE, source)

func _on_multiplier_changed(new_value: int) -> void:
	capture_on_event(ScreenshotEvent.MULTIPLIER, str(new_value))

func _on_game_over(final_score: int) -> void:
	capture_on_event(ScreenshotEvent.GAME_OVER, str(final_score))

func _on_round_lost(final_round_score: int, multiplier_val: int) -> void:
	capture_on_event(ScreenshotEvent.ROUND_END, str(final_round_score))

func _on_round_started() -> void:
	capture_on_event(ScreenshotEvent.ROUND_START)

# ==================== 静态工具方法 ====================

static func get_latest_screenshot() -> String:
	# 返回最新的截图文件路径
	var dir = DirAccess.open("user://screenshots")
	if dir:
		var files = dir.get_files()
		if files.size() > 0:
			files.sort()
			return "user://screenshots/" + files[-1]
	return ""
