# SkillShot 测试运行器
# 运行 REQ-006 Skill Shot 测试

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  SkillShot (REQ-006) 测试套件")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	run_skill_shot_tests(main)
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_skill_shot_tests(main):
	print("\n----- SkillShot 测试 -----")
	
	# 获取 SkillShot 节点
	var skill_shot = main.find_child("SkillShot", true, false)
	
	if skill_shot == null:
		print("✗ SkillShot 节点不存在")
		tests_failed += 1
		return
	
	print("✓ SkillShot 节点存在")
	tests_passed += 1
	
	# 测试 1: 初始状态
	test_skill_shot_initial_state(skill_shot)
	
	# 测试 2: 激活
	test_skill_shot_activation(skill_shot)
	
	# 测试 3: 超时
	test_skill_shot_timeout(skill_shot)
	
	# 测试 4: 得分
	test_skill_shot_scoring(main, skill_shot)

func test_skill_shot_initial_state(skill_shot):
	print("\n--- 测试: 初始状态 ---")
	
	# 检查初始状态
	if skill_shot.is_active == false:
		print("✓ is_active 初始为 false")
		tests_passed += 1
	else:
		print("✗ is_active 应为 false")
		tests_failed += 1
	
	if skill_shot.time_remaining == 0.0:
		print("✓ time_remaining 初始为 0.0")
		tests_passed += 1
	else:
		print("✗ time_remaining 应为 0.0, 实际: " + str(skill_shot.time_remaining))
		tests_failed += 1
	
	if skill_shot.points == 1000000:
		print("✓ points 初始为 1000000")
		tests_passed += 1
	else:
		print("✗ points 应为 1000000, 实际: " + str(skill_shot.points))
		tests_failed += 1

func test_skill_shot_activation(skill_shot):
	print("\n--- 测试: 激活 ---")
	
	skill_shot.activate()
	
	if skill_shot.is_active == true:
		print("✓ activate() 后 is_active 为 true")
		tests_passed += 1
	else:
		print("✗ activate() 后 is_active 应为 true")
		tests_failed += 1
	
	if skill_shot.time_remaining > 0:
		print("✓ activate() 后 time_remaining > 0")
		tests_passed += 1
	else:
		print("✗ activate() 后 time_remaining 应 > 0")
		tests_failed += 1

func test_skill_shot_timeout(skill_shot):
	print("\n--- 测试: 超时 ---")
	
	# 确保激活
	skill_shot.activate()
	
	# 等待超时 (3秒 + buffer)
	await create_timer(3.5).timeout
	
	if skill_shot.is_active == false:
		print("✓ 超时后 is_active 为 false")
		tests_passed += 1
	else:
		print("✗ 超时后 is_active 应为 false")
		tests_failed += 1
	
	if skill_shot.time_remaining <= 0:
		print("✓ 超时后 time_remaining <= 0")
		tests_passed += 1
	else:
		print("✗ 超时后 time_remaining 应 <= 0")
		tests_failed += 1

func test_skill_shot_scoring(main, skill_shot):
	print("\n--- 测试: 得分 ---")
	
	# 获取 GameManager
	var game_manager = main.find_child("GameManager", true, false)
	
	if game_manager == null:
		print("✗ GameManager 不存在")
		tests_failed += 1
		return
	
	print("✓ GameManager 存在")
	tests_passed += 1
	
	# 记录初始分数
	var initial_score = game_manager.round_score
	print("  初始分数: " + str(initial_score))
	
	# 激活 skill shot
	skill_shot.activate()
	
	# 模拟击中 - 直接调用 hit 信号
	# 注意: 在实际测试中需要物理碰撞
	var hit_received = false
	skill_shot.hit.connect(func(points): 
		hit_received = true
		print("  收到击中信号: " + str(points) + " 分")
	)
	
	# 手动触发 _on_body_entered 来模拟球进入
	# 创建假的 ball 对象
	var fake_ball = Node2D.new()
	fake_ball.add_to_group("ball")
	root.add_child(fake_ball)
	
	# 触发碰撞回调
	skill_shot._on_body_entered(fake_ball)
	
	await create_timer(0.1).timeout
	
	# 验证分数增加
	var new_score = game_manager.round_score
	print("  新分数: " + str(new_score))
	
	if new_score == initial_score + 1000000:
		print("✓ 击中后分数增加 1,000,000")
		tests_passed += 1
	else:
		print("✗ 分数应增加 1,000,000, 实际增加: " + str(new_score - initial_score))
		tests_failed += 1
	
	# 验证 is_active 已重置
	if skill_shot.is_active == false:
		print("✓ 击中后 is_active 为 false")
		tests_passed += 1
	else:
		print("✗ 击中后 is_active 应为 false")
		tests_failed += 1
	
	# 清理
	fake_ball.free()
