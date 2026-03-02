extends RigidBody2D
## Flipper - left or right flipper. Rotates on input.

@export var is_left: bool = true
@export var rest_angle: float = 0.0
@export var pressed_angle: float = -45.0  # negative for left
@export var rotation_speed: float = 600.0

var _target_angle: float = 0.0
var _was_pressed: bool = false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	gravity_scale = 0.0
	freeze = true
	freeze_mode = FREEZE_MODE_KINEMATIC
	if not is_left:
		pressed_angle = 45.0
	_target_angle = rest_angle
	var physics_material := PhysicsMaterial.new()
	physics_material.bounce = 0.6
	physics_material.friction = 0.5
	physics_material_override = physics_material

func _physics_process(delta: float) -> void:
	var action := "flipper_left" if is_left else "flipper_right"
	var pressed := Input.is_action_pressed(action)
	if pressed:
		_target_angle = pressed_angle
		if not _was_pressed and SoundManager:
			SoundManager.play_sound("flipper_click")
	else:
		_target_angle = rest_angle
	_was_pressed = pressed
	var diff := _target_angle - rotation_degrees
	if abs(diff) > 0.5:
		rotation_degrees += sign(diff) * min(abs(diff), rotation_speed * delta)
