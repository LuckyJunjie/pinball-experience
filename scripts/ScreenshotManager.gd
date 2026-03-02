extends Node
<<<<<<< HEAD
## ScreenshotManager - Captures game screenshots on events for CI/CD testing

signal screenshot_captured(event_id: int, filename: String)

const SCREENSHOT_DIR = "user://screenshots/"

# Event IDs
enum EventId {
	GAME_START = 1,
	BALL_SPAWN = 4,
	BALL_DRAIN = 3,
	ROUND_END = 11,
	GAME_OVER = 7,
	SCORE = 5,
	MULTIPLIER = 6,
	BONUS_ACTIVATED = 8,
	COMBO = 9,
	BONUS_BALL_SPAWN = 12,
}

var screenshot_counter: int = 0

func _ready() -> void:
	# Ensure screenshot directory exists
=======
## ScreenshotManager - 自动截图管理器
## 用于捕获游戏关键状态的截图

var screenshot_dir: String = "user://screenshots/"
var enabled: bool = true

func _ready():
	# 确保截图目录存在
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir("screenshots")

<<<<<<< HEAD
func capture_on_event(event_id: int, data: String = "") -> void:
	# Skip if no display (headless server)
	if DisplayServer.get_name() == "headless":
		return
	
	# Skip if no viewport
	var viewport = get_viewport()
	if not viewport:
		return
	
	screenshot_counter += 1
	var timestamp = Time.get_unix_time_from_system()
	var filename = "event_%02d_%s_%d.png" % [event_id, data if data else "default", screenshot_counter]
	var filepath = SCREENSHOT_DIR + filename
	
	# Capture screenshot
	await viewport.get_texture().get_image().save_png(filepath)
	screenshot_captured.emit(event_id, filename)

func capture_current_screen() -> void:
	capture_on_event(0, "manual")
=======
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# 游戏关闭时保存截图
		capture_screenshot("game_exit")

## 捕获截图
## @param state_name: 游戏状态名称 (如 "ball_launch", "ball_drain", "flipper_hit")
func capture_screenshot(state_name: String = "") -> String:
	if not enabled:
		return ""
	
	var viewport = get_viewport()
	if not viewport:
		printerr("ScreenshotManager: No viewport found")
		return ""
	
	# 获取图像
	var image = viewport.get_texture().get_image()
	if not image:
		printerr("ScreenshotManager: Failed to get image from viewport")
		# 尝试创建蓝色测试图像
		image = Image.create(viewport.size.x, viewport.size.y, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 1, 1))
	
	# 生成文件名
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "screenshot_" + state_name + "_" + timestamp + ".png"
	var filepath = screenshot_dir + filename
	
	# 保存图像
	var error = image.save_png(filepath)
	if error != OK:
		printerr("ScreenshotManager: Failed to save screenshot: " + filepath)
		return ""
	
	print("ScreenshotManager: Screenshot saved: " + filepath)
	return filepath

## 从命令行参数触发截图
## 使用方式: godot --headless --path . -s screenshot_trigger.gd -- ball_launch
func trigger_from_args():
	var args = OS.get_cmdline_args()
	for i in range(args.size()):
		if args[i] == "--screenshot" and i + 1 < args.size():
			var state = args[i + 1]
			print("Triggering screenshot for state: ", state)
			await get_tree().create_timer(1.0).timeout
			capture_screenshot(state)
			await get_tree().create_timer(0.5).timeout
			get_tree().quit()
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
