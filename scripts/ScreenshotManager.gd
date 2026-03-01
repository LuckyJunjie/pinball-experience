extends Node
## ScreenshotManager - Captures game screenshots on events for CI/CD testing

signal screenshot_captured(event_id: int, filename: String)

const SCREENSHOT_DIR = "user://screenshots/"

# Event IDs
enum EventId {
	GAME_START = 1,
	BALL_SPAWN = 4,
	BALL_DRAIN = 3,
	ROUND_END = 11,
	GAME_OVER = 7,
	SCORE = 5,
	MULTIPLIER = 6,
	BONUS_ACTIVATED = 8,
	COMBO = 9,
	BONUS_BALL_SPAWN = 12,
}

var screenshot_counter: int = 0

func _ready() -> void:
	# Ensure screenshot directory exists
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir("screenshots")

func capture_on_event(event_id: int, data: String = "") -> void:
	# Skip if no display (headless server)
	if DisplayServer.get_name() == "headless":
		return
	
	# Skip if no viewport
	var viewport = get_viewport()
	if not viewport:
		return
	
	screenshot_counter += 1
	var timestamp = Time.get_unix_time_from_system()
	var filename = "event_%02d_%s_%d.png" % [event_id, data if data else "default", screenshot_counter]
	var filepath = SCREENSHOT_DIR + filename
	
	# Capture screenshot
	await viewport.get_texture().get_image().save_png(filepath)
	screenshot_captured.emit(event_id, filename)

func capture_current_screen() -> void:
	capture_on_event(0, "manual")
