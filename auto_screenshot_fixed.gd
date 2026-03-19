extends SceneTree

# 修复后的自动化截图脚本
# 严格按照游戏流程: MainMenu → Select Character → HowToPlay → Main Game → Launch → Screenshot

func _initialize():
	print("=== Auto Screenshot Starting (Fixed) ===")
	
	# 1. 加载 MainMenu 场景
	print("Step 1: Loading MainMenu.tscn...")
	var menu = load("res://scenes/MainMenu.tscn").instantiate()
	root.add_child(menu)
	
	# 等待菜单加载
	await create_timer(1.0).timeout
	print("MainMenu loaded, capturing screenshot...")
	capture_state("01_main_menu")
	
	# 2. 点击 "Play" 按钮 (通过调用内部方法或模拟信号)
	print("Step 2: Clicking Play button...")
	if menu.has_method("_on_play_pressed"):
		menu._on_play_pressed()
	else:
		# 手动切换状态
		menu.flow_state = 1  # SELECT_CHARACTER
		menu._show_state(1)
	
	await create_timer(0.5).timeout
	print("Character selection shown, capturing screenshot...")
	capture_state("02_select_character")
	
	# 3. 选择角色 (点击 Character1 = Sparky)
	print("Step 3: Selecting character 'Dino'...")
	if menu.has_method("_on_character_pressed"):
		menu._on_character_pressed("Dino")
	else:
		# 手动切换状态
		menu.flow_state = 2  # HOW_TO_PLAY
		menu._show_state(2)
	
	await create_timer(0.5).timeout
	print("How to play shown, capturing screenshot...")
	capture_state("03_how_to_play")
	
	# 4. 点击 "Start Game" 开始游戏
	print("Step 4: Starting game...")
	if menu.has_method("_on_how_to_play_done"):
		menu._on_how_to_play_done()
	
	# 等待 Main 场景加载
	await create_timer(1.0).timeout
	print("Main game loaded, capturing screenshot...")
	capture_state("04_game_initial")
	
	# 5. 模拟发射球
	print("Step 5: Launching ball...")
	simulate_launch()
	
	await create_timer(0.5).timeout
	print("Ball launched, capturing screenshot...")
	capture_state("05_ball_launched")
	
	# 6. 等待球运动
	await create_timer(1.0).timeout
	print("Ball moving, capturing screenshot...")
	capture_state("06_ball_moving")
	
	# 7. 等待球掉落
	await create_timer(2.0).timeout
	print("Ball drain, capturing screenshot...")
	capture_state("07_ball_drain")
	
	print("=== All screenshots captured ===")
	quit()

func simulate_launch():
	# 找到 Launcher 节点并发射球
	var launcher = root.find_child("Launcher", true, false)
	if launcher:
		# 尝试调用发射方法
		if launcher.has_method("_launch_ball"):
			launcher._launch_ball()
			print("Ball launched via _launch_ball()")
		elif launcher.has_method("launch"):
			launcher.launch()
			print("Ball launched via launch()")
	else:
		# 尝试通过 Input 模拟空格键
		print("Launcher not found, trying input simulation...")
		# 发送自定义输入事件模拟空格键
		var event = InputEventKey.new()
		event.keycode = KEY_SPACE
		event.pressed = true
		Input.parse_input_event(event)

func capture_state(state_name: String):
	var viewport = get_root().get_viewport()
	if not viewport:
		print("ERROR: No viewport for " + state_name)
		return
	
	var image = viewport.get_texture().get_image()
	if not image or image.get_width() == 0:
		print("WARNING: Viewport not rendered for " + state_name)
		# 尝试等待更长时间
		await create_timer(1.0).timeout
		image = viewport.get_texture().get_image()
	
	if image and image.get_width() > 0:
		var path = "user://screenshots/" + state_name + ".png"
		image.save_png(path)
		print("Saved: " + path + " (" + str(image.get_width()) + "x" + str(image.get_height()) + ")")
	else:
		print("ERROR: Could not capture " + state_name)
