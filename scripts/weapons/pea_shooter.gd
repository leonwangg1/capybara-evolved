extends BaseWeapon
class_name PeaShooter
## Pea Shooter — fires a single fast projectile at the nearest enemy.

const PROJECTILE_SCENE_PATH := "res://scenes/weapons/projectile.tscn"
var _projectile_scene: PackedScene


func _ready() -> void:
	weapon_name = "Pea Shooter"
	fire_rate = 0.4
	damage = 8
	_projectile_scene = load(PROJECTILE_SCENE_PATH)


func _fire(target: Node2D) -> void:
	var direction := (target.global_position - global_position).normalized()
	var projectile := _spawn_projectile(_projectile_scene, global_position, direction)
	if projectile:
		projectile.speed = 600.0
		projectile.projectile_color = Color(0.6, 0.8, 0.2)  # Green pea color
		projectile.projectile_radius = 5.0
		projectile.pierce = 1 + (weapon_level - 1)  # +1 pierce per level


func _apply_level_stats() -> void:
	match weapon_level:
		2:
			damage = 12
			fire_rate = 0.35
		3:
			damage = 16
			fire_rate = 0.3
		4:
			damage = 22
			fire_rate = 0.25
		5:
			damage = 30
			fire_rate = 0.2
