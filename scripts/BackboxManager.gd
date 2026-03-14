extends Node
## BackboxManager - character selection and (future) leaderboard/initials/share.
## Holds selected character for the session; MainMenu sets it, Main reads it.

signal state_changed(state_name: String, data: Variant)

## Character key set by MainMenu when user selects (e.g. "sparky", "dino", "dash", "android").
var selected_character_key: String = "sparky"

## Optional: leaderboard entries for display. Filled by load_leaderboard() when implemented.
var leaderboard_entries: Array = []

## Called from Main on game over when leaderboard/initials flow is implemented.
func request_initials(score: int, character_theme_key: String) -> void:
	# Stub: later show initials form, submit to leaderboard, then share.
	state_changed.emit("initials_requested", {"score": score, "character_key": character_theme_key})

func _ready() -> void:
	add_to_group("backbox_manager")
