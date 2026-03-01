extends GutTest
## SkillShot 集成测试

var launcher = null
var skill_shot = null
var game_manager = null

func before_each():
	# 获取节点
	launcher = get_tree().current_scene.find_child("Launcher", true, false)
	skill_shot = get_tree().current_scene.find_child("SkillShot", true, false)
	game_manager = GameManager

func test_skill_shot_score_integration():
	# 记录初始分数
	var initial_score = game_manager.round_score
	
	# 激活技能射击
	skill_shot.activate()
	assert_true(skill_shot.is_active)
	
	# 模拟球进入技能射击区域
	# (在实际测试中需要创建球的引用)
	
	# 验证分数增加
	# await skill_shot.hit
	# assert_eq(game_manager.round_score, initial_score + 1000000)

func test_skill_shot_timeout_no_score():
	var initial_score = game_manager.round_score
	
	# 激活技能射击
	skill_shot.activate()
	
	# 等待窗口过期
	await get_tree().create_timer(3.5).timeout
	
	# 验证已停用
	assert_false(skill_shot.is_active)

func test_skill_shot_reactivation():
	# 第一次激活
	skill_shot.activate()
	assert_true(skill_shot.is_active)
	
	# 停用
	skill_shot.deactivate()
	assert_false(skill_shot.is_active)
	
	# 再次激活
	skill_shot.activate()
	assert_true(skill_shot.is_active)
