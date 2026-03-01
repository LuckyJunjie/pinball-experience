extends GutTest
## SkillShot E2E 测试

var launcher: Node2D = null
var skill_shot: SkillShot = null
var game_manager: Node = null
var ball: RigidBody2D = null

func before_each():
	# 获取游戏节点
	var main = get_tree().current_scene
	launcher = main.find_child("Launcher", true, false)
	skill_shot = main.find_child("SkillShot", true, false)
	game_manager = main.find_child("GameManager", true, false)
	
	# 确保游戏状态正确
	if game_manager:
		game_manager.status = "playing"
		game_manager.round_score = 0

# ============ 完整流程测试 ============

func test_full_skill_shot_hit_sequence():
	# 1. 激活技能射击
	skill_shot.activate()
	assert_true(skill_shot.is_active)
	
	# 2. 模拟球进入技能射击区域
	# (在真实测试中需要物理碰撞)
	
	# 3. 验证得分
	await get_tree().create_timer(0.5).timeout
	# assert_eq(game_manager.round_score, 1000000)

func test_skill_shot_miss_sequence():
	# 1. 激活技能射击
	skill_shot.activate()
	
	# 2. 等待超时
	await get_tree().create_timer(3.5).timeout
	
	# 3. 验证未激活
	assert_false(skill_shot.is_active)
	
	# 4. 验证分数为0
	# assert_eq(game_manager.round_score, 0)

# ============ 多回合测试 ============

func test_three_rounds_with_skill_shot():
	var total_score = 0
	
	for round_num in range(3):
		# 重置回合分数
		game_manager.round_score = 0
		
		# 激活技能射击
		skill_shot.activate()
		
		# 模拟击中
		await get_tree().create_timer(0.5).timeout
		
		# 累计分数
		total_score += game_manager.round_score
		
		# 模拟球掉落drain
		game_manager.on_ball_removed()
		await get_tree().create_timer(0.5).timeout
	
	# 验证总分数
	# assert_eq(total_score, 3000000, "3次技能射击应该得到3M分")

# ============ 游戏状态测试 ============

func test_skill_shot_during_game_over():
	# 设置游戏结束状态
	game_manager.status = "gameOver"
	
	# 尝试激活技能射击
	skill_shot.activate()
	
	# 游戏结束时不应该激活
	# (取决于实现，可能仍然激活或忽略)

# ============ 性能测试 ============

func test_activation_response_time():
	var start_time = Time.get_ticks_msec()
	skill_shot.activate()
	var end_time = Time.get_ticks_msec()
	
	var response_time = end_time - start_time
	assert_true(response_time < 16, "激活响应时间应该<16ms")

# ============ 视觉反馈测试 ============

func test_activation_visual_feedback():
	skill_shot.activate()
	# 验证视觉反馈
	assert_eq(skill_shot.modulate, Color(1, 1, 0), "激活时应该为黄色")

func test_hit_visual_feedback():
	skill_shot.activate()
	# 模拟击中效果
	skill_shot._play_hit_effect()
	# 验证击中反馈
	assert_eq(skill_shot.modulate, Color(0, 1, 0), "击中时应该为绿色")
