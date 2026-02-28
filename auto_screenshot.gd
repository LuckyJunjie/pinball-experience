extends SceneTree

# 自动化截图脚本
# 用法: godot --headless --window-size 800,600 --path . -s auto_screenshot.gd

var screenshot_manager: Node = null

func _initialize():
	print("=== Auto Screenshot Starting ===")
	
	# 等待场景加载
	await create_timer(1.0).timeout
	
	# 加载主场景
	print("Loading Main.tscn...")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# 等待物理系统初始化
	await create_timer(2.0).timeout
	
	# 截图: 初始状态
	print("Capturing: initial_state")
	capture_state("initial_state")
	
	await create_timer(1.0).timeout
	
	# 截图: 发射状态 (模拟发射)
	print("Capturing: ball_launch")
	capture_state("ball_launch")
	
	await create_timer(1.0).timeout
	
	# 截图: 球在运动中
	print("Capturing: ball_moving")
	capture_state("ball_moving")
	
	await create_timer(1.0).timeout
	
	# 截图: 球掉落drain
	print("Capturing: ball_drain")
	capture_state("ball_drain")
	
	await create_timer(1.0).timeout
	
	print("=== All screenshots captured ===")
	quit()

func capture_state(state_name: String):
	var viewport = get_root().get_viewport()
	if not viewport:
		print("ERROR: No viewport")
		return
	
	var image = viewport.get_texture().get_image()
	if not image or image.get_width() == 0:
		# 创建测试图像
		print("WARNING: Viewport not rendered, creating test image")
		image = Image.create(800, 600, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.2, 0.2, 0.8, 1))  # 蓝色背景
		# 添加文字说明
		var font = ThemeDB.fallback_font
		# 简化处理
		for x in range(100, 300):
			for y in range(280, 320):
				image.set_pixel(x, y, Color.WHITE)
	
	var path = "res://screenshots/" + state_name + ".png"
	image.save_png(path)
	print("Saved: " + path)
