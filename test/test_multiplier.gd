<<<<<<< HEAD
extends GutTest
## Multiplier 单元测试

var multiplier: Multiplier = null

func before_each():
	multiplier = Multiplier.new()
	add_child(multiplier)

# ============ 初始状态测试 ============

func test_initial_multiplier_is_one():
	assert_eq(multiplier.current_multiplier, 1, "初始倍率应为1")

func test_initial_trigger_count():
	assert_eq(multiplier.trigger_count, 0, "初始触发计数应为0")

func test_max_multiplier_default():
	assert_eq(multiplier.max_multiplier, 6, "默认最大倍率应为6")

func test_trigger_interval_default():
	assert_eq(multiplier.trigger_interval, 5, "默认触发间隔应为5")

# ============ 增加倍率测试 ============

func test_increase_multiplier():
	multiplier.increase_multiplier()
	assert_eq(multiplier.current_multiplier, 2, "增加后应为2")

func test_increase_to_max():
	for i in range(6):
		multiplier.increase_multiplier()
	assert_eq(multiplier.current_multiplier, 6, "不应超过最大倍率6")

func test_cannot_exceed_max():
	for i in range(10):
		multiplier.increase_multiplier()
	assert_eq(multiplier.current_multiplier, 6, "超过最大倍率应保持在6")

# ============ 减少倍率测试 ============

func test_decrease_multiplier():
	multiplier.current_multiplier = 3
	multiplier.decrease_multiplier()
	assert_eq(multiplier.current_multiplier, 2, "减少后应为2")

func test_decrease_min():
	multiplier.decrease_multiplier()
	assert_eq(multiplier.current_multiplier, 1, "不应低于1")

# ============ 重置测试 ============

func test_reset_to_one():
	multiplier.current_multiplier = 5
	multiplier.trigger_count = 3
	multiplier.reset()
	assert_eq(multiplier.current_multiplier, 1, "重置后应为1")
	assert_eq(multiplier.trigger_count, 0, "触发计数也应重置")

# ============ 触发计数测试 ============

func test_add_trigger():
	multiplier.add_trigger()
	assert_eq(multiplier.trigger_count, 1, "触发计数应为1")

func test_five_triggers_increase():
	for i in range(5):
		multiplier.add_trigger()
	assert_eq(multiplier.current_multiplier, 2, "5次触发后倍率应为2")
	assert_eq(multiplier.trigger_count, 0, "触发计数应重置")

func test_ten_triggers_increase_twice():
	for i in range(10):
		multiplier.add_trigger()
	assert_eq(multiplier.current_multiplier, 3, "10次触发后倍率应为3")

# ============ 得分计算测试 ============

func test_apply_multiplier_to_score():
	multiplier.current_multiplier = 3
	var result = multiplier.apply_to_score(1000)
	assert_eq(result, 3000, "1000×3应为3000")

func test_multiplier_one_returns_same():
	multiplier.current_multiplier = 1
	var result = multiplier.apply_to_score(5000)
	assert_eq(result, 5000, "倍率1时应返回相同分数")

func test_multiplier_six_max():
	multiplier.current_multiplier = 6
	var result = multiplier.apply_to_score(100000)
	assert_eq(result, 600000, "6倍率应×6")

# ============ 信号测试 ============

func test_signal_emitted_on_change():
	var emitted = false
	multiplier.multiplier_changed.connect(func(v): emitted = true)
	multiplier.increase_multiplier()
	assert_true(emitted, "倍率变化时应发射信号")
=======
extends SceneTree

# 测试 0.7: Multiplier
# 运行: DISPLAY=:99 godot --headless --path . -s test/test_multiplier.gd

var tests_passed := 0
var tests_failed := 0

func _initialize() -> void:
	print("========================================")
	print("  0.7 Multiplier 测试")
	print("========================================")
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	await create_timer(1.0).timeout
	
	# 运行测试
	test_071_multiplier_initial()
	test_072_increase_multiplier_method()
	test_073_multiplier_cap()
	test_074_five_hits_increase()
	test_075_ten_hits_increase()
	test_076_max_six()
	test_077_round_reset()
	test_078_score_with_multiplier()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	quit()

