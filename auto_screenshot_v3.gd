extends SceneTree

# 修复后的自动化截图脚本
# 流程: MainMenu → Select Character → HowToPlay → Main Game → Launch → Screenshot
# 修复: 确保 MainMenu 被正确替换

func _initialize():
	print("=== Auto Screenshot Starting (Fixed v3) ===")
	
	# 确保截图目录存在
	var screenshot_dir = "res://screenshots/"
	var dir = DirAccess.open("res://")
	if dir:
		if not dir.dir_exists("screenshots"):
			dir.make_dir("screenshots")
	
	# 1. 加载 MainMenu 场景
	print("Step 1: Loading MainMenu.tscn...")
	change_scene_to_file("res://scenes/MainMenu.tscn")
	
	# 等待菜单加载
	await scene_changed
	await create_timer(1.0).timeout
	print("MainMenu loaded, capturing...")
	capture_state(screenshot_dir, "01_main_menu")
	
	# 2. 点击 Play 按钮
	print("Step 2: Clicking Play...")
	var play_btn = get_node_or_null("/root/MainMenu/PlayPanel/VBox/PlayButton")
	if play_btn:
		play_btn.pressed.emit()
	
	await create_timer(0.5).timeout
	print("Character panel shown, capturing...")
	capture_state(screenshot_dir, "02_select_character")
	
	# 3. 选择角色 (Character2 = Dino)
	print("Step 3: Selecting Dino...")
	var char_btn = get_node_or_null("/root/MainMenu/CharacterPanel/VBox/HBox/Character2")
	if char_btn:
		char_btn.pressed.emit()
	
	await create_timer(0.5).timeout
	print("How to play shown, capturing...")
	capture_state(screenshot_dir, "03_how_to_play")
	
	# 4. 点击 Start Game
	print("Step 4: Starting game...")
	var start_btn = get_node_or_null("/root/MainMenu/HowToPlayPanel/VBox/DoneButton")
	if start_btn:
		start_btn.pressed.emit()
	
	# 等待 Main 场景加载 (使用 scene_changed 信号)
	await scene_changed
	await create_timer(2.0).timeout  # 额外等待确保完全加载
	print("Game started, capturing...")
	capture_state(screenshot_dir, "04_game_initial")
	
	# 5. 模拟发射
	print("Step 5: Launching ball...")
	var event = InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	Input.parse_input_event(event)
	await create_timer(0.3).timeout
	event = InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = false
	Input.parse_input_event(event)
	
	await create_timer(0.5).timeout
	print("Ball launched, capturing...")
	capture_state(screenshot_dir, "05_ball_launched")
	
	print("=== Done ===")
	quit()

func capture_state(dir_path: String, state_name: String):
	var viewport = get_root().get_viewport()
	if not viewport:
		print("ERROR: No viewport")
		return
	
	await create_timer(0.3).timeout  # 等待渲染
	
	var tex = viewport.get_texture()
	if not tex:
		print("ERROR: No texture for " + state_name)
		return
	
	var image = tex.get_image()
	if not image or image.get_width() == 0:
		print("ERROR: Empty image for " + state_name)
		return
	
	var full_path = dir_path + state_name + ".png"
	var err = image.save_png(full_path)
	if err == OK:
		print("SUCCESS: Saved " + full_path + " (" + str(image.get_width()) + "x" + str(image.get_height()) + ")")
	else:
		print("ERROR: Failed to save " + full_path + " (error: " + str(err) + ")")
