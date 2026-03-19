extends Node2D
## Dino Desert - ChromeDino with animated sprites
## Auto-detects sprite sheet frame grid

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
	
	# Detect frame grid automatically
	var head_grid = _detect_frame_grid(head_tex)
	var mouth_grid = _detect_frame_grid(mouth_tex)
	
	print("[DinoDesert] Detected grid: head=%dx%d, mouth=%dx%d" % [head_grid.x, head_grid.y, mouth_grid.x, mouth_grid.y])
	
	# Head animation
	_head_anim = AnimatedSprite2D.new()
	_head_anim.name = "HeadAnim"
	_head_anim.position = head_pos
	_head_anim.scale = head_scale_val
	_head_anim.z_index = head_z
	
	var head_frames = _create_sprite_frames(head_tex, "head", head_grid.x, head_grid.y)
	head_frames.set_animation_speed("head", 8.0)
	head_frames.set_animation_loop("head", true)
	_head_anim.sprite_frames = head_frames
	_head_anim.play("head")
	
	head_sprite.queue_free()
	$ChromeDino.add_child(_head_anim)
	
	# Mouth animation
	_mouth_anim = AnimatedSprite2D.new()
	_mouth_anim.name = "MouthAnim"
	_mouth_anim.position = mouth_pos
	_mouth_anim.scale = mouth_scale_val
	_mouth_anim.z_index = head_z + 1
	
	var mouth_frames = _create_sprite_frames(mouth_tex, "mouth", mouth_grid.x, mouth_grid.y)
	mouth_frames.set_animation_speed("mouth", 12.0)
	mouth_frames.set_animation_loop("mouth", true)
	_mouth_anim.sprite_frames = mouth_frames
	_mouth_anim.play("mouth")
	
	mouth_sprite.queue_free()
	$ChromeDino.add_child(_mouth_anim)

## Detect frame grid by analyzing sprite sheet
func _detect_frame_grid(tex: Texture2D) -> Vector2i:
	var img = tex.get_image()
	if img == null:
		return Vector2i(1, 1)
	
	var w = img.get_width()
	var h = img.get_height()
	
	# Try common divisors
	var best = Vector2i(1, 1)
	var best_count = 0
	
	for cols in range(1, 11):
		for rows in range(1, 11):
			if cols * rows <= best_count:
				continue
			if w % cols == 0 and h % rows == 0:
				var frame_w = w / cols
				var frame_h = h / rows
				# Check if frames have content (non-transparent pixels)
				var count = _count_nonempty_frames(img, cols, rows, frame_w, frame_h)
				if count > best_count:
					best_count = count
					best = Vector2i(cols, rows)
	
	print("[DinoDesert] Detected %d frames (%dx%d)" % [best_count, best.x, best.y])
	return best

func _count_nonempty_frames(img: Image, cols: int, rows: int, frame_w: int, frame_h: int) -> int:
	var count = 0
	for row in range(rows):
		for col in range(cols):
			var x = col * frame_w
			var y = row * frame_h
			# Sample center of frame
			var sx = x + frame_w / 2
			var sy = y + frame_h / 2
			if sx < img.get_width() and sy < img.get_height():
				var pixel = img.get_pixel(sx, sy)
				if pixel.a > 0:
					count += 1
	return count

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
			var frame = Image.create(frame_w, frame_h, false, img.get_format())
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
