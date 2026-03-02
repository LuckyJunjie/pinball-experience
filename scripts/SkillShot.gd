extends Area2D
## SkillShot - 技能射击目标
<<<<<<< HEAD
## 发射后2-3秒内激活，击中获得1M分

signal hit(points: int)

@export var activation_time: float = 3.0  # 激活时间窗口(秒)
@export var points: int = 1000000  # 技能射击奖励分数

var is_active: bool = false
var time_remaining: float = 0.0
var _timer: Timer = null

func _ready():
	# 创建计时器
	_timer = Timer.new()
	_timer.wait_time = 0.1
	_timer.autostart = false
	add_child(_timer)
	_timer.timeout.connect(_on_timer_timeout)
	
	# 连接碰撞信号
	body_entered.connect(_on_body_entered)

func activate() -> void:
	"""激活技能射击"""
	is_active = true
	time_remaining = activation_time
	_timer.start()
	_play_activation_effect()
	print("[SkillShot] Activated! Window: ", activation_time, "s")

func deactivate() -> void:
	"""停用技能射击"""
	is_active = false
	time_remaining = 0.0
	_timer.stop()
	_play_deactivation_effect()
	print("[SkillShot] Deactivated")

func _on_timer_timeout() -> void:
	"""计时器回调"""
	if is_active:
		time_remaining -= 0.1
		if time_remaining <= 0:
			deactivate()

func _on_body_entered(body: Node2D) -> void:
	"""球进入技能射击区域"""
	if not is_active:
		return
	
	if body.is_in_group("ball"):
		# 击中！奖励分数
		hit.emit(points)
		GameManager.add_score(points)
		_play_hit_effect()
		deactivate()
		print("[SkillShot] HIT! +", points)

func _play_activation_effect():
	"""播放激活视觉/声音效果"""
	# TODO: 添加激活时的视觉反馈
	modulate = Color(1, 1, 0)  # 黄色高亮

func _play_deactivation_effect():
	"""播放停用效果"""
	modulate = Color(1, 1, 1)  # 恢复正常颜色

func _play_hit_effect():
	"""播放击中效果"""
	# TODO: 添加击中时的粒子效果和声音
	modulate = Color(0, 1, 0)  # 绿色闪烁
	await get_tree().create_timer(0.2).timeout
	modulate = Color(1, 1, 1)
=======
## 发射后2-3秒内击中获得1M分

signal skill_shot_hit(points: int)

const SKILL_SHOT_POINTS := 1000000
const WINDOW_DURATION := 2.5  # seconds

var _active := false
var _timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var trigger_area: Area2D = $TriggerArea

func _ready() -> void:
	if trigger_area:
		trigger_area.body_entered.connect(_on_body_entered)
	_active = false
	_timer = 0.0
	_update_visual()

func _process(delta: float) -> void:
	if _active:
		_timer -= delta
		if _timer <= 0:
			_deactivate()

func activate() -> void:
	_active = true
	_timer = WINDOW_DURATION
	_update_visual()
	print("SkillShot: 激活! 窗口期 %.1f 秒" % WINDOW_DURATION)

func _deactivate() -> void:
	_active = false
	_timer = 0.0
	_update_visual()
	print("SkillShot: 已过期")

func _on_body_entered(body: Node2D) -> void:
	if not _active:
		return
	
	if body.is_in_group("ball"):
		_hit()

func _hit() -> void:
	if not _active:
		return
	
	_active = false
	_timer = 0.0
	
	# 添加分数
	if GameManager:
		GameManager.add_score(SKILL_SHOT_POINTS, "skill_shot")
	
	skill_shot_hit.emit(SKILL_SHOT_POINTS)
	print("SkillShot: 击中! +%d 分!" % SKILL_SHOT_POINTS)
	
	_update_visual()

func _update_visual() -> void:
	if sprite:
		# active = lit, inactive = dimmed
		var tex_path = "res://assets/sprites/skill_shot/"
		tex_path += "lit.png" if _active else "dimmed.png"
		if ResourceLoader.exists(tex_path):
			sprite.texture = load(tex_path)
>>>>>>> 705116bfd71db35fc81043d20a98e382b39bc825
