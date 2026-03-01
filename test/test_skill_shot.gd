extends GutTest
## SkillShot 单元测试

var skill_shot = null

func before_each():
	skill_shot = SkillShot.new()
	add_child(skill_shot)

func test_initial_state():
	assert_eq(skill_shot.is_active, false)
	assert_eq(skill_shot.time_remaining, 0.0)
	assert_eq(skill_shot.points, 1000000)

func test_activate():
	skill_shot.activate()
	assert_true(skill_shot.is_active)
	assert_true(skill_shot.time_remaining > 0)

func test_deactivate():
	skill_shot.activate()
	skill_shot.deactivate()
	assert_eq(skill_shot.is_active, false)

func test_timeout():
	skill_shot.activate()
	await get_tree().create_timer(3.5).timeout
	assert_eq(skill_shot.is_active, false)
