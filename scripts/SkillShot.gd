extends Area2D
## SkillShot - 技能射击目标
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
