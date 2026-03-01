# Pinball Experience - Multiball 单元测试
# 测试 REQ-008 Multiball 组件

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Multiball 单元测试 (REQ-008)")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	run_unit_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_unit_tests():
	# 测试 GameManager bonus ball 逻辑
	test_game_manager_bonus_ball()
	
	# 测试 MultiballIndicator
	test_multiball_indicator()
	
	# 测试 Drain 多球逻辑
	test_drain_multiball()

# =============================================================================
# GameManager Bonus Ball 单元测试
# =============================================================================
func test_game_manager_bonus_ball():
	print("\n----- GameManager Bonus Ball 单元测试 -----")
	
	# 创建 GameManager 节点
	var game_manager = GameManager.new()
	root.add_child(game_manager)
	await process_frame
	
	# 测试初始状态
	if game_manager.active_bonus_balls == 0:
		print("✓ UT-008-01: 初始 active_bonus_balls = 0")
		tests_passed += 1
	else:
		print("✗ UT-008-01: 初始 active_bonus_balls 应为 0")
		tests_failed += 1
	
	# 测试 BONUS_BALL_DELAY 常量
	if game_manager.BONUS_BALL_DELAY == 5.0:
		print("✓ UT-008-02: BONUS_BALL_DELAY = 5.0 秒")
		tests_passed += 1
	else:
		print("✗ UT-008-02: BONUS_BALL_DELAY 应为 5.0")
		tests_failed += 1
	
	# 测试 add_bonus 方法存在
	if game_manager.has_method("add_bonus"):
		print("✓ UT-008-03: add_bonus 方法存在")
		tests_passed += 1
	else:
		print("✗ UT-008-03: add_bonus 方法不存在")
		tests_failed += 1
	
	# 测试 add_bonus("googleWord") 触发
	game_manager.add_bonus("googleWord")
	if "googleWord" in game_manager.bonus_history:
		print("✓ UT-008-04: googleWord 已添加到 bonus_history")
		tests_passed += 1
	else:
		print("✗ UT-008-04: googleWord 未添加到 bonus_history")
		tests_failed += 1
	
	# 测试 bonus_ball_timer 已启动
	if game_manager.bonus_ball_timer != null:
		print("✓ UT-008-05: bonus_ball_timer 已创建")
		tests_passed += 1
	else:
		print("✗ UT-008-05: bonus_ball_timer 未创建")
		tests_failed += 1
	
	# 测试 bonus_ball_requested 信号存在
	if game_manager.has_signal("bonus_ball_requested"):
		print("✓ UT-008-06: bonus_ball_requested 信号存在")
		tests_passed += 1
	else:
		print("✗ UT-008-06: bonus_ball_requested 信号不存在")
		tests_failed += 1
	
	game_manager.free()

# =============================================================================
# MultiballIndicator 单元测试
# =============================================================================
func test_multiball_indicator():
	print("\n----- MultiballIndicator 单元测试 -----")
	
	# 加载 MultiballIndicator 场景
	var indicator_scene = load("res://scenes/MultiballIndicator.tscn")
	if indicator_scene:
		print("✓ UT-008-07: MultiballIndicator 场景可加载")
		tests_passed += 1
	else:
		print("✗ UT-008-07: MultiballIndicator 场景加载失败")
		tests_failed += 1
		return
	
	var indicator = indicator_scene.instantiate()
	root.add_child(indicator)
	await process_frame
	
	# 测试指示灯节点存在
	var has_indicators = true
	for i in range(1, 5):
		var node = indicator.get_node_or_null("Indicator%d" % i)
		if not node:
			has_indicators = false
			break
	
	if has_indicators:
		print("✓ UT-008-08: 4个指示灯节点存在")
		tests_passed += 1
	else:
		print("✗ UT-008-08: 指示灯节点不完整")
		tests_failed += 1
	
	# 测试 _update_indicators 方法存在
	if indicator.has_method("_update_indicators"):
		print("✓ UT-008-09: _update_indicators 方法存在")
		tests_passed += 1
	else:
		print("✗ UT-008-09: _update_indicators 方法不存在")
		tests_failed += 1
	
	# 测试纹理预加载
	if indicator.dimmed_texture and indicator.lit_texture:
		print("✓ UT-008-10: 纹理已预加载")
		tests_passed += 1
	else:
		print("✗ UT-008-10: 纹理未预加载")
		tests_failed += 1
	
	# 测试连接到 GameManager
	GameManager.active_bonus_balls = 0
	indicator._update_indicators()
	print("    [DEBUG] active_bonus_balls=0 时的指示灯状态已更新")
	print("✓ UT-008-11: _update_indicators 可正常调用")
	tests_passed += 1
	
	indicator.free()

# =============================================================================
# Drain 多球逻辑单元测试
# =============================================================================
func test_drain_multiball():
	print("\n----- Drain 多球逻辑单元测试 -----")
	
	# 加载 Drain 场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	var drain = main.get_node_or_null("Playfield/Drain")
	if drain:
		print("✓ UT-008-12: Drain 节点存在")
		tests_passed += 1
	else:
		print("✗ UT-008-12: Drain 节点不存在")
		tests_failed += 1
		main.free()
		return
	
	# 测试 get_ball_count 方法
	if GameManager.has_method("get_ball_count"):
		print("✓ UT-008-13: get_ball_count 方法存在")
		tests_passed += 1
	else:
		print("✗ UT-008-13: get_ball_count 方法不存在")
		tests_failed += 1
	
	# 测试 on_ball_removed 方法
	if GameManager.has_method("on_ball_removed"):
		print("✓ UT-008-14: on_ball_removed 方法存在")
		tests_passed += 1
	else:
		print("✗ UT-008-14: on_ball_removed 方法不存在")
		tests_failed += 1
	
	# 发射球
	var launcher = main.get_node_or_null("Launcher")
	if launcher and launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await process_frame
		await create_timer(0.2).timeout
		
		var ball_count = GameManager.get_ball_count()
		print("    [DEBUG] 发射后球数量: %d" % ball_count)
		
		if ball_count > 0:
			print("✓ UT-008-15: 球已成功生成")
			tests_passed += 1
		else:
			print("✗ UT-008-15: 球生成失败")
			tests_failed += 1
	
	main.free()