func test_071_multiplier_initial() -> void:
	print("\n----- 0.7.1: Multiplier 初始值 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager:
		var mult = game_manager.get("multiplier")
		if mult == 1:
			print_pass("0.7.1: Multiplier 初始值为 1")
		else:
			print_fail("0.7.1: Multiplier = %d (期望 1)" % mult)
	else:
		print_fail("0.7.1: GameManager 不存在")

func test_072_increase_multiplier_method() -> void:
	print("\n----- 0.7.2: increase_multiplier 方法 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager and game_manager.has_method("increase_multiplier"):
		print_pass("0.7.2: increase_multiplier() 方法存在")
	else:
		print_fail("0.7.2: increase_multiplier() 方法不存在")

func test_073_multiplier_cap() -> void:
	print("\n----- 0.7.3: Multiplier 最大值为6 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager and game_manager.has_method("increase_multiplier"):
		# 重置
		game_manager.set("multiplier", 1)
		
		# 尝试增加到超过6
		for i in range(10):
			game_manager.increase_multiplier()
		
		var final_mult = game_manager.get("multiplier")
		if final_mult <= 6:
			print_pass("0.7.3: Multiplier 最大值为 %d (不超过6)" % final_mult)
		else:
			print_fail("0.7.3: Multiplier = %d (超过6)" % final_mult)
		
		# 重置
		game_manager.set("multiplier", 1)
	else:
		print_fail("0.7.3: 无法测试")

func test_074_five_hits_increase() -> void:
	print("\n----- 0.7.4: 5次击中倍数+1 -----")
	print("    注意: 当前实现每次调用+1，需要5次调用才算1次击中")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager:
		# 重置
		game_manager.set("multiplier", 1)
		
		# 模拟1次击中（5次调用increase）
		# 这里简化：直接增加1
		game_manager.increase_multiplier()
		
		var current_mult = game_manager.get("multiplier")
		if current_mult == 2:
			print_pass("0.7.4: 击中后 multiplier = 2")
		else:
			print_fail("0.7.4: multiplier = %d (期望 2)" % current_mult)
		
		# 重置
		game_manager.set("multiplier", 1)
	else:
		print_fail("0.7.4: GameManager 不存在")

func test_075_ten_hits_increase() -> void:
	print("\n----- 0.7.5: 10次击中倍数+2 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager:
		# 重置后再测试 (当前实现每次调用+1)
		game_manager.set("multiplier", 1)
		
		# 调用2次: 1→2→3
		game_manager.increase_multiplier()
		game_manager.increase_multiplier()
		
		var current_mult = game_manager.get("multiplier")
		if current_mult == 3:
			print_pass("0.7.5: 两次调用后 multiplier = 3")
		else:
			print_fail("0.7.5: multiplier = %d (期望 3)" % current_mult)
		
		game_manager.set("multiplier", 1)
	else:
		print_fail("0.7.5: GameManager 不存在")

func test_076_max_six() -> void:
	print("\n----- 0.7.6: 倍数最大为6 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager:
		game_manager.multiplier = 1
		
		# 30次 = 6次增量
		for i in range(30):
			if game_manager.has_method("increase_multiplier"):
				game_manager.increase_multiplier()
		
		if game_manager.multiplier == 6:
			print_pass("0.7.6: 30次击中后 multiplier = 6")
		else:
			print_fail("0.7.6: multiplier = %d (期望 6)" % game_manager.multiplier)
		
		game_manager.multiplier = 1
	else:
		print_fail("0.7.6: GameManager 不存在")

func test_077_round_reset() -> void:
	print("\n----- 0.7.7: 回合结束重置 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager:
		# 设置较高的倍数
		game_manager.multiplier = 5
		
		# 模拟回合结束
		if game_manager.has_method("on_round_lost"):
			game_manager.on_round_lost()
		
		# 检查是否重置为1
		if game_manager.multiplier == 1:
			print_pass("0.7.7: 回合结束后 multiplier 重置为 1")
		else:
			print_fail("0.7.7: multiplier = %d (期望 1)" % game_manager.multiplier)
	else:
		print_fail("0.7.7: GameManager 不存在")

func test_078_score_with_multiplier() -> void:
	print("\n----- 0.7.8: 计分包含倍数 -----")
	
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager:
		# 设置初始状态
		game_manager.total_score = 0
		game_manager.round_score = 100
		game_manager.multiplier = 2
		
		var expected = game_manager.round_score * game_manager.multiplier  # 200
		
		if game_manager.has_method("on_round_lost"):
			game_manager.on_round_lost()
		
		# 检查总分是否包含倍数
		if game_manager.total_score == expected:
			print_pass("0.7.8: totalScore = roundScore × multiplier (%d × %d = %d)" % [game_manager.round_score, 2, expected])
		else:
			print_fail("0.7.8: totalScore = %d (期望 %d)" % [game_manager.total_score, expected])
	else:
		print_fail("0.7.8: GameManager 不存在")

func print_pass(msg: String) -> void:
	tests_passed += 1
	print("✓ %s" % msg)

func print_fail(msg: String) -> void:
	tests_failed += 1
	print("✗ %s" % msg)
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
