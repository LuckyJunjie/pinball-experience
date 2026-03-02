<<<<<<< HEAD
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
=======
extends SceneTree

# 测试 0.6: Skill Shot
# 运行: DISPLAY=:99 godot --headless --path . -s test/test_skill_shot.gd

var tests_passed := 0
var tests_failed := 0

func _initialize() -> void:
	print("========================================")
	print("  0.6 Skill Shot 测试")
	print("========================================")
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	await create_timer(1.0).timeout
	
	# 运行测试
	test_061_skillshot_exists()
	test_062_skillshot_sprite()
	test_063_skill_shot_hit_area()
	test_064_skill_shot_scoring()
	
	print("========================================")
	print("  测试结果: %d 通过, %d 失败" % [tests_passed, tests_failed])
	print("========================================")
	
	quit()

func test_061_skillshot_exists() -> void:
	print("\n----- 0.6.1: SkillShot 节点存在 -----")
	
	# 查找 SkillShot 节点
	var skill_shot = root.find_child("SkillShot", true, false)
	if skill_shot:
		print_pass("0.6.1: SkillShot 节点存在")
	else:
		# 尝试查找可能的变体名称
		var alternatives = ["SkillShot", "skill_shot", "SkillTarget", "SkillTargetArea"]
		var found = false
		for name in alternatives:
			if root.find_child(name, true, false):
				found = true
				break
		
		if found:
			print_pass("0.6.1: SkillShot 节点存在 (变体)")
		else:
			print_fail("0.6.1: SkillShot 节点不存在 - 需要实现!")

func test_062_skillshot_sprite() -> void:
	print("\n----- 0.6.2: SkillShot 精灵图 -----")
	
	# 检查精灵图资源是否存在
	var sprite_path = "res://assets/sprites/skill_shot/"
	var sprites = ["lit.png", "dimmed.png", "pin.png", "decal.png"]
	var all_exist = true
	
	for sprite in sprites:
		var full_path = sprite_path + sprite
		var file = FileAccess.file_exists(full_path)
		if file:
			print("    ✓ %s 存在" % sprite)
		else:
			print("    ✗ %s 不存在" % sprite)
			all_exist = false
	
	if all_exist:
		print_pass("0.6.2: 所有 SkillShot 精灵图存在")
	else:
		print_fail("0.6.2: 部分精灵图缺失")

func test_063_skill_shot_hit_area() -> void:
	print("\n----- 0.6.3: SkillShot 碰撞区域 -----")
	
	# 手动遍历节点
	var area_count = 0
	var queue = [root]
	
	while queue.size() > 0:
		var node = queue.pop_front()
		if node is Area2D:
			area_count += 1
			print("    找到 Area2D: %s" % node.name)
		for child in node.get_children():
			queue.append(child)
	
	if area_count > 0:
		print_pass("0.6.3: 找到 %d 个 Area2D 碰撞区域" % area_count)
	else:
		print_fail("0.6.3: 没有找到碰撞区域 - SkillShot 可能未实现")

func test_064_skill_shot_scoring() -> void:
	print("\n----- 0.6.4: Skill Shot 计分逻辑 -----")
	
	# 检查 GameManager 是否有计分方法
	var game_manager = root.find_child("GameManager", true, false)
	if game_manager and game_manager.has_method("add_score"):
		# 测试当前分数
		var initial_score = game_manager.round_score
		game_manager.add_score(1000000, "skill_shot")
		var new_score = game_manager.round_score
		
		if new_score == initial_score + 1000000:
			print_pass("0.6.4: add_score(1000000) 工作正常")
		else:
			print_fail("0.6.4: add_score(1000000) 计分错误")
	else:
		print_fail("0.6.4: add_score 方法不存在")

func print_pass(msg: String) -> void:
	tests_passed += 1
	print("✓ %s" % msg)

func print_fail(msg: String) -> void:
	tests_failed += 1
	print("✗ %s" % msg)
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
