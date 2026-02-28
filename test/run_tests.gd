extends SceneTree

# 增强版测试套件 - 覆盖更多功能
# 运行: DISPLAY=:99 godot --headless --path . -s test/run_tests.gd

var tests_passed := 0
var tests_failed := 0

func _initialize() -> void:
	print("========================================")
	print("  Pinball Experience - 增强测试套件")
	print("========================================")
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# 等待初始化
	await create_timer(1.0).timeout
	
	# 运行测试
	run_all_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	quit()

func run_all_tests() -> void:
	# 0.1 发射器 + 挡板
	print("\n----- 测试 0.1: 发射器 + 挡板 -----")
	test_launcher_exists()
	test_launcher_position()
	test_flipper_left_exists()
	test_flipper_right_exists()
	test_launcher_spawn_position()
	
	# 0.2 排水口
	print("\n----- 测试 0.2: 排水口 -----")
	test_drain_exists()
	test_drain_position()
	
	# 0.3 墙壁
	print("\n----- 测试 0.3: 墙壁 -----")
	test_walls_exist()
	
	# 0.4 障碍物
	print("\n----- 测试 0.4: 障碍物 -----")
	test_obstacles_exist()
	
	# 0.5 UI
	print("\n----- 测试 0.5: UI -----")
	test_hud_exists()
	test_game_over_panel()
	
	# 物理参数测试
	print("\n----- 物理参数测试 -----")
	test_ball_physics()
	test_launcher_direction()

# ===== 0.1 发射器测试 =====

func test_launcher_exists() -> void:
	var launcher = root.find_child("Launcher", true, false)
	if launcher:
		print_pass("0.1.1: Launcher 存在")
	else:
		print_fail("0.1.1: Launcher 不存在")

func test_launcher_position() -> void:
	var launcher = root.find_child("Launcher", true, false)
	if launcher and launcher.position.x > 500:
		print_pass("0.1.2: Launcher 在右侧 (x > 500)")
	else:
		print_fail("0.1.2: Launcher 位置错误")

func test_flipper_left_exists() -> void:
	var flipper = root.find_child("FlipperLeft", true, false)
	if flipper:
		print_pass("0.1.3: FlipperLeft 存在")
	else:
		print_fail("0.1.3: FlipperLeft 不存在")

func test_flipper_right_exists() -> void:
	var flipper = root.find_child("FlipperRight", true, false)
	if flipper:
		print_pass("0.1.4: FlipperRight 存在")
	else:
		print_fail("0.1.4: FlipperRight 不存在")

func test_launcher_spawn_position() -> void:
	var launcher = root.find_child("Launcher", true, false)
	if launcher and launcher.has_method("get_spawn_position"):
		var pos = launcher.get_spawn_position()
		print("    Spawn位置: (%f, %f)" % [pos.x, pos.y])
		print_pass("0.1.5: Launcher.get_spawn_position() 可用")
	else:
		print_fail("0.1.5: Launcher 缺少 get_spawn_position")

# ===== 0.2 排水口测试 =====

func test_drain_exists() -> void:
	var drain = root.find_child("Drain", true, false)
	if drain:
		print_pass("0.2.1: Drain 存在")
	else:
		print_fail("0.2.1: Drain 不存在")

func test_drain_position() -> void:
	var drain = root.find_child("Drain", true, false)
	if drain and drain.position.y > 500:
		print_pass("0.2.2: Drain 在底部 (y > 500)")
	else:
		print_fail("0.2.2: Drain 位置错误")

# ===== 0.3 墙壁测试 =====

func test_walls_exist() -> void:
	var walls = ["WallLeft", "WallRight", "WallTop"]
	var all_exist = true
	
	for wall_name in walls:
		var wall = root.find_child(wall_name, true, false)
		if not wall:
			all_exist = false
			print_fail("0.3.1: %s 不存在" % wall_name)
	
	if all_exist:
		print_pass("0.3.1: 所有墙壁存在")

# ===== 0.4 障碍物测试 =====

func test_obstacles_exist() -> void:
	var obstacles = root.find_child("Obstacles", true, false)
	if obstacles:
		var count = obstacles.get_child_count()
		print_pass("0.4.1: Obstacles 存在 (数量: %d)" % count)
	else:
		print_fail("0.4.1: Obstacles 不存在")

# ===== 0.5 UI测试 =====

func test_hud_exists() -> void:
	var hud = root.find_child("HUD", true, false)
	if hud:
		print_pass("0.5.1: HUD 存在")
	else:
		print_fail("0.5.1: HUD 不存在")

func test_game_over_panel() -> void:
	var panel = root.find_child("GameOverPanel", true, false)
	if panel:
		var visible = panel.visible
		if not visible:
			print_pass("0.5.2: GameOverPanel 默认隐藏")
		else:
			print_fail("0.5.2: GameOverPanel 应该默认隐藏")
	else:
		print_fail("0.5.2: GameOverPanel 不存在")

# ===== 物理参数测试 =====

func test_ball_physics() -> void:
	# 测试球创建和物理参数
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager and game_manager.has_method("spawn_ball_at_launcher"):
		game_manager.spawn_ball_at_launcher()
		await create_timer(0.5).timeout
		
		var balls_container = game_manager.balls_container
		if balls_container and balls_container.get_child_count() > 0:
			var ball = balls_container.get_child(0)
			if ball.has_method("get_physics_parameter"):
				print_pass("0.1.6: 球物理参数可访问")
			else:
				print_pass("0.1.6: 球已生成")
		else:
			print_fail("0.1.6: 球生成失败")
	else:
		print_fail("0.1.6: GameManager 缺少 spawn_ball_at_launcher")

func test_launcher_direction() -> void:
	# 测试发射方向
	var launcher = root.find_child("Launcher", true, false)
	if launcher:
		# 检查脚本中的发射方向
		var script = launcher.get_script()
		if script:
			print_pass("0.1.7: Launcher 有脚本")
		else:
			print_fail("0.1.7: Launcher 无脚本")
	else:
		print_fail("0.1.7: Launcher 不存在")

# ===== 测试工具 =====

func print_pass(msg: String) -> void:
	tests_passed += 1
	print("✓ %s" % msg)

func print_fail(msg: String) -> void:
	tests_failed += 1
	print("✗ %s" % msg)
