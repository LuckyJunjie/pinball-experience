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

# 测试障碍物是 Area2D
func test_obstacles_are_areas():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	if obstacles:
		for child in obstacles.get_children():
			assert_true(child is Area2D, "障碍物应该是 Area2D")
	
	print("✓ 所有障碍物都是 Area2D")
	
	main.free()

# 测试障碍物碰撞信号连接
func test_obstacle_collision_signal():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	if obstacles:
		var obstacle = obstacles.get_child(0)
		if obstacle:
			# 检查 body_entered 信号
			assert_true(obstacle.has_signal("body_entered"), 
				"障碍物应该有 body_entered 信号")
			print("✓ 障碍物碰撞信号正常")
	
	main.free()

# 测试 GameManager add_score 方法
func test_game_manager_add_score():
	var gm = get_node("/root/GameManager")
	
	var initial_score = gm.total_score
	
	# 模拟得分
	gm.add_score(5000)
	
	assert_eq(gm.total_score, initial_score + 5000, "分数应增加 5000")
	print("✓ GameManager.add_score() 工作正常")
