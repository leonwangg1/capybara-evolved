extends Area2D
class_name HitboxComponent
## Reusable hitbox — deals damage on contact with a HurtboxComponent.
## Attach to projectiles, weapons, or enemy attacks.

@export var damage: int = 10


func _ready() -> void:
	# Hitboxes monitor for hurtboxes
	monitorable = false
	monitoring = true
