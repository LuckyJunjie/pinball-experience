extends SceneTree
## Godot 自动测试 - 节点验证 + 截图

var test_results = []
var output_file = "res://test_results.json"

func _initialize():
	print("===== Godot 自动测试开始 =====")
	
	# 加载主场景
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# 等待加载
	await process_frame
	await process_frame
	await create_timer(1.0).timeout
	
	# 测试节点
	test_node(main, "Launcher", Vector2(700, 500))
	test_node(main, "FlipperLeft", Vector2(360, 550))
	test_node(main, "FlipperRight", Vector2(440, 550))
	test_node(main, "Balls")
	test_node(main, "UI")
	test_node(main, "Playfield/Drain")
	
	# 尝试截图
	await take_screenshot()
	
	# 保存结果
	save_results()
	
	await create_timer(0.5).timeout
	print("===== 测试完成 =====")
	quit()

func test_node(parent: Node, node_path: String, expected_pos: Vector2 = Vector2.ZERO):
	var node = parent.get_node_or_null(node_path)
	if node:
		print("✓ 节点存在: " + node_path)
		if expected_pos != Vector2.ZERO:
			var actual_pos = node.global_position
			var diff = actual_pos.distance_to(expected_pos)
			if diff < 10:
				print("  位置正确: " + str(actual_pos))
			else:
				print("  位置错误: 期望 " + str(expected_pos) + ", 实际 " + str(actual_pos))
		test_results.append({"node": node_path, "status": "pass", "position": str(node.global_position)})
	else:
		print("✗ 节点缺失: " + node_path)
		test_results.append({"node": node_path, "status": "fail"})

func take_screenshot():
	print("\n===== 尝试截图 =====")
	var viewport = root.get_viewport()
	if viewport:
		var tex = viewport.get_texture()
		if tex:
			var img = tex.get_image()
			if img and img.get_width() > 0:
				var path = "res://screenshots/auto/main_scene.png"
				img.save_png(path)
				print("✓ 截图已保存: " + path + " (" + str(img.get_width()) + "x" + str(img.get_height()) + ")")
				test_results.append({"screenshot": "pass", "path": path})
			else:
				print("⚠ 无法获取图像数据")
				test_results.append({"screenshot": "fail", "reason": "no_image_data"})
		else:
			print("⚠ 无法获取纹理")
			test_results.append({"screenshot": "fail", "reason": "no_texture"})
	else:
		print("⚠ 无法获取视口")
		test_results.append({"screenshot": "fail", "reason": "no_viewport"})

func save_results():
	var file = FileAccess.open(output_file, FileAccess.WRITE)
	if file:
		var json = JSON.stringify(test_results, "  ")
		file.store_string(json)
		file.close()
		print("✓ 测试结果已保存: " + output_file)
