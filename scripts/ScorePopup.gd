extends Label
## ScorePopup - floating score text that animates up and fades out.
## Spawned by UI.gd when scoring events occur.

var _lifetime: float = 0.8
var _timer: float = 0.0
var _start_y: float = 0.0

func _ready() -> void:
	_start_y = position.y
	modulate.a = 1.0

func _process(delta: float) -> void:
	_timer += delta
	var t: float = _timer / _lifetime
	
	if t >= 1.0:
		queue_free()
		return
	
	# Move up
	position.y = _start_y - (50.0 * t)
	
	# Fade out
	modulate.a = 1.0 - t
	
	# Scale effect
	var scale_val := 1.0 + (0.3 * sin(t * PI))
	scale = Vector2(scale_val, scale_val)

func setup(points: int, world_position: Vector2) -> void:
	text = _format_score(points)
	position = world_position
	# Color based on points
	modulate = _get_color_for_points(points)

func _format_score(points: int) -> String:
	if points >= 1000000:
		return "%dM" % (points / 1000000)
	elif points >= 1000:
		return "%dk" % (points / 1000)
	return str(points)

func _get_color_for_points(points: int) -> Color:
	if points >= 1000000:
		return Color(0.8, 0.2, 1.0)  # Purple for 1M+
	elif points >= 200000:
		return Color(1.0, 0.4, 0.7)   # Pink for 200k+
	elif points >= 20000:
		return Color(1.0, 0.6, 0.0)  # Orange for 20k+
	else:
		return Color(1.0, 1.0, 0.4)  # Yellow for 5k
