# Test Obstacles - 障碍物和计分测试
extends GutTest

# 测试障碍物节点存在
func test_obstacle_nodes_exist():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	assert_not_null(obstacles, "Obstacles 节点应存在")
	
	var obstacle_count = obstacles.get_child_count()
	assert_true(obstacle_count > 0, "应该至少有一个障碍物")
	
	print("障碍物数量: ", obstacle_count)
	
	main.free()

# 测试障碍物是 Area2D（Obstacles 下可能有 Zone 容器，至少应有 Area2D 障碍物实例）
func test_obstacles_are_areas():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	assert_not_null(obstacles, "Obstacles 节点应存在")
	var area_count := 0
	for child in obstacles.get_children():
		if child is Area2D:
			area_count += 1
	assert_true(area_count > 0, "应至少有一个 Area2D 障碍物实例")
	
	print("✓ Area2D 障碍物数量: ", area_count)
	
	main.free()

# 测试障碍物碰撞信号连接（取一个 Area2D 障碍物实例）
func test_obstacle_collision_signal():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	assert_not_null(obstacles, "Obstacles 节点应存在")
	var obstacle: Node = null
	for child in obstacles.get_children():
		if child is Area2D:
			obstacle = child
			break
	if obstacle:
		assert_true(obstacle.has_signal("body_entered"), "障碍物应有 body_entered 信号")
		print("✓ 障碍物碰撞信号正常")
	else:
		fail_test("未找到 Area2D 障碍物")
	
	main.free()

# 测试 GameManager add_score 方法 (add_score 增加 round_score，且仅当 status == playing)
func test_game_manager_add_score():
	var gm = get_node("/root/GameManager")
	gm.status = "playing"
	gm.round_score = 0
	
	gm.add_score(5000)
	
	assert_eq(gm.round_score, 5000, "round_score 应增加 5000")
	print("✓ GameManager.add_score() 工作正常")
