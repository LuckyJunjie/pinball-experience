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
