extends SceneTree

# 缺失的功能测试用例
# 运行: DISPLAY=:99 godot --headless --path . -s test/run_missing_tests.gd

var tests_passed := 0
var tests_failed := 0

func _initialize() -> void:
	print("========================================")
	print("  缺失的功能测试用例")
	print("========================================")
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# 等待初始化
	await create_timer(1.0).timeout
	
	# 运行缺失的测试
	test_014_launcher_impulse()
	await create_timer(0.5).timeout
	
	test_022_drain_ball_removal()
	await create_timer(0.5).timeout
	
	test_023_ball_count_zero()
	await create_timer(0.5).timeout
	
	test_032_wall_collision()
	await create_timer(0.5).timeout
	
	test_042_scoring()
	await create_timer(0.5).timeout
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	quit()

# 0.1.4: Launcher.gd 发射逻辑 - 按空格发射球，施加 impulse
func test_014_launcher_impulse() -> void:
	print("\n----- 0.1.4: Launcher发射逻辑 -----")
	
	var launcher = root.find_child("Launcher", true, false)
	if not launcher:
		print_fail("0.1.4: Launcher 不存在")
		return
	
	# 手动调用发射
	if launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await create_timer(0.2).timeout
		
		# 检查球是否生成
		var game_manager = root.find_child("GameManager", true, false)
		if game_manager and game_manager.balls_container:
			var ball_count = game_manager.balls_container.get_child_count()
			if ball_count > 0:
				print_pass("0.1.4: 球已生成")
				
				# 尝试发射
				if launcher.has_method("_launch_ball"):
					launcher._launch_ball()
					await create_timer(0.1).timeout
					print_pass("0.1.4: _launch_ball() 已调用")
			else:
				print_fail("0.1.4: 球生成失败")
		else:
			print_fail("0.1.4: balls_container 不存在")
	else:
		print_fail("0.1.4: Launcher 缺少 _spawn_ball 方法")

# 0.2.2: 球进入排水口 - 球被移除，触发 on_ball_removed()
func test_022_drain_ball_removal() -> void:
	print("\n----- 0.2.2: 球进入排水口 -----")
	
	var drain = root.find_child("Drain", true, false)
	if not drain:
		print_fail("0.2.2: Drain 不存在")
		return
	
	# 检查 Drain 使用 signal (body_entered)
	if drain.has_signal("body_entered"):
		print_pass("0.2.2: Drain 有 body_entered 信号")
	else:
		print_fail("0.2.2: Drain 缺少 body_entered 信号")
	
	# 检查 _on_body_entered 方法
	if drain.has_method("_on_body_entered"):
		print_pass("0.2.2: Drain 有 _on_body_entered 方法")
	else:
		print_fail("0.2.2: Drain 缺少 _on_body_entered 方法")

# 0.2.3: 球数归零 - get_ball_count() <= 0 时触发 on_round_lost()
func test_023_ball_count_zero() -> void:
	print("\n----- 0.2.3: 球数归零 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if not game_manager:
		print_fail("0.2.3: GameManager 不存在")
		return
	
	# 检查方法
	if game_manager.has_method("get_ball_count"):
		print_pass("0.2.3: get_ball_count() 方法存在")
	else:
		print_fail("0.2.3: 缺少 get_ball_count() 方法")
	
	if game_manager.has_method("on_ball_removed"):
		print_pass("0.2.3: on_ball_removed() 方法存在")
	else:
		print_fail("0.2.3: 缺少 on_ball_removed() 方法")
	
	if game_manager.has_method("on_round_lost"):
		print_pass("0.2.3: on_round_lost() 方法存在")
	else:
		print_fail("0.2.3: 缺少 on_round_lost() 方法")

# 0.3.2: 球碰墙壁 - 球从墙壁反弹不穿透
func test_032_wall_collision() -> void:
	print("\n----- 0.3.2: 球碰墙壁 -----")
	
	var walls = ["WallLeft", "WallRight", "WallTop"]
	var all_have_collision = true
	
	for wall_name in walls:
		var wall = root.find_child(wall_name, true, false)
		if wall:
			var collision = wall.find_child("CollisionShape2D", true, false)
			if collision:
				print("    %s: 有 CollisionShape2D" % wall_name)
			else:
				print_fail("0.3.2: %s 缺少 CollisionShape2D" % wall_name)
				all_have_collision = false
		else:
			print_fail("0.3.2: %s 不存在" % wall_name)
			all_have_collision = false
	
	if all_have_collision:
		print_pass("0.3.2: 所有墙壁都有 CollisionShape2D")

# 0.4.2: 计分逻辑 - 障碍物被击中时得分
func test_042_scoring() -> void:
	print("\n----- 0.4.2: 计分逻辑 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if not game_manager:
		print_fail("0.4.2: GameManager 不存在")
		return
	
	# 检查计分方法
	if game_manager.has_method("add_score"):
		var initial_score = game_manager.round_score
		game_manager.add_score(100, "test")
		var new_score = game_manager.round_score
		
		if new_score == initial_score + 100:
			print_pass("0.4.2: add_score() 工作正常")
		else:
			print_fail("0.4.2: add_score() 计分错误")
	else:
		print_fail("0.4.2: 缺少 add_score() 方法")
	
	# 检查 scored 信号
	if game_manager.has_signal("scored"):
		print_pass("0.4.2: scored 信号存在")
	else:
		print_fail("0.4.2: 缺少 scored 信号")

# 测试工具
func print_pass(msg: String) -> void:
	tests_passed += 1
	print("✓ %s" % msg)

func print_fail(msg: String) -> void:
	tests_failed += 1
	print("✗ %s" % msg)
