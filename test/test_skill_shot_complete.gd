extends GutTest
## SkillShot 完整单元测试套件

var skill_shot: SkillShot = null

func before_each():
	skill_shot = SkillShot.new()
	add_child(skill_shot)

# ============ 初始状态测试 ============

func test_initial_state_is_inactive():
	assert_eq(skill_shot.is_active, false, "初始状态应该未激活")

func test_initial_time_remaining():
	assert_eq(skill_shot.time_remaining, 0.0, "初始时间应该为0")

func test_initial_points():
	assert_eq(skill_shot.points, 1000000, "初始分数应该为1M")

func test_initial_color():
	assert_eq(skill_shot.modulate, Color(1, 1, 1), "初始颜色为白色")

# ============ 激活测试 ============

func test_activate_sets_active():
	skill_shot.activate()
	assert_true(skill_shot.is_active, "激活后应该处于激活状态")

func test_activate_sets_time():
	skill_shot.activate()
	assert_true(skill_shot.time_remaining > 0, "激活后时间应该大于0")

func test_activate_starts_timer():
	skill_shot.activate()
	assert_true(skill_shot._timer.is_inside_tree(), "计时器应该启动")

func test_activate_changes_color():
	skill_shot.activate()
	assert_eq(skill_shot.modulate, Color(1, 1, 0), "激活后颜色应该为黄色")

# ============ 停用测试 ============

func test_deactivate_resets_active():
	skill_shot.activate()
	skill_shot.deactivate()
	assert_false(skill_shot.is_active, "停用后应该未激活")

func test_deactivate_resets_time():
	skill_shot.activate()
	skill_shot.deactivate()
	assert_eq(skill_shot.time_remaining, 0.0, "停用后时间应该为0")

func test_deactivate_resets_color():
	skill_shot.activate()
	skill_shot.deactivate()
	assert_eq(skill_shot.modulate, Color(1, 1, 1), "停用后颜色应该恢复白色")

func test_deactivate_stops_timer():
	skill_shot.activate()
	skill_shot.deactivate()
	assert_false(skill_shot._timer.is_processing(), "停用后计时器应该停止")

# ============ 超时测试 ============

func test_timeout_deactivates():
	skill_shot.activate()
	await get_tree().create_timer(3.5).timeout
	assert_false(skill_shot.is_active, "超时后应该停用")

func test_timeout_resets_time():
	skill_shot.activate()
	await get_tree().create_timer(3.5).timeout
	assert_eq(skill_shot.time_remaining, 0.0, "超时时时间应该为0")

# ============ 边界测试 ============

func test_activate_at_boundary():
	skill_shot.activation_time = 0.1
	skill_shot.activate()
	assert_true(skill_shot.is_active)
	await get_tree().create_timer(0.2).timeout
	assert_false(skill_shot.is_active, "短时间激活后应该快速过期")

func test_multiple_activations():
	skill_shot.activate()
	await get_tree().create_timer(1.0).timeout
	skill_shot.activate()
	assert_true(skill_shot.is_active, "重复激活应该正常工作")

# ============ 配置测试 ============

func test_custom_activation_time():
	skill_shot.activation_time = 5.0
	skill_shot.activate()
	assert_eq(skill_shot.time_remaining, 5.0, "应该使用自定义激活时间")

func test_custom_points():
	skill_shot.points = 500000
	assert_eq(skill_shot.points, 500000, "应该使用自定义分数")
