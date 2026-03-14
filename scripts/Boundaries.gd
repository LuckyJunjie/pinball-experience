extends Node2D
## Step 0.3 – Walls and boundaries. Confines the ball to the playfield (except drain).
## Applies bouncy physics material to all wall StaticBody2D children so the ball bounces off.

func _ready() -> void:
	add_to_group("boundaries")
	var material := PhysicsMaterial.new()
	material.bounce = 0.6
	material.friction = 0.2
	for child in get_children():
		if child is StaticBody2D:
			child.physics_material_override = material
