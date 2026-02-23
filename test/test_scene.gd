extends SceneTree

func _initialize():
	print("[TEST] ====== Pinball Experience 测试 ======")
	
	# 加载主场景
	print("[TEST] 加载 Main 场景...")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	
	# 检查关键节点
	print("[TEST] 检查节点...")
	
	# 检查 GameManager
	var gm = Engine.get_singleton("GameManager")
	if gm:
		print("[TEST] ✓ GameManager 存在")
		print("[TEST]   - rounds: ", gm.rounds)
		print("[TEST]   - status: ", gm.status)
	else:
		print("[TEST] ✗ GameManager 不存在")
	
	# 检查发射器
	if main.has_node("Launcher"):
		print("[TEST] ✓ Launcher 存在")
	else:
		print("[TEST] ✗ Launcher 不存在")
	
	# 检查挡板
	if main.has_node("FlipperLeft"):
		print("[TEST] ✓ FlipperLeft 存在")
	else:
		print("[TEST] ✗ FlipperLeft 不存在")
	
	if main.has_node("FlipperRight"):
		print("[TEST] ✓ FlipperRight 存在")
	else:
		print("[TEST] ✗ FlipperRight 不存在")
	
	# 检查排水口
	if main.has_node("Playfield/Drain"):
		print("[TEST] ✓ Drain 存在")
	else:
		print("[TEST] ✗ Drain 不存在")
	
	# 检查障碍物
	if main.has_node("Obstacles"):
		var obstacles = main.get_node("Obstacles")
		print("[TEST] ✓ Obstacles 存在, 数量: ", obstacles.get_child_count())
	else:
		print("[TEST] ✗ Obstacles 不存在")
	
	# 检查 UI
	if main.has_node("UI/Control/HUD"):
		print("[TEST] ✓ UI HUD 存在")
	else:
		print("[TEST] ✗ UI HUD 不存在")
	
	if main.has_node("UI/Control/GameOverPanel"):
		print("[TEST] ✓ GameOverPanel 存在")
	else:
		print("[TEST] ✗ GameOverPanel 不存在")
	
	print("[TEST] ====== 测试完成 ======")
	quit()
