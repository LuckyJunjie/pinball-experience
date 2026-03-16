# Unit Tests - BallPool (uses autoload singleton)
extends GutTest

var ball_pool: Node = null
var ball_scene: PackedScene
var container: Node2D

func before_all():
	ball_scene = load("res://scenes/Ball.tscn") as PackedScene
	assert_not_null(ball_scene, "Ball scene should load")

func before_each():
	container = Node2D.new()
	add_child_autofree(container)
	ball_pool = BallPool.get_instance() if BallPool else get_node_or_null("/root/BallPool")
	assert_not_null(ball_pool, "BallPool autoload should exist")
	ball_pool.initialize(ball_scene, container, 3)
	await get_tree().process_frame

func after_each():
	# Return any active balls to pool
	while ball_pool.get_active_ball_count() > 0:
		var children = container.get_children()
		for c in children:
			if c is RigidBody2D and c.is_in_group("balls"):
				ball_pool.return_ball(c)
				break

# ============ initialize ============

func test_initialize_creates_pool():
	ball_pool.initialize(ball_scene, container, 3)
	assert_true(ball_pool.is_initialized(), "BallPool should be initialized")
	assert_eq(ball_pool.get_active_ball_count(), 0, "No balls active initially")

func test_initialize_respects_pool_size():
	ball_pool.initialize(ball_scene, container, 5)
	# Get 5 balls - all should come from pool without expansion
	for i in range(5):
		var b = ball_pool.get_ball()
		assert_not_null(b, "get_ball should return ball %d" % i)
		ball_pool.return_ball(b)
	assert_eq(ball_pool.get_active_ball_count(), 0, "All balls returned")

func test_get_ball_expands_pool_when_empty():
	ball_pool.initialize(ball_scene, container, 1)
	var b1 = ball_pool.get_ball()
	var b2 = ball_pool.get_ball()  # Should expand
	assert_not_null(b1, "First ball")
	assert_not_null(b2, "Second ball (pool should expand)")
	ball_pool.return_ball(b1)
	ball_pool.return_ball(b2)

func test_return_ball_decreases_active_count():
	ball_pool.initialize(ball_scene, container, 3)
	var b = ball_pool.get_ball()
	assert_eq(ball_pool.get_active_ball_count(), 1, "1 active after get_ball")
	ball_pool.return_ball(b)
	assert_eq(ball_pool.get_active_ball_count(), 0, "0 active after return")

func test_spawn_ball_at_position():
	ball_pool.initialize(ball_scene, container, 3)
	var pos = Vector2(400, 300)
	var ball = ball_pool.spawn_ball_at_position(pos)
	assert_not_null(ball, "spawn_ball_at_position should return ball")
	assert_eq(ball.global_position, pos, "Ball should be at spawn position")
	assert_true(ball.visible, "Ball should be visible")
	ball_pool.return_ball(ball)

func test_spawn_ball_with_impulse():
	ball_pool.initialize(ball_scene, container, 3)
	var ball = ball_pool.spawn_ball_at_position(Vector2(400, 300), Vector2(100, 0))
	assert_not_null(ball, "spawn with impulse")
	assert_false(ball.freeze, "Ball should be unfrozen when impulse given")
	ball_pool.return_ball(ball)

func test_is_initialized_true_after_init():
	assert_true(ball_pool.is_initialized(), "Should be initialized after init")
