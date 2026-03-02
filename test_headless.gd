extends SceneTree

func _init():
	print("=== Headless Screenshot Test ===")
	
	# Load main scene
	var main = load("res://scenes/Main.tscn").instantiate()
	root.add_child(main)
	
	# Wait for load
	await create_timer(3.0).timeout
	
	# Try to capture - may not work in headless
	print("Attempting screenshot...")
	
	# Quit after test
	await create_timer(1.0).timeout
	quit()
