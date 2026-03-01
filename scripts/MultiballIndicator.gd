extends Control
## MultiballIndicator - displays bonus ball indicators (up to 4).
## Shows lit indicators based on GameManager.active_bonus_balls.

@onready var indicator_1: Sprite2D = $Indicator1
@onready var indicator_2: Sprite2D = $Indicator2
@onready var indicator_3: Sprite2D = $Indicator3
@onready var indicator_4: Sprite2D = $Indicator4

# Preload textures
var dimmed_texture: Texture2D = preload("res://assets/sprites/multiball/dimmed.png")
var lit_texture: Texture2D = preload("res://assets/sprites/multiball/lit.png")

# Spacing between indicators
const INDICATOR_SPACING := 40

func _ready() -> void:
	# Connect to GameManager signals
	GameManager.bonus_ball_requested.connect(_on_bonus_ball_requested)
	GameManager.game_started.connect(_on_game_started)
	
	# Initial update
	_update_indicators()

func _on_bonus_ball_requested() -> void:
	_update_indicators()

func _on_game_started() -> void:
	_update_indicators()

func _update_indicators() -> void:
	var active_count: int = GameManager.active_bonus_balls
	
	# Clamp to max 4 indicators
	active_count = mini(active_count, 4)
	
	# Update each indicator
	_set_indicator_state(indicator_1, active_count >= 1)
	_set_indicator_state(indicator_2, active_count >= 2)
	_set_indicator_state(indicator_3, active_count >= 3)
	_set_indicator_state(indicator_4, active_count >= 4)

func _set_indicator_state(indicator: Sprite2D, is_lit: bool) -> void:
	if indicator:
		indicator.texture = lit_texture if is_lit else dimmed_texture
