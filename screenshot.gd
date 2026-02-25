extends SceneTree

func _initialize():
	print("=== Screenshot Test Starting ===")
	
	# Wait for everything to load
	await create_timer(2.0).timeout
	
	# Get the main scene
	print("Loading Main.tscn...")
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	print("Main scene added to tree")
	
	# Wait for physics
	await create_timer(2.0).timeout
	
	# Get viewport and capture
	var viewport = get_root().get_viewport()
	print("Viewport size: ", viewport.size)
	
	var image = viewport.get_texture().get_image()
	if image:
		var path = "res://screenshots/main_screen.png"
		image.save_png(path)
		print("Screenshot saved to: ", path)
	else:
		print("ERROR: Failed to get image from viewport")
	
	# Also try direct file capture
	var img = Image.create(viewport.size.x, viewport.size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 1, 1))  # Blue test
	img.save_png("res://screenshots/test_blue.png")
	print("Test blue image saved")
	
	await create_timer(0.5).timeout
	print("=== Screenshot Test Done ===")
	quit()
