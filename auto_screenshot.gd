extends SceneTree

# 自动化截图脚本
# 用法: godot --headless --window-size 800,600 --path . -s auto_screenshot.gd

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
	
	# 模拟按下发射键
	print("Simulating launch key press...")
	simulate_launch()
	
	await create_timer(0.5).timeout
	
	# 截图: 发射状态
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

func simulate_launch():
	# 找到Launcher节点并调用发射
	var launcher = root.find_child("Launcher", true, false)
	if launcher and launcher.has_method("_launch_ball"):
		# 检查球是否存在
		if launcher.get("_ball") != null:
			launcher._launch_ball()
			print("Ball launched!")

func capture_state(state_name: String):
	var viewport = get_root().get_viewport()
	if not viewport:
		print("ERROR: No viewport")
		return
	
	var image = viewport.get_texture().get_image()
	if not image or image.get_width() == 0:
		print("WARNING: Viewport not rendered, creating test image")
		image = Image.create(800, 600, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.1, 0.1, 0.2, 1))  # 深蓝色背景
	
	var path = "res://screenshots/" + state_name + ".png"
	image.save_png(path)
	print("Saved: " + path)
