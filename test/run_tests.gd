# Pinball Experience - Test Runner
# 运行所有测试

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Pinball Experience - 测试套件")
	print("========================================")
	
	# 给 Godot 一点时间初始化
	await create_timer(0.1).timeout
	
	run_all_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	# 延迟退出让输出完成
	await create_timer(0.5).timeout
	quit()

func run_all_tests():
	# 测试 0.1 - 发射器 + 挡板
	test_0_1_launcher_and_flippers()
	
	# 测试 0.2 - 排水口
	test_0_2_drain()
	
	# 测试 0.3 - 墙壁
	test_0_3_walls()
	
	# 测试 0.4 - 障碍物
	test_0_4_obstacles()
	
	# 测试 0.5 - 回合游戏结束
	test_0_5_rounds_gameover()

func test_0_1_launcher_and_flippers():
	print("\n----- 测试 0.1: 发射器 + 挡板 -----")
	
	# 加载场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 测试发射器
	if main.has_node("Launcher"):
		print("✓ 0.1.1: Launcher 存在")
		tests_passed += 1
	else:
		print("✗ 0.1.1: Launcher 不存在")
		tests_failed += 1
	
	# 测试左挡板
	if main.has_node("FlipperLeft"):
		print("✓ 0.1.2: FlipperLeft 存在")
		tests_passed += 1
	else:
		print("✗ 0.1.2: FlipperLeft 不存在")
		tests_failed += 1
	
	# 测试右挡板
	if main.has_node("FlipperRight"):
		print("✓ 0.1.3: FlipperRight 存在")
		tests_passed += 1
	else:
		print("✗ 0.1.3: FlipperRight 不存在")
		tests_failed += 1
	
	main.free()

func test_0_2_drain():
	print("\n----- 测试 0.2: 排水口 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 测试排水口
	if main.has_node("Playfield/Drain"):
		print("✓ 0.2.1: Drain 存在")
		tests_passed += 1
	else:
		print("✗ 0.2.1: Drain 不存在")
		tests_failed += 1
	
	main.free()

func test_0_3_walls():
	print("\n----- 测试 0.3: 墙壁 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 测试墙壁
	if main.has_node("Playfield/Boundaries/WallLeft"):
		print("✓ 0.3.1: WallLeft 存在")
		tests_passed += 1
	else:
		print("✗ 0.3.1: WallLeft 不存在")
		tests_failed += 1
	
	if main.has_node("Playfield/Boundaries/WallRight"):
		print("✓ 0.3.2: WallRight 存在")
		tests_passed += 1
	else:
		print("✗ 0.3.2: WallRight 不存在")
		tests_failed += 1
	
	if main.has_node("Playfield/Boundaries/WallTop"):
		print("✓ 0.3.3: WallTop 存在")
		tests_passed += 1
	else:
		print("✗ 0.3.3: WallTop 不存在")
		tests_failed += 1
	
	main.free()

func test_0_4_obstacles():
	print("\n----- 测试 0.4: 障碍物 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 测试障碍物
	if main.has_node("Obstacles"):
		var obstacles = main.get_node("Obstacles")
		var count = obstacles.get_child_count()
		if count >= 3:
			print("✓ 0.4.1: Obstacles 存在 (数量: %d)" % count)
			tests_passed += 1
		else:
			print("✗ 0.4.1: Obstacles 数量不足 (期望: 3, 实际: %d)" % count)
			tests_failed += 1
	else:
		print("✗ 0.4.1: Obstacles 不存在")
		tests_failed += 1
	
	main.free()

func test_0_5_rounds_gameover():
	print("\n----- 测试 0.5: 回合 + 游戏结束 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 测试 UI
	if main.has_node("UI/Control/HUD"):
		print("✓ 0.5.1: HUD 存在")
		tests_passed += 1
	else:
		print("✗ 0.5.1: HUD 不存在")
		tests_failed += 1
	
	if main.has_node("UI/Control/GameOverPanel"):
		var panel = main.get_node("UI/Control/GameOverPanel")
		if not panel.visible:
			print("✓ 0.5.2: GameOverPanel 默认隐藏")
			tests_passed += 1
		else:
			print("✗ 0.5.2: GameOverPanel 应该默认隐藏")
			tests_failed += 1
	else:
		print("✗ 0.5.2: GameOverPanel 不存在")
		tests_failed += 1
	
	main.free()
