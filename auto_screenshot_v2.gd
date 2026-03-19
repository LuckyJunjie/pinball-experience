extends SceneTree

# 修复后的自动化截图脚本 - 保存到项目目录
# 流程: MainMenu → Select Character → HowToPlay → Main Game → Launch → Screenshot

func _initialize():
	print("=== Auto Screenshot Starting (Fixed v2) ===")
	
	# 确保截图目录存在
	var screenshot_dir = "res://screenshots/"
	var dir = DirAccess.open("res://")
	if dir:
		if not dir.dir_exists("screenshots"):
			dir.make_dir("screenshots")
	
	# 1. 加载 MainMenu 场景
	print("Step 1: Loading MainMenu.tscn...")
	var menu = load("res://scenes/MainMenu.tscn").instantiate()
	root.add_child(menu)
	
	# 等待菜单完全加载
	await create_timer(1.0).timeout
	print("MainMenu loaded, capturing...")
	capture_state(screenshot_dir, "01_main_menu")
	
	# 2. 点击 Play 按钮
	print("Step 2: Clicking Play...")
	var play_btn = menu.get_node("PlayPanel/VBox/PlayButton")
	if play_btn:
		play_btn.pressed.emit()
	
	await create_timer(0.5).timeout
	print("Character panel shown, capturing...")
	capture_state(screenshot_dir, "02_select_character")
	
	# 3. 选择角色 (Character2 = Dino)
	print("Step 3: Selecting Dino...")
	var char_btn = menu.get_node("CharacterPanel/VBox/HBox/Character2")
	if char_btn:
		char_btn.pressed.emit()
	
	await create_timer(0.5).timeout
	print("How to play shown, capturing...")
	capture_state(screenshot_dir, "03_how_to_play")
	
	# 4. 点击 Start Game
	print("Step 4: Starting game...")
	var start_btn = menu.get_node("HowToPlayPanel/VBox/DoneButton")
	if start_btn:
		start_btn.pressed.emit()
	
	# 等待 Main 场景加载
	await create_timer(2.0).timeout
	print("Game started, capturing...")
	capture_state(screenshot_dir, "04_game_initial")
	
	# 5. 模拟空格键发射
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
	
	# 6. 等待球运动
	await create_timer(1.5).timeout
	print("Ball moving, capturing...")
	capture_state(screenshot_dir, "06_ball_moving")
	
	print("=== Done ===")
	quit()

func capture_state(dir_path: String, state_name: String):
	var viewport = get_root().get_viewport()
	if not viewport:
		print("ERROR: No viewport")
		return
	
	# 等待一帧确保渲染完成
	await create_timer(0.2).timeout
	
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
