extends Control
## UI - HUD (score, multiplier, rounds) and game over panel.

@onready var score_label: Label = $HUD/ScoreLabel
@onready var multiplier_label: Label = $HUD/MultiplierLabel
@onready var rounds_label: Label = $HUD/RoundsLabel
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_score: Label = $GameOverPanel/VBox/ScoreLabel
@onready var replay_button: Button = $GameOverPanel/VBox/ReplayButton

func _ready() -> void:
	GameManager.scored.connect(_on_scored)
	GameManager.round_lost.connect(_on_round_lost)
	GameManager.game_over.connect(_on_game_over)
	GameManager.game_started.connect(_on_game_started)
	game_over_panel.visible = false
	if replay_button:
		replay_button.pressed.connect(_on_replay)

func _on_scored(_points: int, _source: String) -> void:
	_update_hud()

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

func _update_hud() -> void:
	if score_label:
		score_label.text = str(GameManager.get_display_score())
	if multiplier_label:
		multiplier_label.text = "x%d" % GameManager.multiplier
	if rounds_label:
		rounds_label.text = "Rounds: %d" % GameManager.rounds
