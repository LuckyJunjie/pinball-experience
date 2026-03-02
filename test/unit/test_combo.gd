extends GutTest
## ComboManager 单元测试

var combo_manager: Node = null

func before_each():
	# 创建 ComboManager 节点
	combo_manager = load("res://scripts/ComboManager.gd").new()
	add_child(combo_manager)
	
	# 等待 _ready 完成
	await get_tree().process_frame

# ============ 初始状态测试 ============

func test_combo_initial_count():
	assert_eq(combo_manager.combo_count, 0, "初始 Combo 数应为 0")

func test_combo_initial_timer():
	assert_eq(combo_manager.combo_timer, 0.0, "初始计时器应为 0")

func test_combo_max_value():
	assert_eq(combo_manager.MAX_COMBO, 10, "最大 Combo 应为 10")

func test_combo_timeout_value():
	assert_eq(combo_manager.COMBO_TIMEOUT, 2.0, "超时时间应为 2 秒")

# ============ Combo 增加测试 ============

func test_increase_combo_first_time():
	combo_manager.increase_combo()
	assert_eq(combo_manager.combo_count, 1, "第一次增加后 Combo 应为 1")
	assert_eq(combo_manager.get_combo_multiplier(), 2, "倍率应为 x2")

func test_increase_combo_multiple():
	combo_manager.increase_combo()
	combo_manager.increase_combo()
	combo_manager.increase_combo()
	assert_eq(combo_manager.combo_count, 3, "3次增加后 Combo 应为 3")
	assert_eq(combo_manager.get_combo_multiplier(), 4, "倍率应为 x4")

func test_combo_max_limit():
	# 增加到超过最大值
	for i in range(15):
		combo_manager.increase_combo()
	assert_eq(combo_manager.combo_count, 10, "Combo 不应超过最大值 10")
	assert_eq(combo_manager.get_combo_multiplier(), 11, "最大倍率应为 x11")

# ============ 计时器测试 ============

func test_combo_timer_reset_on_increase():
	combo_manager.combo_timer = 0.5
	combo_manager.increase_combo()
	assert_eq(combo_manager.combo_timer, 2.0, "增加 Combo 后计时器应重置为 2 秒")

# ============ 超时重置测试 ============

func test_combo_reset_after_timeout():
	combo_manager.increase_combo()
	combo_manager.combo_timer = -0.1  # 模拟超时
	
	# 调用 _process 模拟超时
	combo_manager._process(0.1)
	
	assert_eq(combo_manager.combo_count, 0, "超时后 Combo 应重置为 0")
	assert_eq(combo_manager.get_combo_multiplier(), 1, "超时后倍率应为 x1")

# ============ 倍率计算测试 ============

func test_multiplier_calculation():
	# combo_count=0 → x1
	assert_eq(combo_manager.get_combo_multiplier(), 1, "无 Combo 时倍率为 x1")
	
	combo_manager.combo_count = 1
	assert_eq(combo_manager.get_combo_multiplier(), 2, "Combo 1 时倍率为 x2")
	
	combo_manager.combo_count = 5
	assert_eq(combo_manager.get_combo_multiplier(), 6, "Combo 5 时倍率为 x6")

func test_calculate_combo_score():
	combo_manager.combo_count = 2  # x3
	var score = combo_manager.calculate_combo_score(1000)
	assert_eq(score, 3000, "1000 × 3 = 3000")

func test_calculate_combo_score_no_combo():
	combo_manager.combo_count = 0  # x1
	var score = combo_manager.calculate_combo_score(5000)
	assert_eq(score, 5000, "5000 × 1 = 5000")

# ============ 强制重置测试 ============

func test_force_reset():
	combo_manager.combo_count = 5
	combo_manager.combo_timer = 1.5
	
	combo_manager.force_reset()
	
	assert_eq(combo_manager.combo_count, 0, "强制重置后 Combo 应为 0")
	assert_eq(combo_manager.combo_timer, 0.0, "强制重置后计时器应为 0")

# ============ 公开方法测试 ============

func test_get_combo_count():
	assert_eq(combo_manager.get_combo_count(), 0, "get_combo_count 应返回 0")
	combo_manager.combo_count = 7
	assert_eq(combo_manager.get_combo_count(), 7, "get_combo_count 应返回 7")

func test_get_combo_timer():
	combo_manager.combo_timer = 1.5
	assert_eq(combo_manager.get_combo_timer(), 1.5, "get_combo_timer 应返回正确值")

func test_get_combo_timeout():
	assert_eq(combo_manager.get_combo_timeout(), 2.0, "get_combo_timeout 应返回 2.0")

# ============ 信号测试 ============

func test_signal_emitted_on_increase():
	var emitted = false
	var new_combo = -1
	combo_manager.combo_increased.connect(func(val): 
		emitted = true
		new_combo = val
	)
	
	combo_manager.increase_combo()
	
	assert_true(emitted, "combo_increased 信号应发射")
	assert_eq(new_combo, 1, "信号参数应为 1")

func test_signal_emitted_on_reset():
	var emitted = false
	combo_manager.combo_count = 3
	combo_manager.combo_reset.connect(func(): emitted = true)
	
	combo_manager.force_reset()
	
	assert_true(emitted, "combo_reset 信号应发射")

func test_timeout_signal_emitted():
	var emitted = false
	combo_manager.combo_timeout.connect(func(): emitted = true)
	
	combo_manager.increase_combo()
	combo_manager.combo_timer = -0.1
	combo_manager._process(0.1)
	
	assert_true(emitted, "combo_timeout 信号应发射")
