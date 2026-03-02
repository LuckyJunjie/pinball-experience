extends Node
## SoundManager - plays sound effects for pinball events.
## Handles missing files gracefully.
## Connected to GameManager signals for automatic playback.

const SOUND_PATHS := {
	"ball_launch": "res://assets/sounds/ball_launch.wav",
	"ball_lost": "res://assets/sounds/ball_lost.wav",
	"flipper_click": "res://assets/sounds/flipper_click.wav",
	"hold_entry": "res://assets/sounds/hold_entry.wav",
	"obstacle_hit": "res://assets/sounds/obstacle_hit.wav",
}

var _players: Dictionary = {}
var _game_manager: Node = null

func _ready() -> void:
	for sound_name in SOUND_PATHS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players[sound_name] = player
	
	# Connect to GameManager signals
	_connect_to_game_manager()

func _connect_to_game_manager() -> void:
	# Wait for GameManager to be ready
	await get_tree().create_timer(0.1).timeout
	_game_manager = get_tree().get_first_node_in_group("game_manager")
	if _game_manager == null:
		_game_manager = get_node_or_null("/root/Main/GameManager")
	
	if _game_manager:
		if _game_manager.has_signal("game_started"):
			_game_manager.game_started.connect(_on_game_started)
		if _game_manager.has_signal("round_lost"):
			_game_manager.round_lost.connect(_on_round_lost)
		if _game_manager.has_signal("bonus_activated"):
			_game_manager.bonus_activated.connect(_on_bonus_activated)

func _on_game_started() -> void:
	play_sound("ball_launch")

func _on_round_lost(_final_round: int, _mult: int) -> void:
	play_sound("ball_lost")

func _on_bonus_activated(_bonus_type: String) -> void:
	play_sound("hold_entry")

func play_sound(sound_name: String) -> void:
	if not SOUND_PATHS.has(sound_name):
		return
	var path: String = SOUND_PATHS[sound_name]
	if not ResourceLoader.exists(path):
		return
	var stream = load(path) as AudioStream
	if stream == null:
		return
	var player: AudioStreamPlayer = _players[sound_name]
	player.stream = stream
	player.play()
