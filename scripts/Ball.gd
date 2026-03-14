extends RigidBody2D
## Ball - physics body for pinball. Spawned at launcher; Launcher connects to launch_requested and calls launch_ball(force) via signal.
## Handles collision (flipper boost), CCD; emits ball_lost when removed (e.g. by Drain).

signal ball_lost

const BALL_LAYER := 1
const DEBUG_BALL_TRACE := true
const BALL_MASK := 14  # 2+4+8: flippers, walls, obstacles

@export var initial_position: Vector2 = Vector2(400, 500)
@export var boundary_left: float = 20.0
@export var boundary_right: float = 780.0
@export var boundary_top: float = 20.0
@export var boundary_bottom: float = 600.0

const BALL_RADIUS := 16.0 / 3.0

var _has_emitted_lost: bool = false
var launch_time: float = -1.0
var _trace_frame_count: int = 0
var _pending_launch_force: Vector2 = Vector2.ZERO
var _apply_impulse_next_frame: bool = false
var _launch_position: Vector2 = Vector2.ZERO  ## Override position in _integrate_forces (Godot integrates before our callback)

func _ready() -> void:
	freeze = true  # Stay frozen until BallPool positions us
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] created at ", global_position)
	z_index = 5
	add_to_group("ball")
	add_to_group("balls")
	collision_layer = BALL_LAYER
	collision_mask = BALL_MASK
	mass = 0.4
	gravity_scale = 1.0
	linear_damp = 0.02
	angular_damp = 0.02
	continuous_cd = CCD_MODE_CAST_SHAPE
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)
	var physics_material := PhysicsMaterial.new()
	physics_material.bounce = 0.85
	physics_material.friction = 0.075
	physics_material_override = physics_material
	var shape := CircleShape2D.new()
	shape.radius = BALL_RADIUS
	if $CollisionShape2D:
		$CollisionShape2D.shape = shape

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	## OVERRIDE velocity and position - Godot integrates before calling us, so we receive corrupted state.
	## Setting both here overwrites overlap resolution / residual physics.
	if _pending_launch_force != Vector2.ZERO:
		var target_vel := _pending_launch_force / mass
		if DEBUG_BALL_TRACE:
			print("[Pinball][Ball] _integrate_forces OVERRIDE pos ", state.transform.origin, " -> ", _launch_position, " vel -> ", target_vel)
		state.transform.origin = _launch_position
		state.linear_velocity = target_vel
		state.angular_velocity = 0.0
		_pending_launch_force = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	## One frame after re-enable: _integrate_forces will override pos/vel using _launch_position + _pending_launch_force
	if _apply_impulse_next_frame:
		_apply_impulse_next_frame = false
		if DEBUG_BALL_TRACE:
			print("[Pinball][Ball] launch frame (override in _integrate_forces)")
	## Enable collision only when ball has moved UP (y<400) - avoids overlap at launcher
	if collision_layer == 0 and global_position.y < 400.0:
		if $CollisionShape2D:
			$CollisionShape2D.disabled = false
		collision_layer = BALL_LAYER
		collision_mask = BALL_MASK
	if freeze:
		return
	if DEBUG_BALL_TRACE:
		_trace_frame_count += 1
		if _trace_frame_count <= 5 or _trace_frame_count % 12 == 0:
			print("[Pinball][Ball] pos=", global_position, " vel=", linear_velocity, " mass=", mass, " freeze=", freeze)
	var top_min := boundary_top + BALL_RADIUS
	var clamped_x := clampf(global_position.x, boundary_left, boundary_right)
	var clamped_y := global_position.y
	if global_position.y < top_min:
		clamped_y = top_min
	if global_position.y > boundary_bottom:
		clamped_y = boundary_bottom
	if global_position.x != clamped_x or global_position.y != clamped_y:
		global_position = Vector2(clamped_x, clamped_y)
		if global_position.x <= boundary_left:
			apply_central_impulse(Vector2(50, 0))
		elif global_position.x >= boundary_right:
			apply_central_impulse(Vector2(-50, 0))
		if global_position.y <= top_min:
			apply_central_impulse(Vector2(0, 50))
		elif global_position.y >= boundary_bottom:
			linear_velocity.y = minf(linear_velocity.y, 0.0)

func _on_body_entered(body: Node2D) -> void:
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] _on_body_entered with ", body.name, " (", body.get_class(), ") at pos=", body.global_position)
	if body.has_method("get_flipper_side"):
		var side: String = body.get_flipper_side()
		var strength: float = body.flipper_strength if "flipper_strength" in body else 1500.0
		var impulse_dir := Vector2.UP.rotated(deg_to_rad(30)) if side == "left" else Vector2.UP.rotated(deg_to_rad(-30))
		apply_central_impulse(impulse_dir * strength * 0.5)

func reset_ball() -> void:
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	_has_emitted_lost = false
	launch_time = -1.0
	_pending_launch_force = Vector2.ZERO
	_apply_impulse_next_frame = false
	_launch_position = Vector2.ZERO

func _do_launch() -> void:
	if not is_instance_valid(self) or _pending_launch_force == Vector2.ZERO:
		return
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] _do_launch force=", _pending_launch_force, " pos=", global_position)
	## Disable collision until ball moves up - prevents overlap resolution from overwriting our velocity
	collision_layer = 0
	collision_mask = 0
	if $CollisionShape2D:
		$CollisionShape2D.disabled = true
	## Re-enable physics (ball was removed via process_mode DISABLED + disable_mode REMOVE)
	process_mode = Node.PROCESS_MODE_INHERIT
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
	sleeping = false
	## _integrate_forces will override pos/vel next frame
	_apply_impulse_next_frame = true

func launch_ball(force: Vector2 = Vector2(0, -500)) -> void:
	visible = true
	launch_time = Time.get_ticks_msec() / 1000.0
	_trace_frame_count = 0
	_pending_launch_force = force
	_launch_position = global_position  ## Capture BEFORE re-enable - physics will corrupt it
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] launch_ball force=", force, " pos=", global_position, " coll_layer=", collision_layer)
	## Defer unfreeze+impulse to next frame - physics server needs a frame to sync collision_layer=0
	call_deferred("_do_launch")

func _exit_tree() -> void:
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] removed at ", global_position, " Stack:")
		print(get_stack())
	if not _has_emitted_lost:
		_has_emitted_lost = true
		print("[Pinball][Ball] ball_lost emitted, launch_time=", launch_time, " vel=", linear_velocity)
		ball_lost.emit()
