extends Node2D
## Main - playfield. Wires GameManager (balls, launcher, ball scene), defers start_game.

var _camera: Camera2D = null

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm:
		return
	_camera = get_node_or_null("Camera2D")
	var balls_node = get_node_or_null("Balls")
	var launcher_node = get_node_or_null("Launcher")
	if balls_node:
		gm.balls_container = balls_node
	if launcher_node:
		gm.launcher_node = launcher_node
		gm.launcher_spawn_position = launcher_node.global_position + Vector2(0, -25)
		if launcher_node.has_method("get_spawn_position"):
			gm.launcher_spawn_position = launcher_node.get_spawn_position()
	var ball_scene = load("res://scenes/Ball.tscn") as PackedScene
	if ball_scene:
		gm.ball_scene = ball_scene
	if has_node("/root/CoordinateConverter"):
		gm.bonus_ball_spawn_position = CoordinateConverter.flutter_to_godot(Vector2(29.2, -24.5))
		gm.bonus_ball_impulse = CoordinateConverter.flutter_impulse_to_godot(Vector2(-40, 0))
	if has_node("/root/BackboxManager") and gm.has_method("set_character_theme"):
		gm.set_character_theme(BackboxManager.selected_character_key)
	var back_btn = get_node_or_null("UI/BackToMenuButton")
	if back_btn and back_btn is BaseButton:
		back_btn.pressed.connect(_on_back_to_menu)
	if gm.game_over.is_connected(_on_game_over) == false:
		gm.game_over.connect(_on_game_over)
	_connect_obstacles()
	if _camera:
		_camera.make_current()
	_apply_camera_status(gm.status)
	get_viewport().gui_release_focus()
	if gm.has_method("_ensure_ball_pool_initialized"):
		gm._ensure_ball_pool_initialized()
	call_deferred("_deferred_start_game")

func _deferred_start_game() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("start_game"):
		gm.start_game()

func _on_game_over() -> void:
	var gm = get_node_or_null("/root/GameManager")
	var backbox = get_node_or_null("/root/BackboxManager")
	if gm and backbox and backbox.has_method("request_initials"):
		backbox.request_initials(gm.display_score(), backbox.selected_character_key)
	_apply_camera_status(GameManager.Status.GAME_OVER)

func _connect_obstacles() -> void:
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	for obs in obstacles:
		if obs.has_signal("obstacle_hit"):
			obs.obstacle_hit.connect(_on_obstacle_hit)

func _on_obstacle_hit(points: int) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("add_score"):
		gm.add_score(points)
	if SoundManager:
		SoundManager.play_sound("obstacle_hit")

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _apply_camera_status(status: int) -> void:
	if not _camera:
		return
	# Full playfield: y 10–610, x 10–790. Launcher/flippers at y ~518–550. Use zoom to fit.
	var vp := get_viewport().get_visible_rect().size
	var playfield_height: float = 620.0
	var playfield_width: float = 820.0
	var zoom_y := vp.y / playfield_height
	var zoom_x := vp.x / playfield_width
	var zoom := minf(zoom_x, zoom_y)
	_camera.zoom = Vector2(zoom, zoom)
	# Center on playfield (walls 10–790 x, 10–610 y)
	_camera.position = Vector2(400, 310)
