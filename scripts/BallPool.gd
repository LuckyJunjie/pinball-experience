extends Node
## Ball pooling for performance. Use as autoload "BallPool".

signal ball_activated(ball: RigidBody2D)
signal ball_deactivated(ball: RigidBody2D)
signal pool_expanded(new_size: int)

const DEFAULT_POOL_SIZE: int = 5
const EXPANSION_INCREMENT: int = 3
## Off-screen position so pool balls never overlap playfield; prevents overlap resolution on unfreeze
const POOL_STORAGE_POSITION := Vector2(-10000, -10000)

var _available_balls: Array[RigidBody2D] = []
var _active_balls: Array[RigidBody2D] = []
var _ball_scene: PackedScene = null
var _balls_container: Node2D = null
var _pool_size: int = DEFAULT_POOL_SIZE

static var _instance: Node = null
const DEBUG_LOGS := true

func _ready() -> void:
	add_to_group("ball_pool")
	if _instance == null:
		_instance = self
	else:
		queue_free()
		return

func initialize(ball_scene: PackedScene, container: Node2D, initial_pool_size: int = DEFAULT_POOL_SIZE) -> void:
	var container_valid = is_instance_valid(_balls_container) if _balls_container else false
	if _ball_scene != null and container_valid and _balls_container == container:
		return
	if _ball_scene != null:
		_available_balls.clear()
		_active_balls.clear()
	_ball_scene = ball_scene
	_balls_container = container
	_pool_size = initial_pool_size
	for i in range(_pool_size):
		_create_ball_instance()
	print("BallPool initialized with pool size: %d" % _pool_size)

func get_ball() -> RigidBody2D:
	if _available_balls.is_empty():
		_expand_pool()
		if _available_balls.is_empty():
			push_error("BallPool: Failed to get ball")
			return null
	var ball: RigidBody2D = _available_balls.pop_back()
	_active_balls.append(ball)
	ball.show()
	ball.visible = true
	# Keep frozen - caller sets position before unfreezing to avoid overlap resolution corrupting velocity
	if DEBUG_LOGS:
		print("[Pinball][BallPool] get_ball active_count=%d" % _active_balls.size())
	ball_activated.emit(ball)
	return ball

func return_ball(ball: RigidBody2D) -> void:
	if not ball:
		if DEBUG_LOGS:
			print("[Pinball][BallPool] return_ball called with null ball")
		return
	if _available_balls.has(ball):
		if DEBUG_LOGS:
			print("[Pinball][BallPool] return_ball ball already in available list")
		return
	if _active_balls.has(ball):
		_active_balls.erase(ball)
	_reset_ball_state(ball)
	ball.hide()
	ball.freeze = true
	_available_balls.append(ball)
	if DEBUG_LOGS:
		print("[Pinball][BallPool] return_ball pos=%s active_count=%d" % [ball.global_position, _active_balls.size()])
		print(get_stack())
	ball_deactivated.emit(ball)

func spawn_ball_at_position(position: Vector2, impulse: Vector2 = Vector2.ZERO, freeze: bool = false) -> RigidBody2D:
	var ball: RigidBody2D = get_ball()
	if not ball:
		return null
	ball.global_position = position
	ball.visible = true
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	if ball.get("initial_position") != null:
		ball.initial_position = position
	ball.freeze = freeze
	if impulse != Vector2.ZERO:
		ball.freeze = false
		ball.apply_central_impulse(impulse)
	if DEBUG_LOGS:
		print("[Pinball][BallPool] spawn_ball_at_position pos=%s freeze=%s visible=%s" % [position, freeze, ball.visible])
	return ball

func get_active_ball_count() -> int:
	return _active_balls.size()

func is_initialized() -> bool:
	return _ball_scene != null and _balls_container != null

func _create_ball_instance() -> RigidBody2D:
	if not _ball_scene or not _balls_container:
		return null
	var ball: RigidBody2D = _ball_scene.instantiate()
	_balls_container.add_child(ball)
	ball.global_position = POOL_STORAGE_POSITION
	ball.hide()
	ball.freeze = true
	if ball.has_signal("ball_lost"):
		ball.ball_lost.connect(_on_ball_lost.bind(ball))
	_available_balls.append(ball)
	return ball

func _expand_pool() -> void:
	for i in range(EXPANSION_INCREMENT):
		_create_ball_instance()
	_pool_size += EXPANSION_INCREMENT
	pool_expanded.emit(_pool_size)

func _reset_ball_state(ball: RigidBody2D) -> void:
	if ball.get_meta("is_launcher_spawn", false):
		ball.remove_meta("is_launcher_spawn")
	ball.global_position = POOL_STORAGE_POSITION
	ball.freeze = false
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.rotation = 0.0
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	elif ball.get("_has_emitted_lost") != null:
		ball._has_emitted_lost = false
	ball.freeze = true

func _on_ball_lost(ball: RigidBody2D) -> void:
	## ball_lost is emitted from Ball._exit_tree when ball is queue_free'd.
	## Do NOT call return_ball - the ball is being destroyed. Only update active count and trigger round_lost.
	if _active_balls.has(ball):
		_active_balls.erase(ball)
	if DEBUG_LOGS:
		print("[Pinball][BallPool] _on_ball_lost (ball freed) active_count=%d" % _active_balls.size())
	if get_active_ball_count() == 0:
		var gm = get_node_or_null("/root/GameManager")
		if gm and gm.has_method("on_round_lost") and gm.status == gm.Status.PLAYING:
			gm.on_round_lost()

static func get_instance() -> Node:
	return _instance
