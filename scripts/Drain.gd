extends Area2D
## Drain - removes ball on contact. When no balls remain, triggers round_lost.

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		body.queue_free()
		if SoundManager:
			SoundManager.play_sound("ball_lost")
		await get_tree().process_frame
		GameManager.on_ball_removed()
