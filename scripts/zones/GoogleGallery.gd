extends Node2D
## Google Gallery - Google Word letters, rollovers (5k each), bonus when all letters lit.

const ROLLOVER_POINTS := 5000
const LETTER_COUNT := 6

var _letters_lit: Array[bool] = []
var _cooldown_left: float = 0.0
var _cooldown_right: float = 0.0

@onready var _letter_sprites: Array[Sprite2D] = []
@onready var _letter_dimmed: Array[Texture2D] = []
@onready var _letter_lit: Array[Texture2D] = []
@onready var _rollover_left: Area2D = $RolloverLeft
@onready var _rollover_right: Area2D = $RolloverRight

func _ready() -> void:
	_reset_letters()
	for i in range(1, LETTER_COUNT + 1):
		var letter = get_node_or_null("GoogleWord/Letter%d" % i) as Sprite2D
		if letter:
			_letter_sprites.append(letter)
			_letter_dimmed.append(load("res://assets/sprites/google_word/letter%d/dimmed.png" % i) as Texture2D)
			_letter_lit.append(load("res://assets/sprites/google_word/letter%d/lit.png" % i) as Texture2D)
	if _rollover_left:
		_rollover_left.body_entered.connect(_on_rollover_left_entered)
	if _rollover_right:
		_rollover_right.body_entered.connect(_on_rollover_right_entered)

func _process(delta: float) -> void:
	if _cooldown_left > 0:
		_cooldown_left -= delta
	if _cooldown_right > 0:
		_cooldown_right -= delta

func _reset_letters() -> void:
	_letters_lit.clear()
	for _i in range(LETTER_COUNT):
		_letters_lit.append(false)
	_update_letter_visuals()

func _light_next_letter() -> void:
	for i in range(LETTER_COUNT):
		if not _letters_lit[i]:
			_letters_lit[i] = true
			_update_letter_visuals()
			if _all_lit():
				_on_all_letters_lit()
			return

func _all_lit() -> bool:
	for lit in _letters_lit:
		if not lit:
			return false
	return true

func _on_all_letters_lit() -> void:
	if GameManager:
		GameManager.add_bonus(GameManager.Bonus.GOOGLE_WORD)
	_reset_letters()
	if SoundManager:
		SoundManager.play_sound("hold_entry")

func _update_letter_visuals() -> void:
	for i in range(mini(_letter_sprites.size(), LETTER_COUNT)):
		if i < _letter_dimmed.size() and i < _letter_lit.size():
			_letter_sprites[i].texture = _letter_lit[i] if _letters_lit[i] else _letter_dimmed[i]

func _on_rollover_left_entered(body: Node2D) -> void:
	if _cooldown_left > 0:
		return
	if body.is_in_group("ball"):
		GameManager.add_score(ROLLOVER_POINTS, "GoogleRolloverLeft")
		_cooldown_left = 0.3
		_light_next_letter()
		if SoundManager:
			SoundManager.play_sound("hold_entry")

func _on_rollover_right_entered(body: Node2D) -> void:
	if _cooldown_right > 0:
		return
	if body.is_in_group("ball"):
		GameManager.add_score(ROLLOVER_POINTS, "GoogleRolloverRight")
		_cooldown_right = 0.3
		_light_next_letter()
		if SoundManager:
			SoundManager.play_sound("hold_entry")
