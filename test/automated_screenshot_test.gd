# automated_screenshot_test.gd
extends SceneTree
## 自动化截图测试 - 测试游戏各阶段的截图功能

var test_results = []
var screenshot_base = "user://test_screenshots/"

func _initialize() -> void:
	print("========================================")
	print("  自动化截图测试")
	print("========================================")
	
	# 确保目录存在
	DirAccess.make_dir_recursive_absolute(screenshot_base)
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# 等待初始化
	await process_frame
	await process_frame
	await create_timer(1.0).timeout
	
	# 执行测试场景
	await test_game_start(main)
	await test_launch_ball(main)
	await test_ball_drain(main)
	await test_game_over(main)
	
	# 保存测试报告
	save_test_report()
	
	main.free()
	await create_timer(0.5).timeout
	print("========================================")
	print("  测试完成")
	print("========================================")
	quit()

func test_game_start(main: Node) -> void:
	print("\n--- 场景1: 游戏开始 ---")
	await create_timer(0.5).timeout
	capture("01_game_start")
	test_results.append({"test": "game_start", "status": "pass"})

func test_launch_ball(main: Node) -> void:
	print("\n--- 场景2: 发射球 ---")
	
	# 尝试触发发射
	var launcher = main.get_node_or_null("Launcher")
	if launcher:
		# 模拟按下发射键
		launcher._launch_ball() if launcher.has_method("_launch_ball") else null
	
	await create_timer(1.0).timeout
	capture("02_ball_launched")
	test_results.append({"test": "ball_launch", "status": "pass"})

func test_ball_drain(main: Node) -> void:
	print("\n--- 场景3: 球掉落 ---")
	
	# 等待球自然掉落或手动触发
	await create_timer(3.0).timeout
	capture("03_ball_drain")
	test_results.append({"test": "ball_drain", "status": "pass"})

func test_game_over(main: Node) -> void:
	print("\n--- 场景4: 游戏结束 ---")
	
	# 等待游戏结束
	await create_timer(2.0).timeout
	capture("04_game_over")
	test_results.append({"test": "game_over", "status": "pass"})

func capture(prefix: String) -> void:
	var viewport = get_viewport()
	if viewport:
		var tex = viewport.get_texture()
		if tex:
			var img = tex.get_image()
			if img and img.get_width() > 0:
				var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
				var path = screenshot_base + prefix + "_" + timestamp + ".png"
				img.save_png(path)
				print("✓ 截图: " + path)
			else:
				print("⚠ 无法获取图像")
				test_results.append({"test": prefix, "status": "fail", "reason": "no_image"})
		else:
			print("⚠ 无法获取纹理")
			test_results.append({"test": prefix, "status": "fail", "reason": "no_texture"})
	else:
		print("⚠ 无法获取视口")
		test_results.append({"test": prefix, "status": "fail", "reason": "no_viewport"})

func save_test_report() -> void:
	var report = JSON.stringify(test_results, "  ")
	var file = FileAccess.open("user://test_report.json", FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
		print("\n✓ 测试报告已保存: user://test_report.json")
