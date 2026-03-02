extends Control
## UI - HUD (score, multiplier, rounds) and game over panel.

@onready var score_label: Label = $HUD/ScoreLabel
@onready var multiplier_label: Label = $HUD/MultiplierLabel
@onready var rounds_label: Label = $HUD/RoundsLabel
@onready var combo_label: Label = $HUD/ComboLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_score: Label = $GameOverPanel/VBox/ScoreLabel
@onready var replay_button: Button = $GameOverPanel/VBox/ReplayButton

# Score popup
var _score_popup_scene: PackedScene = preload("res://scenes/ScorePopup.tscn")
var _popup_container: Node = null

func _ready() -> void:
	GameManager.scored.connect(_on_scored)
	GameManager.round_lost.connect(_on_round_lost)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_started.connect(_on_game_started)
	game_over_panel.visible = false
	if replay_button:
		replay_button.pressed.connect(_on_replay)
	
	# 隐藏 Combo 标签初始状态
	if combo_label:
		combo_label.visible = false
	
	# 获取 ComboManager 并连接信号
	var combo_manager = get_tree().get_first_node_in_group("combo_manager")
	if combo_manager == null:
		combo_manager = get_node_or_null("../ComboManager")
	if combo_manager and combo_manager.has_signal("combo_increased"):
		combo_manager.combo_increased.connect(_on_combo_increased)
	if combo_manager and combo_manager.has_signal("combo_reset"):
		combo_manager.combo_reset.connect(_on_combo_reset)
	
	# 创建分数弹窗容器
	_popup_container = Node2D.new()
	_popup_container.name = "PopupContainer"
	add_child(_popup_container)

func _on_scored(points: int, source: String) -> void:
	_update_hud()
	# Spawn score popup (only for significant scores)
	if points >= 5000 and _popup_container != null:
		_spawn_score_popup(points)

func _spawn_score_popup(points: int) -> void:
	var popup: Label = _score_popup_scene.instantiate()
	_popup_container.add_child(popup)
	# Random offset for visual variety
	var offset := Vector2(randf_range(-30, 30), randf_range(-20, 20))
	popup.position = get_viewport().get_mouse_position() + offset
	popup.setup(points, popup.position)

func _on_round_lost(_final_round: int, _mult: int) -> void:
	_update_hud()

func _on_game_over(final_score: int) -> void:
	_update_hud()
	game_over_panel.visible = true
	if game_over_score:
		game_over_score.text = str(final_score)
	if replay_button:
		replay_button.grab_focus()

func _on_game_started() -> void:
	_update_hud()
	game_over_panel.visible = false

func _on_replay() -> void:
	get_tree().reload_current_scene()

func _on_combo_increased(new_combo: int) -> void:
	_update_combo_display(new_combo)

func _on_combo_reset() -> void:
	_update_combo_display(0)

func _update_combo_display(combo_count: int) -> void:
	if combo_label:
		if combo_count >= 2:
			combo_label.visible = true
			combo_label.text = "COMBO x%d!" % combo_count
			# 简单的缩放动画
			var tween = create_tween()
			tween.tween_property(combo_label, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(combo_label, "scale", Vector2(1.0, 1.0), 0.1)
		else:
			combo_label.visible = false

func _update_hud() -> void:
	if score_label:
		score_label.text = str(GameManager.get_display_score())
	if multiplier_label:
		multiplier_label.text = "x%d" % GameManager.multiplier
	if rounds_label:
		rounds_label.text = "Rounds: %d" % GameManager.rounds
