extends SceneTree

func _init():
	print("=== Screenshot Test ===")
	
	# Load main scene
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# Wait for load
	await create_timer(2.0).timeout
	
	# Capture viewport
	var vp = get_viewport()
	var img = vp.get_texture().get_image()
	
	# Save to project folder
	var path = "res://test_screenshot.png"
	img.save_png(path)
	print("Screenshot saved to: ", path)
	
	await create_timer(0.5).timeout
	quit()
