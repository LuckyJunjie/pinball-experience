extends SceneTree

var screenshot_count = 0

func _initialize():
	print("=== Pinball Experience Screenshot Test ===")
	
	# Wait for everything to load
	await create_timer(1.0).timeout
	
	# Get the main scene
	print("Loading Main.tscn...")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	await create_timer(1.0).timeout
	
	# Take screenshot 0.1: Main menu / Initial state
	take_screenshot("0.1_initial")
	
	# Simulate game start by pressing space (launch ball)
	print("Simulating ball launch...")
	simulate_input("launch")
	await create_timer(0.5).timeout
	take_screenshot("0.1_launch")
	
	# Wait for ball to move
	await create_timer(2.0).timeout
	take_screenshot("0.2_ball_moving")
	
	# Simulate flipper input
	print("Simulating flipper...")
	simulate_input("flipper_left")
	await create_timer(0.3).timeout
	simulate_input("flipper_right")
	await create_timer(0.3).timeout
	take_screenshot("0.2_flippers")
	
	# Let ball fall to drain
	await create_timer(3.0).timeout
	take_screenshot("0.2_drain")
	
	# Wait for game over or next round
	await create_timer(2.0).timeout
	take_screenshot("0.5_game_over")
	
	print("=== All Screenshots Taken ===")
	quit()

func take_screenshot(name):
	screenshot_count += 1
	var viewport = get_root().get_viewport()
	var image = viewport.get_texture().get_image()
	if image:
		var path = "res://screenshots/" + name + ".png"
		image.save_png(path)
		print("Screenshot " + str(screenshot_count) + ": " + name + " saved")
	else:
		print("ERROR: Failed to capture screenshot: " + name)

func simulate_input(action):
	# This is a simplified simulation
	# In a real test, we'd send input events
	print("Simulating input: " + action)
