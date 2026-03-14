extends Control
## MainMenu - start flow: initial → selectCharacter → howToPlay → play (load Main).

enum FlowState { INITIAL, SELECT_CHARACTER, HOW_TO_PLAY }

var flow_state: FlowState = FlowState.INITIAL

@onready var play_panel: Control = $PlayPanel
@onready var character_panel: Control = $CharacterPanel
@onready var how_to_play_panel: Control = $HowToPlayPanel

func _ready() -> void:
	_show_state(FlowState.INITIAL)
	var play_btn = get_node_or_null("PlayPanel/VBox/PlayButton")
	if play_btn and play_btn is BaseButton:
		play_btn.pressed.connect(_on_play_pressed)
	var chars := ["Sparky", "Dino", "Dash", "Android"]
	for i in range(chars.size()):
		var btn = get_node_or_null("CharacterPanel/VBox/HBox/Character" + str(i + 1))
		if btn and btn is BaseButton:
			btn.pressed.connect(_on_character_pressed.bind(chars[i]))
	var done_btn = get_node_or_null("HowToPlayPanel/VBox/DoneButton")
	if done_btn and done_btn is BaseButton:
		done_btn.pressed.connect(_on_how_to_play_done)

func _show_state(s: FlowState) -> void:
	flow_state = s
	if play_panel:
		play_panel.visible = (s == FlowState.INITIAL)
	if character_panel:
		character_panel.visible = (s == FlowState.SELECT_CHARACTER)
	if how_to_play_panel:
		how_to_play_panel.visible = (s == FlowState.HOW_TO_PLAY)

func _on_play_pressed() -> void:
	_show_state(FlowState.SELECT_CHARACTER)

func _on_character_pressed(character_name: String) -> void:
	if has_node("/root/BackboxManager"):
		BackboxManager.selected_character_key = character_name.to_lower()
	_show_state(FlowState.HOW_TO_PLAY)

func _on_how_to_play_done() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
