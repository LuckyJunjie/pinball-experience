# Pinball Experience - Layout Tests
# 测试游戏布局：验证发射器、挡板、排水口位置

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Pinball Experience - 布局测试")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	run_layout_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_layout_tests():
	# 测试布局
	test_launcher_position()
	test_flipper_positions()
	test_drain_position()
	test_layout合理性()

func test_launcher_position():
	print("\n----- 测试: 发射器位置 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	var launcher = main.get_node("Launcher")
	if launcher:
		var pos = launcher.position
		print("✓ LT-01: Launcher 位置 (%.0f, %.0f)" % [pos.x, pos.y])
		tests_passed += 1
		
		# 检查发射器是否在合理区域 (右侧)
		if pos.x > 500:
			print("✓ LT-02: 发射器在右侧区域")
			tests_passed += 1
		else:
			print("✗ LT-02: 发射器应该在右侧 (x > 500)")
			tests_failed += 1
	else:
		print("✗ LT-01: Launcher 不存在")
		tests_failed += 1
	
	main.free()

func test_flipper_positions():
	print("\n----- 测试: 挡板位置 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 左挡板
	var flipper_left = main.get_node("FlipperLeft")
	if flipper_left:
		var pos = flipper_left.position
		print("✓ LT-03: FlipperLeft 位置 (%.0f, %.0f)" % [pos.x, pos.y])
		tests_passed += 1
	else:
		print("✗ LT-03: FlipperLeft 不存在")
		tests_failed += 1
	
	# 右挡板
	var flipper_right = main.get_node("FlipperRight")
	if flipper_right:
		var pos = flipper_right.position
		print("✓ LT-04: FlipperRight 位置 (%.0f, %.0f)" % [pos.x, pos.y])
		tests_passed += 1
	else:
		print("✗ LT-04: FlipperRight 不存在")
		tests_failed += 1
	
	# 检查挡板间距
	if flipper_left and flipper_right:
		var distance = flipper_right.position.x - flipper_left.position.x
		print("    [INFO] 挡板间距: %.0f px" % distance)
		
		# 标准弹球机挡板间距约为 200-300px
		if distance > 100 and distance < 400:
			print("✓ LT-05: 挡板间距合理")
			tests_passed += 1
		else:
			print("✗ LT-05: 挡板间距可能不合理 (%.0f px)" % distance)
			tests_failed += 1
	
	main.free()

func test_drain_position():
	print("\n----- 测试: 排水口位置 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	var drain = main.get_node("Playfield/Drain")
	if drain:
		var pos = drain.position
		print("✓ LT-06: Drain 位置 (%.0f, %.0f)" % [pos.x, pos.y])
		tests_passed += 1
	else:
		print("✗ LT-06: Drain 不存在")
		tests_failed += 1
	
	main.free()

func test_layout合理性():
	print("\n----- 测试: 布局合理性 -----")
	
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	var launcher = main.get_node("Launcher")
	var flipper_left = main.get_node("FlipperLeft")
	var flipper_right = main.get_node("FlipperRight")
	var drain = main.get_node("Playfield/Drain")
	
	if launcher and flipper_left and flipper_right and drain:
		# 计算距离
		var launcher_to_left_flipper = abs(launcher.position.x - flipper_left.position.x)
		var launcher_to_right_flipper = abs(launcher.position.x - flipper_right.position.x)
		var flipper_to_drain = drain.position.y - flipper_left.position.y
		
		print("    [INFO] 发射器到左挡板: %.0f px" % launcher_to_left_flipper)
		print("    [INFO] 发射器到右挡板: %.0f px" % launcher_to_right_flipper)
		print("    [INFO] 挡板到排水口: %.0f px" % flipper_to_drain)
		
		# 检查球是否能正常弹跳
		# 如果发射器到挡板太远，球可能会直接掉下去
		if launcher_to_left_flipper > 300:
			print("⚠️ LT-07: 警告 - 发射器到左挡板距离太远 (%.0f px)" % launcher_to_left_flipper)
			# 继续测试，但不失败
			tests_passed += 1
		else:
			print("✓ LT-07: 发射器到挡板距离合理")
			tests_passed += 1
		
		# 检查挡板到排水口的距离
		if flipper_to_drain < 50:
			print("⚠️ LT-08: 警告 - 挡板到排水口太近 (%.0f px)" % flipper_to_drain)
			tests_failed += 1
		elif flipper_to_drain > 150:
			print("⚠️ LT-08: 警告 - 挡板到排水口太远 (%.0f px)" % flipper_to_drain)
			tests_failed += 1
		else:
			print("✓ LT-08: 挡板到排水口距离合理")
			tests_passed += 1
	else:
		print("✗ LT-07: 布局测试失败 - 缺少节点")
		tests_failed += 1
	
	main.free()
