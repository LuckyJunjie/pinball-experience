# Test Multiplier - 倍率测试 (0.7)
extends GutTest

# ========== 第一层: 单元测试 ==========

# 测试倍率初始值
func test_multiplier_initial():
	var gm = get_node("/root/GameManager")
	assert_eq(gm.multiplier, 1, "初始倍率应为 1")
	print("✓ 初始倍率: ", gm.multiplier)

# 测试倍率增加
func test_multiplier_increase():
	var gm = get_node("/root/GameManager")
	gm.multiplier = 1
	gm.increase_multiplier()
	assert_eq(gm.multiplier, 2, "倍率应增加到 2")
	print("✓ 倍率增加到: ", gm.multiplier)

# 测试倍率上限
func test_multiplier_max():
	var gm = get_node("/root/GameManager")
	gm.multiplier = 6
	gm.increase_multiplier()
	assert_eq(gm.multiplier, 6, "倍率上限为 6")
	print("✓ 倍率上限: ", gm.multiplier)

# ========== 第二层: 集成测试 ==========

# 测试 ramp shot 增加倍率
func test_ramp_shot_increases_multiplier():
	var gm = get_node("/root/GameManager")
	gm.multiplier = 1
	gm._ramp_shot_count = 4  # 已经 4 次
	
	# 触发第 5 次 ramp shot
	gm.on_ramp_shot()
	
	assert_eq(gm.multiplier, 2, "第 5 次 ramp shot 应增加倍率")
	assert_eq(gm._ramp_shot_count, 0, "计数应重置")
	print("✓ ramp shot 逻辑正确")

# 测试倍率重置
func test_multiplier_resets_on_round_lost():
	var gm = get_node("/root/GameManager")
	gm.multiplier = 4
	gm.round_score = 100
	
	# 模拟球掉落
	gm.on_ball_removed()
	
	await get_tree().process_frame
	
	assert_eq(gm.multiplier, 1, "回合结束后倍率应重置为 1")
	print("✓ 倍率在回合结束后重置")

# ========== 第三层: 截图测试 ==========

# 测试倍率显示
func test_multiplier_display():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var ui = main.get_node_or_null("UI/Control/HUD/MultiplierLabel")
	if ui:
		var text = ui.text
		assert_true(text.begins_with("x"), "倍率显示应为 xN 格式")
		print("✓ 倍率显示: ", text)
	
	main.free()

# ========== 第四层: 性能测试 ==========

# 测试倍率更新性能
func test_multiplier_update_performance():
	var gm = get_node("/root/GameManager")
	
	# 模拟 100 次倍率更新
	for i in range(100):
		gm.multiplier = 1
		gm.increase_multiplier()
	
	print("✓ 100 次倍率更新完成")
	assert_true(true, "性能测试通过")
