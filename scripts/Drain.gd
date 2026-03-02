extends Area2D
## Drain - removes ball on contact. When no balls remain, triggers round_lost.

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.queue_free()
		SoundManager.play_sound("ball_lost")
		# 截图：球掉落drain
		_capture_drain_screenshot()
		await get_tree().process_frame
		GameManager.on_ball_removed()

func _capture_drain_screenshot() -> void:
	# 尝试获取ScreenshotManager节点
	var main = get_tree().current_scene
	if main and main.has_node("ScreenshotManager"):
		main.get_node("ScreenshotManager").capture_on_event(3) # BALL_DRAIN
