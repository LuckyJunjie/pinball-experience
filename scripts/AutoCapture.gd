## 自动截图集成脚本
## 集成到游戏管理器中，在关键事件时自动截图

extends Node

# 截图配置
var screenshot_enabled: bool = true
var screenshot_quality: float = 1.0  # 1.0 = 原始质量
var screenshot_dir: String = "user://screenshots/"

# 截图状态
var last_screenshot: String = ""
var screenshot_queue: Array = []

func _ready():
	# 确保目录存在
	DirAccess.make_dir_recursive_absolute("user://screenshots")

## 在球发射时截图
func capture_ball_launch():
	if screenshot_enabled:
		capture_state("ball_launch")

## 在球碰撞挡板时截图
func capture_flipper_hit():
	if screenshot_enabled:
		capture_state("flipper_hit")

## 在球掉落drain时截图
func capture_ball_drain():
	if screenshot_enabled:
		capture_state("ball_drain")

## 在球碰撞障碍物时截图
func capture_obstacle_hit(obstacle_name: String = "obstacle"):
	if screenshot_enabled:
		capture_state("obstacle_hit_" + obstacle_name)

## 在得分时截图
func capture_score(points: int):
	if screenshot_enabled:
		capture_state("score_" + str(points))

## 在游戏结束时截图
func capture_game_over():
	if screenshot_enabled:
		capture_state("game_over")

## 通用截图函数
func capture_state(state_name: String) -> String:
	var viewport = get_viewport()
	if not viewport:
		printerr("Screenshot: No viewport")
		return ""
	
	var image = viewport.get_texture().get_image()
	if not image or image.get_width() == 0:
		printerr("Screenshot: Failed to get image")
		return ""
	
	# 生成文件名
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = state_name + "_" + timestamp + ".png"
	var filepath = screenshot_dir + filename
	
	# 调整质量
	if screenshot_quality < 1.0:
		var w = int(image.get_width() * screenshot_quality)
		var h = int(image.get_height() * screenshot_quality)
		image.resize(w, h)
	
	var error = image.save_png(filepath)
	if error != OK:
		printerr("Screenshot: Failed to save " + filepath)
		return ""
	
	last_screenshot = filepath
	print("Screenshot captured: " + filepath)
	return filepath

## 从外部调用截图 (通过信号或命令)
func trigger_screenshot(state_name: String):
	capture_state(state_name)
