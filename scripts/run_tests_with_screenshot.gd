extends SceneTree
## Captures a single screenshot using GDSnap-style viewport capture.
## Overwrites the latest screenshot only to avoid RAM waste (no accumulation).
##
## Run: godot -s scripts/run_tests_with_screenshot.gd
## Or use: ./run_all_tests.sh (runs unit tests + this)

const LATEST_SCREENSHOT_PATH := "user://screenshots/latest.png"
const SCENE_TO_CAPTURE := "res://scenes/Main.tscn"

func _initialize() -> void:
	print("=== Pinball Screenshot Capture (latest only) ===\n")
	await _capture_and_quit()

func _capture_and_quit() -> void:
	var main = load(SCENE_TO_CAPTURE).instantiate()
	root.add_child(main)

	await create_timer(1.5).timeout
	await RenderingServer.frame_post_draw

	var viewport = root.get_viewport()
	if viewport:
		var img: Image = viewport.get_texture().get_image()
		if img:
			_ensure_screenshots_dir()
			var err = img.save_png(LATEST_SCREENSHOT_PATH)
			if err == OK:
				print("Screenshot saved to %s (overwrites previous)" % LATEST_SCREENSHOT_PATH)
			else:
				push_error("Failed to save screenshot: %d" % err)
			img = null
		else:
			push_error("Failed to get viewport image")
	else:
		push_error("No viewport")

	main.queue_free()
	print("=== Done ===")
	quit()

func _ensure_screenshots_dir() -> void:
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("screenshots"):
		dir.make_dir("screenshots")
