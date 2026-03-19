extends Node2D
## Dino Desert - ChromeDino with animated sprites
## 8x9 grid (72 frames), scaled 3x, moved left 100px

const MOUTH_POINTS := 200000

var _mouth_cooldown: float = 0.0
var _head_anim: AnimatedSprite2D
var _mouth_anim: AnimatedSprite2D

@onready var _mouth_sensor: Area2D = $ChromeDino/MouthSensor

func _ready() -> void:
	_setup_animated_sprites()
	
	if _mouth_sensor:
		_mouth_sensor.body_entered.connect(_on_mouth_entered)

func _setup_animated_sprites():
	var chrome_dino = $ChromeDino
	
	# Remove ALL existing sprites first to avoid residuals
	var children = chrome_dino.get_children()
	for child in children:
		if child is Sprite2D or child is AnimatedSprite2D:
			child.queue_free()
	
	# Wait a frame for queue_free to process
	await get_tree().process_frame
	
	# Get original values from scene (before removal)
	var head_pos = Vector2(-39, 0)  # Moved left 100px: 61 -> -39
	var head_scale_val = Vector2(0.6, 0.6)  # 3x: 0.2 -> 0.6
	var mouth_pos = Vector2(-39 + 0, 15)  # Relative to head
	var mouth_scale_val = Vector2(0.6, 0.6)
	
	# Get textures
	var head_tex = load("res://assets/sprites/dino/animatronic/head.png")
	var mouth_tex = load("res://assets/sprites/dino/animatronic/mouth.png")
	
	# Use 5x9 grid - 2035 divisible by 5, 1422 divisible by 9
	var cols = 5
	var rows = 9
	
	print("[DinoDesert] Creating 5x9 animation (45 frames), scale=0.6, pos=(-39,0)")
	
	# Head animation
	_head_anim = AnimatedSprite2D.new()
	_head_anim.name = "HeadAnim"
	_head_anim.position = head_pos
	_head_anim.scale = head_scale_val
	
	var head_frames = _create_sprite_frames(head_tex, "head", cols, rows)
	head_frames.set_animation_speed("head", 12.0)
	head_frames.set_animation_loop("head", true)
	_head_anim.sprite_frames = head_frames
	_head_anim.play("head")
	
	chrome_dino.add_child(_head_anim)
	
	# Mouth animation
	_mouth_anim = AnimatedSprite2D.new()
	_mouth_anim.name = "MouthAnim"
	_mouth_anim.position = mouth_pos
	_mouth_anim.scale = mouth_scale_val
	_mouth_anim.z_index = 1
	
	var mouth_frames = _create_sprite_frames(mouth_tex, "mouth", cols, rows)
	mouth_frames.set_animation_speed("mouth", 12.0)
	mouth_frames.set_animation_loop("mouth", true)
	_mouth_anim.sprite_frames = mouth_frames
	_mouth_anim.play("mouth")
	
	chrome_dino.add_child(_mouth_anim)
	
	print("[DinoDesert] Done: 45 frames each, scale=0.6, moved left 100px")

func _create_sprite_frames(tex: Texture2D, anim_name: String, cols: int, rows: int) -> SpriteFrames:
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation(anim_name)
	
	var img = tex.get_image()
	if img == null:
		return frames
	
	var img_w = img.get_width()
	var img_h = img.get_height()
	var frame_w = img_w / cols
	var frame_h = img_h / rows
	
	for row in range(rows):
		for col in range(cols):
			var x = col * frame_w
			var y = row * frame_h
			
			var frame = Image.create(frame_w, frame_h, true, Image.FORMAT_RGBA8)
			frame.fill(Color(0, 0, 0, 0))
			frame.blit_rect(img, Rect2i(x, y, frame_w, frame_h), Vector2i(0, 0))
			
			var frame_tex = ImageTexture.create_from_image(frame)
			frames.add_frame(anim_name, frame_tex)
	
	return frames

func _process(delta: float) -> void:
	if _mouth_cooldown > 0:
		_mouth_cooldown -= delta

func _on_mouth_entered(body: Node2D) -> void:
	if _mouth_cooldown > 0 or not body.is_in_group("ball"):
		return
	_mouth_cooldown = 0.5
	GameManager.add_score(MOUTH_POINTS, "ChromeDino")
	GameManager.add_bonus(GameManager.Bonus.DINO_CHOMP)
	if _mouth_anim:
		_mouth_anim.play("mouth")
	if _head_anim:
		_head_anim.play("head")
	if SoundManager:
		SoundManager.play_sound("hold_entry")
