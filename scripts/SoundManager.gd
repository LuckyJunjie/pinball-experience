extends Node
## SoundManager - plays sound effects and BGM for pinball events.
## Handles missing files gracefully. Supports dynamic pitch and BGM.

# SFX definitions with default pitch
const SFX_PATHS := {
	"ball_launch": {"path": "res://assets/sounds/ball_launch.wav", "default_pitch": 1.0},
	"ball_lost": {"path": "res://assets/sounds/ball_lost.wav", "default_pitch": 1.0},
	"flipper_click": {"path": "res://assets/sounds/flipper_click.wav", "default_pitch": 1.0},
	"hold_entry": {"path": "res://assets/sounds/hold_entry.wav", "default_pitch": 1.0},
	"obstacle_hit": {"path": "res://assets/sounds/obstacle_hit.wav", "default_pitch": 1.0},
	# Additional SFX for expanded system
	"bumper_hit": {"path": "res://assets/sounds/obstacle_hit.wav", "default_pitch": 1.2},
	"combo": {"path": "res://assets/sounds/obstacle_hit.wav", "default_pitch": 1.5},
	"multiball": {"path": "res://assets/sounds/ball_launch.wav", "default_pitch": 0.8},
	"game_over": {"path": "res://assets/sounds/ball_lost.wav", "default_pitch": 0.7},
}

# BGM definitions
const BGM_PATHS := {
	"main_theme": "res://assets/sounds/main_theme.mp3",
	"multiball_theme": "res://assets/sounds/multiball_theme.mp3",
}

var _sfx_players: Dictionary = {}
var _bgm_player: AudioStreamPlayer = null
var _current_bgm: String = ""

func _ready() -> void:
	# Initialize SFX players
	for name in SFX_PATHS:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_players[name] = player
	
	# Initialize BGM player
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = "Music"
	_bgm_player.volume_db = -10.0  # Slightly lower than SFX
	add_child(_bgm_player)

## Play a sound effect with optional pitch adjustment
func play_sound(sound_name: String, pitch_scale: float = -1.0) -> void:
	if not SFX_PATHS.has(sound_name):
		push_warning("[SoundManager] Unknown sound: ", sound_name)
		return
	
	var sfx_info = SFX_PATHS[sound_name]
	var path: String = sfx_info["path"]
	
	if not ResourceLoader.exists(path):
		push_warning("[SoundManager] Sound file not found: ", path)
		return
	
	var stream = load(path) as AudioStream
	if stream == null:
		push_warning("[SoundManager] Failed to load sound: ", path)
		return
	
	var player: AudioStreamPlayer = _sfx_players[sound_name]
	player.stream = stream
	
	# Apply pitch scale
	if pitch_scale < 0.0:
		pitch_scale = sfx_info["default_pitch"]
	player.pitch_scale = clamp(pitch_scale, 0.5, 2.0)
	
	player.play()

## Play sound with velocity-based pitch (for ball collisions)
func play_collision_sound(velocity: float, base_pitch: float = 1.0) -> void:
	# Scale pitch based on velocity (faster = higher pitch)
	var speed_factor := clamp(velocity / 1000.0, 0.0, 1.0)
	var pitch := base_pitch + speed_factor * 0.5
	play_sound("obstacle_hit", pitch)

## Play flipper sound
func play_flipper_sound() -> void:
	play_sound("flipper_click", randf_range(0.9, 1.1))

## Play bumper hit sound
func play_bumper_sound(velocity: float = 500.0) -> void:
	play_collision_sound(velocity, 1.2)

## Play combo sound (increasing pitch for combos)
func play_combo_sound(combo_count: int) -> void:
	var pitch := 1.0 + (combo_count - 1) * 0.1
	play_sound("combo", min(pitch, 2.0))

## Play ball lost sound
func play_ball_lost() -> void:
	play_sound("ball_lost")

## Start BGM playback
func play_bgm(bgm_name: String, fade_time: float = 1.0) -> void:
	if not BGM_PATHS.has(bgm_name):
		push_warning("[SoundManager] Unknown BGM: ", bgm_name)
		return
	
	var path: String = BGM_PATHS[bgm_name]
	
	if not ResourceLoader.exists(path):
		push_warning("[SoundManager] BGM file not found: ", path)
		return
	
	var stream = load(path) as AudioStream
	if stream == null:
		push_warning("[SoundManager] Failed to load BGM: ", path)
		return
	
	# Fade out current BGM if playing
	if _bgm_player.playing:
		_fade_bgm_out(fade_time / 2.0)
	
	_bgm_player.stream = stream
	_bgm_player.play()
	_current_bgm = bgm_name

## Stop BGM playback
func stop_bgm(fade_time: float = 1.0) -> void:
	if _bgm_player.playing:
		_fade_bgm_out(fade_time)
	_current_bgm = ""

func _fade_bgm_out(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(_bgm_player, "volume_db", -40.0, duration)
	tween.tween_callback(_bgm_player.stop)
	tween.tween_property(_bgm_player, "volume_db", -10.0, 0.1)  # Reset for next play

func _fade_bgm_in(duration: float) -> void:
	_bgm_player.volume_db = -40.0
	var tween := create_tween()
	tween.tween_property(_bgm_player, "volume_db", -10.0, duration)

## Get current BGM name
func get_current_bgm() -> String:
	return _current_bgm

## Check if BGM is playing
func is_bgm_playing() -> bool:
	return _bgm_player.playing
