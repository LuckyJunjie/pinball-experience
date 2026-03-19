extends Node2D
## Dino Desert - with smart crop for sprite sheet

const MOUTH_POINTS := 200000

var _mouth_cooldown: float = 0.0

@onready var _mouth_sensor: Area2D = $ChromeDino/MouthSensor

func _ready() -> void:
	# Apply smart crop to head sprite
	_apply_smart_crop()
	
	if _mouth_sensor:
		_mouth_sensor.body_entered.connect(_on_mouth_entered)

func _apply_smart_crop():
	var head = $ChromeDino/Head
	var mouth = $ChromeDino/Mouth
	
	if not head or not mouth:
		return
	
	# Get original values
	# Scale 3x and move left 300 pixels
	var head_pos = Vector2(-300, 0)
	var head_scale = Vector2(0.6, 0.6)  # 3x of 0.2
	var mouth_pos = Vector2(-300, 15)
	var mouth_scale = Vector2(0.6, 0.6)
	var head_tex = head.texture
	var mouth_tex = mouth.texture
	
	# Create animated sprites with cropped frames
	var head_anim = _create_animated_sprite(head_tex, "HeadAnim", head_pos, head_scale, 8, 9)
	var mouth_anim = _create_animated_sprite(mouth_tex, "MouthAnim", mouth_pos, mouth_scale, 8, 9)
	
	if head_anim:
		head.queue_free()
		$ChromeDino.add_child(head_anim)
	
	if mouth_anim:
		mouth.queue_free()
		$ChromeDino.add_child(mouth_anim)

func _create_animated_sprite(tex: Texture2D, name: String, pos: Vector2, scale: Vector2, cols: int, rows: int) -> AnimatedSprite2D:
	var anim = AnimatedSprite2D.new()
	anim.name = name
	anim.position = pos
	anim.scale = scale
	
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	frames.add_animation("default")
	
	var img = tex.get_image()
	if img:
		# Convert to RGBA
		img.convert(Image.FORMAT_RGBA8)
		
		# Crop: remove left 3 columns (3/8 = ~37.5%)
		var w = img.get_width()
		var h = img.get_height()
		var crop_x = int(w / cols * 3)  # Skip first 3 columns
		var crop_w = w - crop_x
		
		var cropped = img.get_region(Rect2i(crop_x, 0, crop_w, h))
		
		# Create frames from cropped image
		var frame_w = crop_w / cols
		var frame_h = h / rows
		
		for row in range(rows):
			for col in range(cols):
				var x = col * frame_w
				var y = row * frame_h
				var frame = Image.create(frame_w, frame_h, true, Image.FORMAT_RGBA8)
				frame.fill(Color(0,0,0,0))
				frame.blit_rect(cropped, Rect2i(x, y, frame_w, frame_h), Vector2i(0, 0))
				var frame_tex = ImageTexture.create_from_image(frame)
				frames.add_frame("default", frame_tex)
	
	frames.set_animation_speed("default", 8.0)
	frames.set_animation_loop("default", true)
	anim.sprite_frames = frames
	anim.play("default")
	
	return anim

func _process(delta: float) -> void:
	if _mouth_cooldown > 0:
		_mouth_cooldown -= delta

func _on_mouth_entered(body: Node2D) -> void:
	if _mouth_cooldown > 0 or not body.is_in_group("ball"):
		return
	_mouth_cooldown = 0.5
	GameManager.add_score(MOUTH_POINTS, "ChromeDino")
	GameManager.add_bonus(GameManager.Bonus.DINO_CHOMP)
	if SoundManager:
		SoundManager.play_sound("hold_entry")
