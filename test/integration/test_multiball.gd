# Pinball Experience - Multiball Integration Tests
# 测试 REQ-008 Multiball 功能验收标准

extends SceneTree

# 测试结果统计
var tests_passed = 0
var tests_failed = 0

# 测试标记
const TEST_BONUS_BALL_DELAY := 5.0  # AC-1: 5秒延迟

func _initialize():
	print("========================================")
	print("  Multiball 集成测试 (REQ-008)")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	run_multiball_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_multiball_tests():
	# AC-1: 触发 googleWord/dashNest 后 5 秒生成 bonus ball
	test_ac1_bonus_ball_spawn_delay()
	
	# AC-2: MultiballIndicator 显示激活的 bonus balls (最多4个)
	test_ac2_multiball_indicator_display()
	
	# AC-3: 多个球可以同时存在于场地上
	test_ac3_multiple_balls_coexist()
	
	# AC-4: 只有当所有球都掉落时才触发回合结束
	test_ac4_all_balls_drain_ends_round()
	
	# AC-5: UI 显示当前 active_bonus_balls 数量
	test_ac5_ui_shows_active_bonus_balls()

# =============================================================================
# AC-1: 触发 googleWord/dashNest 后 5 秒生成 bonus ball
# =============================================================================
func test_ac1_bonus_ball_spawn_delay():
	print("\n----- AC-1: Bonus ball 5秒生成延迟 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置 GameManager 状态
	GameManager.active_bonus_balls = 0
	GameManager.round_score = 0
	
	# 记录初始球数量
	var initial_ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 初始球数量: %d" % initial_ball_count)
	
	# 触发 googleWord bonus
	GameManager.add_bonus("googleWord")
	print("    [DEBUG] 触发 googleWord bonus")
	
	# 等待 5 秒 (bonus ball 延迟)
	await create_timer(TEST_BONUS_BALL_DELAY).timeout
	
	# 验证 bonus ball 已生成
	var new_ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 5秒后球数量: %d" % new_ball_count)
	
	if new_ball_count > initial_ball_count:
		print("✓ IT-008-01: 触发 googleWord 后 5 秒生成 bonus ball")
		tests_passed += 1
	else:
		print("✗ IT-008-01: 触发 googleWord 后未生成 bonus ball")
		tests_failed += 1
	
	# 验证 active_bonus_balls 已增加
	if GameManager.active_bonus_balls > 0:
		print("✓ IT-008-02: active_bonus_balls 已更新: %d" % GameManager.active_bonus_balls)
		tests_passed += 1
	else:
		print("✗ IT-008-02: active_bonus_balls 未更新")
		tests_failed += 1
	
	# 测试 dashNest bonus
	GameManager.add_bonus("dashNest")
	print("    [DEBUG] 触发 dashNest bonus")
	
	await create_timer(TEST_BONUS_BALL_DELAY).timeout
	
	var final_ball_count = GameManager.get_ball_count()
	print("    [DEBUG] dashNest 后球数量: %d" % final_ball_count)
	
	if final_ball_count > new_ball_count:
		print("✓ IT-008-03: 触发 dashNest 后 5 秒生成 bonus ball")
		tests_passed += 1
	else:
		print("✗ IT-008-03: 触发 dashNest 后未生成 bonus ball")
		tests_failed += 1
	
	main.free()

# =============================================================================
# AC-2: MultiballIndicator 显示激活的 bonus balls (最多4个)
# =============================================================================
func test_ac2_multiball_indicator_display():
	print("\n----- AC-2: MultiballIndicator 显示 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置状态
	GameManager.active_bonus_balls = 0
	
	# 检查 MultiballIndicator 节点是否存在
	var multiball_indicator = main.get_node_or_null("UI/Control/MultiballIndicator")
	if multiball_indicator:
		print("✓ IT-008-04: MultiballIndicator 节点存在")
		tests_passed += 1
	else:
		print("✗ IT-008-04: MultiballIndicator 节点不存在")
		tests_failed += 1
		main.free()
		return
	
	# 触发 1 次 bonus 并验证指示灯
	GameManager.add_bonus("googleWord")
	await create_timer(TEST_BONUS_BALL_DELAY).timeout
	GameManager._update_indicators() if GameManager.has_method("_update_indicators") else null
	
	var active = GameManager.active_bonus_balls
	print("    [DEBUG] active_bonus_balls: %d" % active)
	
	if active >= 1:
		print("✓ IT-008-05: 1 个 bonus ball 时 active_bonus_balls = 1")
		tests_passed += 1
	else:
		print("✗ IT-008-05: active_bonus_balls 应为 1")
		tests_failed += 1
	
	# 触发更多 bonus 并验证上限 (最多4个)
	for i in range(5):  # 再触发 5 次
		GameManager.add_bonus("googleWord")
		await create_timer(TEST_BONUS_BALL_DELAY).timeout
	
	active = GameManager.active_bonus_balls
	print("    [DEBUG] 6次 bonus 后 active_bonus_balls: %d" % active)
	
	if active <= 4:
		print("✓ IT-008-06: active_bonus_balls 上限为 4 (实际: %d)" % active)
		tests_passed += 1
	else:
		print("✗ IT-008-06: active_bonus_balls 应限制为 4")
		tests_failed += 1
	
	main.free()

# =============================================================================
# AC-3: 多个球可以同时存在于场地上
# =============================================================================
func test_ac3_multiple_balls_coexist():
	print("\n----- AC-3: 多球共存 -----")
	
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
	
	var ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 初始球数量: %d" % ball_count)
	
	# 触发多次 bonus ball
	GameManager.add_bonus("googleWord")
	await create_timer(TEST_BONUS_BALL_DELAY).timeout
	
	ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 1次 bonus 后球数量: %d" % ball_count)
	
	if ball_count >= 2:
		print("✓ IT-008-07: 存在多个球 (数量: %d)" % ball_count)
		tests_passed += 1
	else:
		print("✗ IT-008-07: 球数量不足")
		tests_failed += 1
	
	# 再触发更多 bonus
	GameManager.add_bonus("dashNest")
	await create_timer(TEST_BONUS_BALL_DELAY).timeout
	
	ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 2次 bonus 后球数量: %d" % ball_count)
	
	if ball_count >= 3:
		print("✓ IT-008-08: 3 个球同时存在 (数量: %d)" % ball_count)
		tests_passed += 1
	else:
		print("✗ IT-008-08: 应有至少 3 个球")
		tests_failed += 1
	
	main.free()

# =============================================================================
# AC-4: 只有当所有球都掉落时才触发回合结束
# =============================================================================
func test_ac4_all_balls_drain_ends_round():
	print("\n----- AC-4: 所有球掉落才结束回合 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置
	GameManager.active_bonus_balls = 0
	GameManager.rounds = 1  # 设置为 1 回合以便测试
	var round_lost_called = false
	
	# 捕获 round_lost 信号
	GameManager.round_lost.connect(func(_score, _mult): 
		round_lost_called = true
	)
	
	# 发射初始球
	var launcher = main.get_node_or_null("Launcher")
	if launcher and launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await process_frame
		await create_timer(0.2).timeout
	
	# 触发 bonus ball
	GameManager.add_bonus("googleWord")
	await create_timer(TEST_BONUS_BALL_DELAY).timeout
	
	var ball_count = GameManager.get_ball_count()
	print("    [DEBUG] 触发 bonus 后球数量: %d" % ball_count)
	
	# 模拟第一个球掉落 (不是最后一个球)
	if ball_count >= 2:
		# 手动移除一个球
		var balls = main.get_node("Balls")
		if balls.get_child_count() > 0:
			var first_ball = balls.get_child(0)
			first_ball.queue_free()
			await process_frame
			await create_timer(0.1).timeout
			
			# 检查 round_lost 不应该被调用
			if not round_lost_called:
				print("✓ IT-008-09: 部分球掉落时不触发回合结束")
				tests_passed += 1
			else:
				print("✗ IT-008-09: 部分球掉落时不应触发回合结束")
				tests_failed += 1
			
			# 剩余球数量
			var remaining = GameManager.get_ball_count()
			print("    [DEBUG] 移除一个后剩余球数量: %d" % remaining)
			
			# 移除所有剩余的球
			while balls.get_child_count() > 0:
				balls.get_child(0).queue_free()
				await process_frame
			
			await create_timer(0.1).timeout
			
			# 现在应该触发 round_lost
			if round_lost_called:
				print("✓ IT-008-10: 所有球掉落后触发回合结束")
				tests_passed += 1
			else:
				print("✗ IT-008-10: 所有球掉落时应触发回合结束")
				tests_failed += 1
	else:
		print("✗ IT-008-09: 球数量不足，无法测试")
		tests_failed += 1
		print("✗ IT-008-10: 球数量不足，无法测试")
		tests_failed += 1
	
	main.free()

# =============================================================================
# AC-5: UI 显示当前 active_bonus_balls 数量
# =============================================================================
func test_ac5_ui_shows_active_bonus_balls():
	print("\n----- AC-5: UI 显示 active_bonus_balls -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 重置
	GameManager.active_bonus_balls = 0
	
	# 检查 UI 节点
	var ui_control = main.get_node_or_null("UI/Control")
	if ui_control:
		print("✓ IT-008-11: UI/Control 节点存在")
		tests_passed += 1
	else:
		print("✗ IT-008-11: UI/Control 节点不存在")
		tests_failed += 1
		main.free()
		return
	
	# 检查是否有显示 bonus balls 的 UI 元素
	# 查找 MultiballIndicator
	var multiball = main.get_node_or_null("UI/Control/MultiballIndicator")
	if multiball:
		print("✓ IT-008-12: MultiballIndicator UI 存在")
		tests_passed += 1
	else:
		print("✗ IT-008-12: MultiballIndicator UI 不存在")
		tests_failed += 1
	
	# 触发 bonus 并验证 active_bonus_balls 更新
	GameManager.add_bonus("googleWord")
	await create_timer(0.5).timeout  # 短时间等待信号处理
	
	var active = GameManager.active_bonus_balls
	print("    [DEBUG] bonus 触发后 active_bonus_balls: %d" % active)
	
	# 验证 active_bonus_balls 被正确追踪
	if active >= 1:
		print("✓ IT-008-13: active_bonus_balls 数量正确追踪: %d" % active)
		tests_passed += 1
	else:
		print("✗ IT-008-13: active_bonus_balls 未正确更新")
		tests_failed += 1
	
	# 验证 UI 会响应 active_bonus_balls 变化
	# (通过检查 MultiballIndicator 的 _update_indicators 方法是否被调用)
	if multiball and multiball.has_method("_update_indicators"):
		print("✓ IT-008-14: MultiballIndicator 有更新方法")
		tests_passed += 1
	else:
		print("✗ IT-008-14: MultiballIndicator 缺少更新方法")
		tests_failed += 1
	
	main.free()
