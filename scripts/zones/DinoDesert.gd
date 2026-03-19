extends Node2D
## Dino Desert - ChromeDino with animated sprites
## Uses fixed 5x3 grid for animation frames

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
	var head_sprite = $ChromeDino/Head
	var mouth_sprite = $ChromeDino/Mouth
	
	if not head_sprite or not mouth_sprite:
		return
	
	var head_tex = head_sprite.texture
	var mouth_tex = mouth_sprite.texture
	
	var head_pos = head_sprite.position
	var head_scale_val = head_sprite.scale
	var mouth_pos = mouth_sprite.position
	var mouth_scale_val = mouth_sprite.scale
	var head_z = head_sprite.z_index
	
	# Use 5x3 grid - this divides evenly: 2035x1422 -> 407x474
	var cols = 5
	var rows = 3
	
	print("[DinoDesert] Using fixed grid: %dx%d" % [cols, rows])
	
	# Head animation
	_head_anim = AnimatedSprite2D.new()
	_head_anim.name = "HeadAnim"
	_head_anim.position = head_pos
	_head_anim.scale = head_scale_val
	_head_anim.z_index = head_z
	
	var head_frames = _create_sprite_frames(head_tex, "head", cols, rows)
	head_frames.set_animation_speed("head", 8.0)
	head_frames.set_animation_loop("head", true)
	_head_anim.sprite_frames = head_frames
	_head_anim.play("head")
	
	head_sprite.queue_free()
	$ChromeDino.add_child(_head_anim)
	
	# Mouth animation - overlay on top of head
	_mouth_anim = AnimatedSprite2D.new()
	_mouth_anim.name = "MouthAnim"
	_mouth_anim.position = mouth_pos
	_mouth_anim.scale = mouth_scale_val
	_mouth_anim.z_index = head_z + 1  # Above head
	
	var mouth_frames = _create_sprite_frames(mouth_tex, "mouth", cols, rows)
	mouth_frames.set_animation_speed("mouth", 12.0)
	mouth_frames.set_animation_loop("mouth", true)
	_mouth_anim.sprite_frames = mouth_frames
	_mouth_anim.play("mouth")
	
	mouth_sprite.queue_free()
	$ChromeDino.add_child(_mouth_anim)
	
	print("[DinoDesert] Animation setup complete: %d head frames, %d mouth frames" % [head_frames.get_frame_count("head"), mouth_frames.get_frame_count("mouth")])

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
			
			# Create frame image with transparency
			var frame = Image.create(frame_w, frame_h, true, Image.FORMAT_RGBA8)
			frame.fill(Color(0, 0, 0, 0))  # Clear to transparent
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
