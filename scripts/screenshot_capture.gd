# screenshot_capture.gd
extends Node
## 自动截图模块 - 监听游戏事件并自动截图

signal screenshot_captured(path: String)

@export var screenshot_dir: String = "user://screenshots/"
@export var capture_on_game_start: bool = true
@export var capture_on_drain: bool = true

func _ready() -> void:
	# 确保截图目录存在
	DirAccess.make_dir_recursive_absolute(screenshot_dir)
	
	# 连接游戏事件
	if capture_on_game_start and GameManager:
		GameManager.game_started.connect(_on_game_started)
	
	if capture_on_drain and GameManager:
		GameManager.round_lost.connect(_on_round_lost)

func _on_game_started() -> void:
	await get_tree().create_timer(0.5).timeout
	capture_screenshot("game_start")

func _on_round_lost(final_round_score: int, multiplier_val: int) -> void:
	await get_tree().create_timer(0.3).timeout
	capture_screenshot("drain")

func capture_screenshot(prefix: String = "screenshot") -> void:
	var viewport = get_viewport()
	if viewport:
		var tex = viewport.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
				var filename = "%s_%s.png" % [prefix, timestamp]
				var path = screenshot_dir + filename
				img.save_png(path)
				print("[Screenshot] 已保存: ", path)
				screenshot_captured.emit(path)

# 手动触发截图的公开方法
func manual_capture(name: String = "manual") -> void:
	capture_screenshot(name)
