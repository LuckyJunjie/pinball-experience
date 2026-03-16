extends Control
## UI - HUD (score, multiplier, rounds) and game over panel. Flutter parity: score:, Ball Ct, Multiplier.

@onready var score_label: Label = $HUD/ScoreLabel
@onready var multiplier_label: Label = $HUD/MultiplierLabel
@onready var rounds_label: Label = $HUD/RoundsLabel
@onready var multiball_indicators: HBoxContainer = $HUD/MultiballIndicators
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_score: Label = $GameOverPanel/VBox/ScoreLabel
@onready var replay_button: Button = $GameOverPanel/VBox/ReplayButton

var _multiball_blink_timer: float = 0.0

func _ready() -> void:
	GameManager.scored.connect(_on_scored)
	GameManager.round_lost.connect(_on_round_lost)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_started.connect(_on_game_started)
	GameManager.bonus_activated.connect(_on_bonus_activated)
	game_over_panel.visible = false
	_setup_multiball_indicators()
	if replay_button:
		replay_button.pressed.connect(_on_replay)

func _setup_multiball_indicators() -> void:
	if not multiball_indicators:
		return
	for i in range(4):
		var tex := TextureRect.new()
		tex.custom_minimum_size = Vector2(16, 16)
		tex.texture = load("res://assets/sprites/multiball/dimmed.png") as Texture2D
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		multiball_indicators.add_child(tex)

func _on_bonus_activated(_bonus: GameManager.Bonus) -> void:
	if _bonus == GameManager.Bonus.GOOGLE_WORD or _bonus == GameManager.Bonus.DASH_NEST:
		_multiball_blink_timer = 5.0

func _on_scored(_points: int) -> void:
	_update_hud()

func _on_round_lost() -> void:
	_update_hud()

func _process(delta: float) -> void:
	if _multiball_blink_timer > 0:
		_multiball_blink_timer -= delta
		_update_multiball_indicators()

func _update_multiball_indicators() -> void:
	if not multiball_indicators:
		return
	var lit := _multiball_blink_timer > 0
	var tex_path := "res://assets/sprites/multiball/lit.png" if lit else "res://assets/sprites/multiball/dimmed.png"
	var tex = load(tex_path) as Texture2D
	for child in multiball_indicators.get_children():
		if child is TextureRect:
			child.texture = tex

func _on_game_over() -> void:
	_update_hud()
	game_over_panel.visible = true
	if score_label:
		score_label.text = "Game Over"
	if game_over_score:
		game_over_score.text = "Final Score: %s" % GameManager.display_score()
	if rounds_label:
		rounds_label.visible = false
	if replay_button:
		replay_button.grab_focus()

func _on_game_started() -> void:
	_update_hud()
	game_over_panel.visible = false
	if rounds_label:
		rounds_label.visible = true

func _on_replay() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _update_hud() -> void:
	if score_label:
		score_label.text = "score: %s" % GameManager.display_score()
	if multiplier_label:
		multiplier_label.text = "Multiplier: %dx" % GameManager.multiplier
	if rounds_label:
		rounds_label.text = "Ball Ct: %d" % GameManager.rounds
