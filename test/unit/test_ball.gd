# Unit Tests - Ball
extends GutTest

var ball: RigidBody2D = null
var ball_scene: PackedScene

func before_all():
	ball_scene = load("res://scenes/Ball.tscn") as PackedScene
	assert_not_null(ball_scene, "Ball scene should load")

func before_each():
	ball = ball_scene.instantiate() as RigidBody2D
	add_child_autofree(ball)
	await get_tree().process_frame

# ============ Constants ============

func test_ball_constants():
	assert_eq(ball.BALL_LAYER, 1, "BALL_LAYER should be 1")
	assert_eq(ball.BALL_MASK, 14, "BALL_MASK should be 14")
	assert_almost_eq(ball.BALL_RADIUS, 16.0 / 3.0, 0.001, "BALL_RADIUS should be 16/3")

# ============ reset_ball ============

func test_reset_ball_clears_velocity():
	ball.linear_velocity = Vector2(100, 200)
	ball.angular_velocity = 1.5
	ball.reset_ball()
	assert_eq(ball.linear_velocity, Vector2.ZERO, "linear_velocity should be zero")
	assert_eq(ball.angular_velocity, 0.0, "angular_velocity should be zero")

func test_reset_ball_clears_launch_time():
	ball.launch_time = 123.45
	ball.reset_ball()
	assert_eq(ball.launch_time, -1.0, "launch_time should be -1")

# ============ launch_ball ============

func test_launch_ball_sets_visible():
	ball.visible = false
	ball.launch_ball(Vector2(0, -500))
	assert_true(ball.visible, "Ball should be visible after launch")

func test_launch_ball_unfreezes():
	ball.freeze = true
	ball.launch_ball(Vector2(0, -500))
	assert_false(ball.freeze, "Ball should be unfrozen after launch")

func test_launch_ball_sets_launch_time():
	ball.launch_ball(Vector2(0, -500))
	assert_gt(ball.launch_time, 0.0, "launch_time should be set")

func test_launch_ball_disables_collision_during_launch():
	ball.launch_ball(Vector2(0, -500))
	assert_eq(ball.collision_layer, 0, "collision_layer should be 0 during launch")
	assert_eq(ball.collision_mask, 0, "collision_mask should be 0 during launch")

func test_launch_ball_applies_force():
	ball.launch_ball(Vector2(0, -500))
	# _launch_velocity = force / mass
	var expected_vel_y = -500.0 / ball.mass
	assert_almost_eq(ball._launch_velocity.y, expected_vel_y, 1.0, "launch velocity should match force/mass")

# ============ Script load ============

func test_ball_script_loads():
	var script = load("res://scripts/Ball.gd")
	assert_not_null(script, "Ball.gd should load")
	assert_true(script is GDScript, "Ball should be GDScript")
