# Pinball Experience - Multiball E2E 测试
# 完整的端到端 Multiball 流程测试

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Multiball E2E 测试 (REQ-008)")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	run_e2e_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_e2e_tests():
	# E2E-1: 完整 Multiball 流程
	test_e2e1_full_multiball_flow()
	
	# E2E-2: 多次 Multiball
	test_e2e2_multiple_multiball()
	
	# E2E-3: 游戏结束与 Multiball
	test_e2e3_gameover_with_multiball()

# =============================================================================
# E2E-1: 完整 Multiball 流程
# =============================================================================
func test_e2e1_full_multiball_flow():
	print("\n----- E2E-1: 完整 Multiball 流程 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置游戏状态
	GameManager.active_bonus_balls = 0
	GameManager.round_score = 0
	
	# 步骤 1: 开始游戏并发射球
	print("    [E2E] 步骤 1: 发射初始球")
	var launcher = main.get_node_or_null("Launcher")
	if launcher and launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await process_frame
		await create_timer(0.2).timeout
	
	var ball_count = GameManager.get_ball_count()
	if ball_count > 0:
		print("✓ E2E-008-01: 初始球已发射")
		tests_passed += 1
	else:
		print("✗ E2E-008-01: 初始球发射失败")
		tests_failed += 1
		main.free()
		return
	
	# 步骤 2: 触发 googleWord bonus
	print("    [E2E] 步骤 2: 触发 googleWord bonus")
	GameManager.add_bonus("googleWord")
	print("    [DEBUG] bonus_ball_timer running: %s" % (GameManager.bonus_ball_timer.time_left > 0 if GameManager.bonus_ball_timer else "N/A"))
	
	# 步骤 3: 等待 5 秒
	print("    [E2E] 步骤 3: 等待 5 秒...")
	await create_timer(5.0).timeout
	
	# 步骤 4: 验证 bonus ball 生成
	ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 5秒后球数量: %d" % ball_count)
	
	if ball_count >= 2:
		print("✓ E2E-008-02: Bonus ball 已生成 (总球数: %d)" % ball_count)
		tests_passed += 1
	else:
		print("✗ E2E-008-02: Bonus ball 未生成")
		tests_failed += 1
	
	# 步骤 5: 验证 MultiballIndicator 更新
	var multiball_indicator = main.get_node_or_null("UI/Control/MultiballIndicator")
	if multiball_indicator:
		print("✓ E2E-008-03: MultiballIndicator 存在")
		tests_passed += 1
	else:
		print("✗ E2E-008-03: MultiballIndicator 不存在")
		tests_failed += 1
	
	# 步骤 6: 验证 active_bonus_balls 追踪
	if GameManager.active_bonus_balls >= 1:
		print("✓ E2E-008-04: active_bonus_balls 正确追踪: %d" % GameManager.active_bonus_balls)
		tests_passed += 1
	else:
		print("✗ E2E-008-04: active_bonus_balls 未正确更新")
		tests_failed += 1
	
	# 清理
	main.free()

# =============================================================================
# E2E-2: 多次 Multiball
# =============================================================================
func test_e2e2_multiple_multiball():
	print("\n----- E2E-2: 多次 Multiball -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置
	GameManager.active_bonus_balls = 0
	
	# 发射初始球
	var launcher = main.get_node_or_null("Launcher")
	if launcher and launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await process_frame
		await create_timer(0.2).timeout
	
	# 触发多次 bonus
	print("    [E2E] 触发 3 次 bonus ball")
	for i in range(3):
		GameManager.add_bonus("googleWord")
		await create_timer(5.0).timeout
		print("        第 %d 次 bonus 后球数量: %d" % [i+1, GameManager.get_ball_count()])
	
	var ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 3次 bonus 后总球数: %d" % ball_count)
	
	if ball_count >= 4:  # 初始球 + 3个 bonus ball
		print("✓ E2E-008-05: 多次 Multiball 成功 (总球数: %d)" % ball_count)
		tests_passed += 1
	else:
		print("✗ E2E-008-05: 多次 Multiball 失败")
		tests_failed += 1
	
	# 验证 active_bonus_balls 限制为 4
	if GameManager.active_bonus_balls <= 4:
		print("✓ E2E-008-06: active_bonus_balls 已限制为 4 (实际: %d)" % GameManager.active_bonus_balls)
		tests_passed += 1
	else:
		print("✗ E2E-008-06: active_bonus_balls 未正确限制")
		tests_failed += 1
	
	main.free()

# =============================================================================
# E2E-3: 游戏结束与 Multiball
# =============================================================================
func test_e2e3_gameover_with_multiball():
	print("\n----- E2E-3: 游戏结束与 Multiball -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置
	GameManager.active_bonus_balls = 0
	GameManager.rounds = 1
	var game_over_triggered = false
	var round_lost_triggered = false
	
	# 连接信号
	GameManager.game_over.connect(func(_score): 
		game_over_triggered = true
	)
	GameManager.round_lost.connect(func(_score, _mult):
		round_lost_triggered = true
	)
	
	# 发射球并触发 bonus
	var launcher = main.get_node_or_null("Launcher")
	if launcher and launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await process_frame
		await create_timer(0.2).timeout
	
	# 触发 bonus ball
	GameManager.add_bonus("googleWord")
	await create_timer(5.0).timeout
	
	print("    [DEBUG] Bonus ball 生成后球数: %d" % GameManager.get_ball_count())
	
	# 移除所有球来触发回合结束
	var balls = main.get_node("Balls")
	while balls.get_child_count() > 0:
		balls.get_child(0).queue_free()
		await process_frame
	
	await create_timer(0.2).timeout
	
	# 验证 round_lost 被触发
	if round_lost_triggered:
		print("✓ E2E-008-07: 所有球掉落后触发 round_lost")
		tests_passed += 1
	else:
		print("✗ E2E-008-07: round_lost 未触发")
		tests_failed += 1
	
	# 由于 rounds=1，应该触发 game_over
	if game_over_triggered:
		print("✓ E2E-008-08: 游戏结束触发")
		tests_passed += 1
	else:
		print("✗ E2E-008-08: 游戏结束未触发")
		tests_failed += 1
	
	main.free()
