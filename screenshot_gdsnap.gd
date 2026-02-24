# Screenshot Test using GDSnap
extends SceneTree

func _initialize():
	print("=== GDSnap Screenshot Test ===")
	
	# Wait for everything to load
	await create_timer(1.0).timeout
	
	# Load main scene
	print("Loading Main scene...")
	var main = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	
	await create_timer(1.0).timeout
	
	# Try using GDSnap to take screenshot
	# GDSnap should work in headless mode
	if has_node("/root/GDSnap"):
		var gdsnap = get_node("/root/GDSnap")
		print("GDSnap found!")
		
		# Try to take screenshot
		var viewport = get_viewport()
		var result = gdsnap.take_screenshot("main_screen", viewport)
		print("Screenshot result: ", result)
	else:
		print("GDSnap not found in scene tree")
		# Try global access
		if GDSnap:
			print("GDSnap is available as global")
			var viewport = get_viewport()
			GDSnap.take_screenshot("main_screen", viewport)
		else:
			print("GDSnap not available globally either")
	
	await create_timer(0.5).timeout
	print("=== Test Done ===")
	quit()
