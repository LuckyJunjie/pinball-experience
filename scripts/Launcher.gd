extends Node2D
## Launcher - receives ball from GameManager via set_ball(); player presses Space/Down to launch.
## Charge: hold to charge, release to launch (like original pin-ball).
## Communicates with Ball via launch_requested signal (ball connects in set_ball).

signal ball_launched(force: Vector2)  ## Emitted after launch (for SkillShot, etc.)
signal launch_requested(force: Vector2)  ## Emitted to tell ball to launch (ball connects to this)

@onready var spawn_point: Node2D = $SpawnPoint
@onready var plunger_visual: Sprite2D = $PlungerVisual

@export var base_launch_force: Vector2 = Vector2(0, -400)
@export var max_launch_force: Vector2 = Vector2(0, -800)
@export var charge_rate: float = 2.0
@export var max_charge: float = 1.0
@export var horizontal_launch_angle: float = 0.0  # 0 = straight up; positive = launch left toward playfield (launcher on right at x=700)
## Small offset to avoid ball overlapping launcher/plunger when spawned (prevents physics push on unfreeze)
@export var spawn_offset: Vector2 = Vector2(-8, 0)  # Left of spawn point (launcher on right)

const DEBUG_LAUNCH := true  ## Set true to trace spawn position and launch force

var current_ball: RigidBody2D = null
var _launch_callable: Callable  ## Ball.launch_ball connected to launch_requested
var current_charge: float = 0.0
var is_charging: bool = false
var plunger_rest_position: Vector2 = Vector2(0, 0)
var plunger_max_pull: Vector2 = Vector2(0, 25)

const PLUNGER_SHEET_PATH := "res://assets/sprites/plunger/plunger.png"
const PLUNGER_FRAME_COUNT := 20

func _ready() -> void:
	_setup_plunger_visual()

func _setup_plunger_visual() -> void:
	if not plunger_visual:
		return
	var sheet := load(PLUNGER_SHEET_PATH) as Texture2D
	if sheet == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	var fw := sheet.get_width() / PLUNGER_FRAME_COUNT
	atlas.region = Rect2i(0, 0, fw, sheet.get_height())
	plunger_visual.texture = atlas

func _physics_process(delta: float) -> void:
	var has_valid_ball = current_ball != null and is_instance_valid(current_ball)
	var launch_pressed = Input.is_action_pressed("launch_ball")
	var launch_just_released = Input.is_action_just_released("launch_ball")

	if launch_pressed and has_valid_ball:
		if not is_charging:
			is_charging = true
			current_charge = 0.0
		current_charge = minf(current_charge + charge_rate * delta, max_charge)
		_update_plunger_visual()
	else:
		if has_valid_ball and (is_charging or launch_just_released):
			if current_charge <= 0.0:
				current_charge = 0.2
			launch_ball()
		is_charging = false
		current_charge = 0.0
		_update_plunger_visual()

func get_spawn_position() -> Vector2:
	if spawn_point:
		return spawn_point.global_position
	return global_position

## Called by GameManager when a new ball is spawned at the launcher.
func set_ball(ball: RigidBody2D) -> void:
	_disconnect_launch()
	current_ball = ball
	if ball:
		var pos = get_spawn_position() + spawn_offset
		if DEBUG_LAUNCH:
			print("Spawn point: ", pos, " (offset: ", spawn_offset, ")")
		ball.visible = true
		ball.global_position = pos
		ball.freeze = true
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0
		if ball.get("initial_position") != null:
			ball.initial_position = pos
		if ball.has_method("reset_ball"):
			ball.reset_ball()
		## Ball receives launch via signal - decouples Launcher from Ball
		if ball.has_method("launch_ball"):
			_launch_callable = ball.launch_ball
			launch_requested.connect(_launch_callable)
		if SoundManager:
			SoundManager.play_sound("ball_launch")

func _update_plunger_visual() -> void:
	if plunger_visual and is_charging:
		var pull = plunger_max_pull * current_charge
		plunger_visual.position = plunger_rest_position + pull
	elif plunger_visual:
		plunger_visual.position = plunger_rest_position

func launch_ball() -> void:
	if not current_ball or not is_instance_valid(current_ball):
		return
	var ball_to_launch = current_ball
	current_ball = null
	# Use sin/cos: positive angle = left (launcher on right at x=700), negative = right
	var force_range = max_launch_force - base_launch_force
	var force_magnitude = absf(base_launch_force.y) + absf(force_range.y) * current_charge
	var angle_rad = deg_to_rad(horizontal_launch_angle)
	var launch_force = Vector2(-sin(angle_rad), -cos(angle_rad)) * force_magnitude
	if DEBUG_LAUNCH:
		print("[Pinball][Launcher] launch params: base=", base_launch_force, " max=", max_launch_force, " charge=", current_charge, " magnitude=", force_magnitude, " angle_deg=", horizontal_launch_angle)
		print("[Pinball][Launcher] launch_force=", launch_force, " (x>0=RIGHT, y<0=UP) len=", launch_force.length())
	ball_to_launch.visible = true
	## Tell ball to launch via signal (ball connected in set_ball)
	var had_signal_connection := _launch_callable.is_valid() and launch_requested.is_connected(_launch_callable)
	launch_requested.emit(launch_force)
	_disconnect_launch()
	## Fallback if ball doesn't support launch_ball (e.g. generic RigidBody2D)
	if ball_to_launch.freeze and not had_signal_connection:
		ball_to_launch.freeze = false
		ball_to_launch.apply_central_impulse(launch_force)
	ball_launched.emit(launch_force)
	current_charge = 0.0
	is_charging = false
	_activate_skill_shot()

func _disconnect_launch() -> void:
	if _launch_callable.is_valid() and launch_requested.is_connected(_launch_callable):
		launch_requested.disconnect(_launch_callable)
	_launch_callable = Callable()

func _activate_skill_shot() -> void:
	var skill_shot = get_tree().get_first_node_in_group("skill_shot")
	if skill_shot and skill_shot.has_method("activate"):
		skill_shot.activate()

func has_ball() -> bool:
	return current_ball != null and is_instance_valid(current_ball)
