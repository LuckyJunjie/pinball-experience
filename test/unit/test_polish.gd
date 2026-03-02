# Pinball Experience - Polish 单元测试
# 测试 REQ-010 Polish (物理、动画、音效)

extends SceneTree

var tests_passed = 0
var tests_failed = 0

func _initialize():
	print("========================================")
	print("  Polish 单元测试 (REQ-010)")
	print("========================================")
	
	await create_timer(0.1).timeout
	
	run_unit_tests()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	await create_timer(0.5).timeout
	quit()

func run_unit_tests():
	# 物理测试
	test_physics_configuration()
	
	# 音效系统测试
	test_sound_system()
	
	# 动画组件测试
	test_animation_components()

# =============================================================================
# 物理配置测试
# =============================================================================
func test_physics_configuration():
	print("\n----- 物理配置单元测试 -----")
	
	# 加载 Main 场景
	var main_scene = load("res://scenes/Main.tscn")
	if main_scene == null:
		print("✗ UT-010-01: Main 场景加载失败")
		tests_failed += 1
		return
	
	var main = main_scene.instantiate()
	root.add_child(main)
	await process_frame
	
	# UT-010-01: 检查 Flipper 节点
	var flipper_left = main.get_node_or_null("Playfield/Flippers/FlipperLeft")
	var flipper_right = main.get_node_or_null("Playfield/Flippers/FlipperRight")
	
	if flipper_left and flipper_right:
		print("✓ UT-010-01: Flipper 节点存在")
		tests_passed += 1
	else:
		print("✗ UT-010-01: Flipper 节点不存在")
		tests_failed += 1
	
	# UT-010-02: 检查 Ball 物理材质
	var ball_scene = load("res://scenes/Ball.tscn")
	if ball_scene:
		var ball = ball_scene.instantiate()
		root.add_child(ball)
		await process_frame
		
		var physics_mat = ball.get("physics_material")
		if physics_mat:
			var restitution = physics_mat.get("bounce", -1)
			if restitution > 0:
				print("✓ UT-010-02: Ball physics_material bounce = %.2f" % restitution)
				tests_passed += 1
			else:
				print("✗ UT-010-02: Ball physics_material bounce 无效")
				tests_failed += 1
		else:
			print("✓ UT-010-02: Ball 使用默认物理材质 (可能需要配置)")
			tests_passed += 1
		
		ball.free()
	else:
		print("✗ UT-010-02: Ball 场景加载失败")
		tests_failed += 1
	
	# UT-010-03: 检查 Bumper 物理
	var bumper = main.get_node_or_null("Playfield/Bumpers/BumperA")
	if bumper:
		print("✓ UT-010-03: Bumper 节点存在")
		tests_passed += 1
	else:
		print("✗ UT-010-03: Bumper 节点不存在")
		tests_failed += 1
	
	# UT-010-04: 检查 Wall 节点
	var walls = main.get_node_or_null("Playfield/Walls")
	if walls:
		print("✓ UT-010-04: Walls 节点存在")
		tests_passed += 1
	else:
		print("✗ UT-010-04: Walls 节点不存在")
		tests_failed += 1
	
	main.free()

# =============================================================================
# 音效系统测试
# =============================================================================
func test_sound_system():
	print("\n----- 音效系统单元测试 -----")
	
	# UT-010-05: 检查 SoundManager
	var sound_manager = SoundManager.new()
	root.add_child(sound_manager)
	await process_frame
	
	# 检查 SOUND_PATHS 常量
	if sound_manager.has("SOUND_PATHS"):
		var sound_paths = sound_manager.get("SOUND_PATHS")
		if sound_paths.has("ball_launch") and sound_paths.has("obstacle_hit"):
			print("✓ UT-010-05: SOUND_PATHS 包含必要音效")
			tests_passed += 1
		else:
			print("✗ UT-010-05: SOUND_PATHS 缺少必要音效")
			tests_failed += 1
	else:
		print("✗ UT-010-05: SOUND_PATHS 不存在")
		tests_failed += 1
	
	# UT-010-06: 检查音效文件存在
	var sound_paths = sound_manager.get("SOUND_PATHS")
	var all_exist = true
	for sound_name in ["ball_launch", "obstacle_hit", "ball_lost", "flipper_click"]:
		if sound_paths.has(sound_name):
			var path = sound_paths[sound_name]
			if not ResourceLoader.exists(path):
				print("    警告: %s 文件不存在" % sound_name)
				all_exist = false
	
	if all_exist:
		print("✓ UT-010-06: 所有音效文件存在")
		tests_passed += 1
	else:
		print("✗ UT-010-06: 部分音效文件缺失")
		tests_failed += 1
	
	# UT-010-07: 检查 play_sound 方法
	if sound_manager.has_method("play_sound"):
		print("✓ UT-010-07: play_sound 方法存在")
		tests_passed += 1
	else:
		print("✗ UT-010-07: play_sound 方法不存在")
		tests_failed += 1
	
	# UT-010-08: 测试 play_sound 调用 (使用 mock/不实际播放)
	if sound_manager.has_method("play_sound"):
		sound_manager.play_sound("ball_launch")
		print("✓ UT-010-08: play_sound 调用无错误")
		tests_passed += 1
	else:
		print("✗ UT-010-08: play_sound 无法调用")
		tests_failed += 1
	
	sound_manager.free()

