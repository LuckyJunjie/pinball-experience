extends Node
## SoundManager - plays sound effects for pinball events.
## Handles missing files gracefully.

const SOUND_PATHS := {
	"ball_launch": "res://assets/sounds/ball_launch.wav",
	"ball_lost": "res://assets/sounds/ball_lost.wav",
	"flipper_click": "res://assets/sounds/flipper_click.wav",
	"hold_entry": "res://assets/sounds/hold_entry.wav",
	"obstacle_hit": "res://assets/sounds/obstacle_hit.wav",
}

var _players: Dictionary = {}

func _ready() -> void:
	for sound_name in SOUND_PATHS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_players[sound_name] = player

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
