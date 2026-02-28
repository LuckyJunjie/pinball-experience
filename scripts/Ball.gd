extends RigidBody2D
## Ball - physics body for pinball. Spawned at launcher.

const BALL_LAYER := 1
const BALL_MASK := 14  # 2+4+8: flippers, walls, obstacles

func _ready() -> void:
	collision_layer = BALL_LAYER
	collision_mask = BALL_MASK
	mass = 0.5
	gravity_scale = 1.0
	linear_damp = 0.05
	angular_damp = 0.05
	var physics_material := PhysicsMaterial.new()
	physics_material.bounce = 0.8
	physics_material.friction = 0.3
	physics_material_override = physics_material
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	$CollisionShape2D.shape = shape
