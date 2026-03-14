extends Area2D
## Drain: on ball contact return ball to pool (or queue_free); if no balls left call GameManager.on_round_lost().
## Only removes ball when it is actually at the bottom (Y threshold) and not just launched (grace period).

const DEBUG_LOGS := true
## Minimum Y position for ball to be considered "in drain" - only remove when ball is actually in drain area.
## Drain shape covers y=560-600; use 560 to avoid spawn/launch overlap (spawn ~y=475).
const DRAIN_Y_THRESHOLD := 560.0
## Grace period (seconds) after launch - ignore drain trigger to avoid instant removal on weak launch
const LAUNCH_GRACE_PERIOD := 0.5
## Deferred check: wait one frame then re-verify ball is still in drain before removing (avoids physics overlap false triggers)
const USE_DEFERRED_CHECK := true

func _ready() -> void:
	collision_layer = 4
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = false

func _on_body_entered(body: Node2D) -> void:
	if DEBUG_LOGS:
		print("[Pinball][Drain] body_entered raw: ", body.name, " pos=", body.global_position if "global_position" in body else "?")
	if not (body is RigidBody2D and body.is_in_group("balls")):
		return
	# Only remove when ball is actually at the bottom (avoids spawn-point overlap false triggers)
	if body.global_position.y < DRAIN_Y_THRESHOLD:
		if DEBUG_LOGS:
			print("[Pinball][Drain] ignored - ball y=%.1f above threshold %.1f" % [body.global_position.y, DRAIN_Y_THRESHOLD])
		return
	# Grace period after launch - avoid instant removal if ball barely moved
	var launch_time_val = body.get("launch_time")
	if launch_time_val != null and launch_time_val >= 0.0:
		var elapsed = Time.get_ticks_msec() / 1000.0 - launch_time_val
		if elapsed < LAUNCH_GRACE_PERIOD:
			if DEBUG_LOGS:
				print("[Pinball][Drain] ignored - ball just launched %.2fs ago (grace)" % elapsed)
			return
	if USE_DEFERRED_CHECK:
		await get_tree().process_frame
		if not is_instance_valid(body):
			return
		if body.global_position.y < DRAIN_Y_THRESHOLD:
			if DEBUG_LOGS:
				print("[Pinball][Drain] deferred check: ball moved above threshold, skip remove")
			return
	if DEBUG_LOGS:
		print("[Pinball][Drain] removing ball pos=%s" % body.global_position)
	var gm = get_node_or_null("/root/GameManager")
	var ball_pool = get_node_or_null("/root/BallPool")
	if ball_pool and ball_pool.has_method("return_ball") and ball_pool.is_initialized():
		ball_pool.return_ball(body)
	else:
		body.queue_free()
	if SoundManager:
		SoundManager.play_sound("ball_lost")
	await get_tree().process_frame
	if gm and gm.has_method("get_ball_count") and gm.get_ball_count() == 0:
		if gm.has_method("on_round_lost"):
			gm.on_round_lost()
		if DEBUG_LOGS:
			print("[Pinball][Drain] no balls left -> on_round_lost")
