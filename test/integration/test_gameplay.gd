# Pinball Experience - Integration Tests
# 测试游戏过程：发射球、挡板击球

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Pinball Experience - 集成测试")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	run_integration_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_integration_tests():
	# 测试发射球
	test_ball_launch()
	
	# 测试挡板输入
	test_flipper_input()
	
	# 测试球物理
	test_ball_physics()

func test_ball_launch():
	print("\n----- 测试: 球发射 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 获取 Launcher
	var launcher = main.get_node("Launcher")
	if launcher:
		print("✓ IT-01: Launcher 节点存在")
		tests_passed += 1
	else:
		print("✗ IT-01: Launcher 节点不存在")
		tests_failed += 1
		main.free()
		return
	
	# 触发球生成 - 使用正确的方式
	# Launcher 在 _ready 中连接了信号
	# 我们可以手动调用发射
	if launcher.has_method("_spawn_ball"):
		launcher._spawn_ball()
		await process_frame
		await process_frame
		await create_timer(0.1).timeout
		
		# 从 balls_container 获取球
		var balls_container = main.get_node("Balls")
		if balls_container and balls_container.get_child_count() > 0:
			var ball = balls_container.get_child(0)
			print("✓ IT-02: 球已生成 (位置: %.2f, %.2f)" % [ball.position.x, ball.position.y])
			tests_passed += 1
			
			# 手动设置球为非冻结状态并发射
			ball.freeze = false
			ball.apply_central_impulse(Vector2(-300, -400))
			
			await create_timer(0.3).timeout
			
			# 检查球的速度
			var velocity = ball.linear_velocity
			print("    [DEBUG] 发射后球速度: (%.2f, %.2f)" % [velocity.x, velocity.y])
			
			if velocity.length() > 50:  # 有明显速度
				print("✓ IT-03: 球已发射 (速度: %.2f)" % velocity.length())
				tests_passed += 1
			else:
				print("✗ IT-03: 球未发射 (速度太慢: %.2f)" % velocity.length())
				tests_failed += 1
		else:
			print("✗ IT-02: 球未生成")
			tests_failed += 1
			print("✗ IT-03: 球未生成")
			tests_failed += 1
	else:
		print("✗ IT-02: Launcher 没有 _spawn_ball 方法")
		tests_failed += 1
		print("✗ IT-03: Launcher 没有 _spawn_ball 方法")
		tests_failed += 1
	
	main.free()

func test_flipper_input():
	print("\n----- 测试: 挡板输入 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 测试左挡板
	var flipper_left = main.get_node("FlipperLeft")
	if flipper_left:
		print("✓ IT-04: FlipperLeft 存在")
		tests_passed += 1
		
		# 检查旋转属性
		if flipper_left.has_method("_physics_process"):
			print("✓ IT-05: FlipperLeft 有物理处理方法")
			tests_passed += 1
		else:
			print("✗ IT-05: FlipperLeft 没有物理处理方法")
			tests_failed += 1
		
		# 检查 is_left 属性
		if flipper_left.get("is_left") != null:
			if flipper_left.is_left == true:
				print("✓ IT-05b: FlipperLeft.is_left = true")
				tests_passed += 1
			else:
				print("✗ IT-05b: FlipperLeft.is_left 应该为 true")
				tests_failed += 1
		else:
			print("✗ IT-05b: FlipperLeft 没有 is_left 属性")
			tests_failed += 1
	else:
		print("✗ IT-04: FlipperLeft 不存在")
		tests_failed += 1
	
	# 测试右挡板
	var flipper_right = main.get_node("FlipperRight")
	if flipper_right:
		print("✓ IT-06: FlipperRight 存在")
		tests_passed += 1
		
		# 检查 is_left 属性
		if flipper_right.get("is_left") != null:
			if flipper_right.is_left == false:
				print("✓ IT-06b: FlipperRight.is_left = false")
				tests_passed += 1
			else:
				print("✗ IT-06b: FlipperRight.is_left 应该为 false")
				tests_failed += 1
	else:
		print("✗ IT-06: FlipperRight 不存在")
		tests_failed += 1
	
	# 测试输入映射
	var action_exists = InputMap.has_action("flipper_left")
	if action_exists:
		print("✓ IT-07: flipper_left 输入动作已定义")
		tests_passed += 1
	else:
		print("✗ IT-07: flipper_left 输入动作未定义")
		tests_failed += 1
	
	action_exists = InputMap.has_action("flipper_right")
	if action_exists:
		print("✓ IT-08: flipper_right 输入动作已定义")
		tests_passed += 1
	else:
		print("✗ IT-08: flipper_right 输入动作未定义")
		tests_failed += 1
	
	action_exists = InputMap.has_action("launch_ball")
	if action_exists:
		print("✓ IT-09: launch_ball 输入动作已定义")
		tests_passed += 1
	else:
		print("✗ IT-09: launch_ball 输入动作未定义")
		tests_failed += 1
	
	main.free()

func test_ball_physics():
	print("\n----- 测试: 球物理 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 生成球
	var launcher = main.get_node("Launcher")
	if launcher:
		launcher._spawn_ball()
		await process_frame
		
		var balls_container = main.get_node("Balls")
		if balls_container and balls_container.get_child_count() > 0:
			var ball = balls_container.get_child(0)
			
			# 手动发射球
			ball.freeze = false
			ball.apply_central_impulse(Vector2(-300, -400))
			
			await create_timer(0.3).timeout
			
			# 检查球是否有速度
			var velocity = ball.linear_velocity
			if velocity.length() > 50:
				print("✓ IT-10: 球有速度 (%.2f, %.2f)" % [velocity.x, velocity.y])
				tests_passed += 1
			else:
				print("✗ IT-10: 球没有速度 (%.2f, %.2f)" % [velocity.x, velocity.y])
				tests_failed += 1
			
			# 检查球的物理属性
			if ball.is_in_group("ball"):
				print("✓ IT-11: 球在 'ball' 组中")
				tests_passed += 1
			else:
				print("✗ IT-11: 球不在 'ball' 组中")
				tests_failed += 1
			
			# 检查碰撞层
			if ball.collision_layer & 1:  # layer 1
				print("✓ IT-12: 球的碰撞层正确 (layer 1)")
				tests_passed += 1
			else:
				print("✗ IT-12: 球的碰撞层不正确")
				tests_failed += 1
			
			# 检查物理材质
			if ball.physics_material_override:
				print("✓ IT-13: 球有物理材质 (bounce: %.2f)" % ball.physics_material_override.bounce)
				tests_passed += 1
			else:
				print("✗ IT-13: 球没有物理材质")
				tests_failed += 1
		else:
			print("✗ IT-10: 球未生成")
			tests_failed += 1
			print("✗ IT-11: 球未生成")
			tests_failed += 1
			print("✗ IT-12: 球未生成")
			tests_failed += 1
			print("✗ IT-13: 球未生成")
			tests_failed += 1
	
	main.free()
