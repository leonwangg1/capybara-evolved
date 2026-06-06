extends BaseWeapon
class_name SpreadShot
## Spread Shot — fires a fan of projectiles.

const PROJECTILE_SCENE_PATH := "res://scenes/weapons/projectile.tscn"
var _projectile_scene: PackedScene


func _ready() -> void:
	weapon_name = "Spread Shot"
	fire_rate = 1.0
	damage = 6
	_projectile_scene = load(PROJECTILE_SCENE_PATH)


func _fire(target: Node2D) -> void:
	var base_direction := (target.global_position - global_position).normalized()
	
	var projectile_count := 3
	if weapon_level >= 3:
		projectile_count = 5
	if weapon_level >= 5:
		projectile_count = 7
		
	var spread_angle: float = deg_to_rad(45.0) # Total spread arc
	var angle_step: float = spread_angle / float(max(1, projectile_count - 1))
	var start_angle := -spread_angle / 2.0
	
	for i in projectile_count:
		var current_angle = start_angle + (i * angle_step)
		var direction := base_direction.rotated(current_angle)
		var projectile := _spawn_projectile(_projectile_scene, global_position, direction)
		if projectile:
			projectile.speed = 450.0
			projectile.projectile_color = Color(0.9, 0.7, 0.2)  # Orange/Yellow
			projectile.projectile_radius = 4.0
			projectile.pierce = 1 + int(weapon_level >= 4)


func _apply_level_stats() -> void:
	match weapon_level:
		2:
			damage = 8
			fire_rate = 0.9
		3:
			# Fires 5 projectiles now
			damage = 10
			fire_rate = 0.9
		4:
			# Projectiles pierce +1
			damage = 12
			fire_rate = 0.8
		5:
			# Fires 7 projectiles
			damage = 15
			fire_rate = 0.7
