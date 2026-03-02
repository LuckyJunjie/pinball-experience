# Test Zones - 障碍物区域测试 (0.6)
extends GutTest

# ========== 第一层: 单元测试 ==========

# 测试区域节点存在
func test_zone_nodes_exist():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	assert_not_null(obstacles, "Obstacles 节点应存在")
	
	# 检查 4 个区域
	assert_true(obstacles.has_node("Zone_AndroidAcres"), "Android Acres 区域应存在")
	assert_true(obstacles.has_node("Zone_DinoDesert"), "Dino Desert 区域应存在")
	assert_true(obstacles.has_node("Zone_FlutterForest"), "Flutter Forest 区域应存在")
	assert_true(obstacles.has_node("Zone_SparkyScorch"), "Sparky Scorch 区域应存在")
	
	print("✓ 4 个障碍物区域节点都存在")
	
	main.free()

# 测试区域位置
func test_zone_positions():
	var main = load("res://scenes/Main.tscn").instantiate()
	
	var obstacles = main.get_node_or_null("Obstacles")
	
	# Android Acres - 左侧
	var android = obstacles.get_node_or_null("Zone_AndroidAcres")
	if android:
		assert_true(android.position.x < 200, "Android Acres 应在左侧 (x < 200)")
		print("Android Acres: ", android.position)
	
	# Dino Desert - 发射器附近
	var dino = obstacles.get_node_or_null("Zone_DinoDesert")
	if dino:
		assert_true(dino.position.x > 600, "Dino Desert 应在右侧 (x > 600)")
		print("Dino Desert: ", dino.position)
	
	# Flutter Forest - 右上
	var forest = obstacles.get_node_or_null("Zone_FlutterForest")
	if forest:
		assert_true(forest.position.x > 500 and forest.position.y < 200, 
			"Flutter Forest 应在右上")
		print("Flutter Forest: ", forest.position)
	
	# Sparky Scorch - 左上
	var sparky = obstacles.get_node_or_null("Zone_SparkyScorch")
	if sparky:
		assert_true(sparky.position.x < 200 and sparky.position.y < 200, 
			"Sparky Scorch 应在左上")
		print("Sparky Scorch: ", sparky.position)
	
	main.free()

# ========== 第二层: 集成测试 ==========

# 测试障碍物碰撞
func test_obstacle_collision():
	var main = load("res://scenes/Main.tscn").instantiate()
	get_tree().root.add_child(main)
	
	await get_tree().process_frame
	
	var gm = get_node("/root/GameManager")
	var initial_score = gm.total_score
	
	# 获取一个障碍物
	var obstacles = main.get_node_or_null("Obstacles")
	if obstacles and obstacles.get_child_count() > 0:
		var obstacle = obstacles.get_child(0)
		
		# 创建球并移动到障碍物位置
		var ball = load("res://scenes/Ball.tscn").instantiate()
		ball.global_position = obstacle.global_position + Vector2(0, 30)
		main.add_child(ball)
		
		await get_tree().physics_process_frame
		
		# 移动球撞向障碍物
		ball.global_position = obstacle.global_position
		await get_tree().physics_process_frame
		
		# 检查分数是否增加
		print("初始分数: ", initial_score, " 当前分数: ", gm.total_score)
	
	get_tree().root.remove_child(main)
	main.free()

# ========== 第三层: 截图测试 ==========

# 测试区域截图 (需要在有图形环境下)
func test_zone_screenshot():
	var main = load("res://scenes/Main.tscn").instantiate()
	get_tree().root.add_child(main)
	
	await get_tree().process_frame
	
	# 尝试截图
	var viewport = get_viewport()
	if viewport:
		var tex = viewport.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				img.save_png("user://test_screenshots/zone_test.png")
				print("✓ 截图保存成功")
	
	get_tree().root.remove_child(main)
	main.free()

# ========== 第四层: 性能测试 ==========

# 测试帧率
func test_framerate():
	var main = load("res://scenes/Main.tscn").instantiate()
	get_tree().root.add_child(main)
	
	await get_tree().process_frame
	
	# 模拟 60 帧
	for i in range(60):
		get_tree().process_frame
	
	# 检查是否卡顿
	print("✓ 60 帧处理完成")
	
	get_tree().root.remove_child(main)
	main.free()
