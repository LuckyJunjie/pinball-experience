extends SceneTree

func _init():
	print("=== Screenshot Test ===")
	
	# Wait for load
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	
	# Load scene
	var main = load("res://scenes/Main.tscn").instantiate()
	add_child(main)
	
	await get_tree().process_frame
	await get_tree().create_timer(2.0).timeout
	
	# Get viewport
	var vp = get_viewport()
	var tex = vp.get_texture()
	var img = tex.get_image()
	
	# Save
	img.save_png("user://screenshot.png")
	print("Saved to user://screenshot.png")
	
	await get_tree().create_timer(0.5).timeout
	quit()
