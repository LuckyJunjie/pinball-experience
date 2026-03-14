extends RigidBody2D
## Ball - physics body for pinball. Spawned at launcher; Launcher/GameManager call set_ball and launch_ball(force).
## Handles collision (flipper boost), CCD; emits ball_lost when removed (e.g. by Drain).
## Launch logic matches original pin-ball: freeze=false, linear_velocity=0, apply_central_impulse(force).

signal ball_lost

const BALL_LAYER := 1
const DEBUG_BALL_TRACE := true  ## Set true to trace ball pos/vel and removal stack
const BALL_MASK := 14  # 2+4+8: flippers, walls, obstacles

@export var initial_position: Vector2 = Vector2(400, 500)
@export var boundary_left: float = 20.0
@export var boundary_right: float = 780.0
@export var boundary_top: float = 20.0
@export var boundary_bottom: float = 600.0  ## Cap Y to prevent runaway fall; drain handles removal

const BALL_RADIUS := 16.0

var _has_emitted_lost: bool = false
## Time when ball was launched (seconds since engine start); used by Drain for grace period
var launch_time: float = -1.0
var _trace_frame_count: int = 0

func _ready() -> void:
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
	shape.radius = 16.0
	if $CollisionShape2D:
		$CollisionShape2D.shape = shape

func _physics_process(_delta: float) -> void:
	if freeze:
		return
	if DEBUG_BALL_TRACE:
		_trace_frame_count += 1
		if _trace_frame_count <= 5 or _trace_frame_count % 12 == 0:
			print("[Pinball][Ball] pos=", global_position, " vel=", linear_velocity, " mass=", mass, " freeze=", freeze)
	# Keep ball within playfield (safety; drain handles bottom)
	var clamped_x := clampf(global_position.x, boundary_left, boundary_right)
	var clamped_y := global_position.y
	# Top: place ball center below wall - avoid overlap (wall y=0..20, ball radius 16)
	var top_min := boundary_top + BALL_RADIUS
	if global_position.y < top_min:
		clamped_y = top_min
	# Bottom: cap Y to prevent runaway fall; drain handles removal
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
			# Zero downward velocity when capping at bottom to prevent runaway
			linear_velocity.y = minf(linear_velocity.y, 0.0)

func _on_body_entered(body: Node2D) -> void:
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

func launch_ball(force: Vector2 = Vector2(0, -500)) -> void:
	visible = true
	freeze = false
	sleeping = false
	linear_velocity = force / mass
	launch_time = Time.get_ticks_msec() / 1000.0
	_trace_frame_count = 0
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] launch_ball force=", force, " vel=", linear_velocity, " pos=", global_position, " (y<0=UP)")

func _exit_tree() -> void:
	if DEBUG_BALL_TRACE:
		print("[Pinball][Ball] removed at ", global_position, " Stack:")
		print(get_stack())
	if not _has_emitted_lost:
		_has_emitted_lost = true
		print("[Pinball][Ball] ball_lost emitted, launch_time=", launch_time, " vel=", linear_velocity)
		ball_lost.emit()