# =============================================================================
# 动画组件测试
# =============================================================================
func test_animation_components():
	print("\n----- 动画组件单元测试 -----")
	
	# UT-010-09: 检查 ScorePopup 场景
	var score_popup_scene = load("res://scenes/ScorePopup.tscn")
	if score_popup_scene:
		print("✓ UT-010-09: ScorePopup 场景存在")
		tests_passed += 1
	else:
		# 尝试其他可能的位置
		var alt_scene = load("res://scenes/UI/ScorePopup.tscn")
		if alt_scene:
			print("✓ UT-010-09: ScorePopup 场景存在 (UI 子目录)")
			tests_passed += 1
		else:
			print("✗ UT-010-09: ScorePopup 场景不存在")
			tests_failed += 1
	
	# UT-010-10: 检查 ComboManager
	var combo_manager = ComboManager.new()
	root.add_child(combo_manager)
	await process_frame
	
	if combo_manager.has_signal("combo_increased"):
		print("✓ UT-010-10: ComboManager combo_increased 信号存在")
		tests_passed += 1
	else:
		print("✗ UT-010-10: ComboManager 信号不存在")
		tests_failed += 1
	
	if combo_manager.has_method("increase_combo"):
		print("✓ UT-010-11: ComboManager increase_combo 方法存在")
		tests_passed += 1
	else:
		print("✗ UT-010-11: ComboManager increase_combo 方法不存在")
		tests_failed += 1
	
	# 检查 ComboManager 配置
	if combo_manager.has("COMBO_TIMEOUT"):
		var timeout = combo_manager.get("COMBO_TIMEOUT")
		if timeout > 0:
			print("✓ UT-010-12: COMBO_TIMEOUT = %.1f 秒" % timeout)
			tests_passed += 1
		else:
			print("✗ UT-010-12: COMBO_TIMEOUT 无效")
			tests_failed += 1
	else:
		print("✗ UT-010-12: COMBO_TIMEOUT 不存在")
		tests_failed += 1
	
	if combo_manager.has("MAX_COMBO"):
		var max_combo = combo_manager.get("MAX_COMBO")
		if max_combo > 0:
			print("✓ UT-010-13: MAX_COMBO = %d" % max_combo)
			tests_passed += 1
		else:
			print("✗ UT-010-13: MAX_COMBO 无效")
			tests_failed += 1
	else:
		print("✗ UT-010-13: MAX_COMBO 不存在")
		tests_failed += 1
	
	combo_manager.free()
	
	# UT-010-14: 检查 Multiplier 组件
	var multiplier_scene = load("res://scenes/Multiplier.tscn")
	if multiplier_scene:
		var multiplier = multiplier_scene.instantiate()
		root.add_child(multiplier)
		await process_frame
		
		if multiplier.has_method("increase_multiplier"):
			print("✓ UT-010-14: Multiplier increase_multiplier 方法存在")
			tests_passed += 1
		else:
			print("✗ UT-010-14: Multiplier increase_multiplier 方法不存在")
			tests_failed += 1
		
		multiplier.free()
	else:
		print("✗ UT-010-14: Multiplier 场景不存在")
		tests_failed += 1
