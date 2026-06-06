extends BaseWeapon
class_name AcornBombWeapon
## Acorn Bomb — lobs an explosive bomb at the nearest enemy.

const PROJECTILE_SCENE_PATH := "res://scenes/weapons/acorn_bomb_projectile.tscn"
var _projectile_scene: PackedScene


func _ready() -> void:
	weapon_name = "Acorn Bomb"
	fire_rate = 2.0
	damage = 25
	_projectile_scene = load(PROJECTILE_SCENE_PATH)


func _fire(target: Node2D) -> void:
	# Calculate how many bombs to throw
	var bomb_count := 1
	if weapon_level >= 3:
		bomb_count = 2
	if weapon_level >= 5:
		bomb_count = 3
		
	for i in bomb_count:
		# If throwing multiple, add some random spread to the target position
		var target_pos := target.global_position
		if bomb_count > 1:
			target_pos += Vector2(randf_range(-50, 50), randf_range(-50, 50))
			
		var bomb := _spawn_projectile(_projectile_scene, global_position, Vector2.RIGHT)
		if bomb and bomb.has_method("lob_to"):
			bomb.damage = damage
			bomb.explosion_radius = 60.0 + (weapon_level * 10.0)
			bomb.lob_to(target_pos)


func _apply_level_stats() -> void:
	match weapon_level:
		2:
			damage = 35
			fire_rate = 1.8
		3:
			# Throws 2 bombs
			damage = 45
		4:
			damage = 60
			fire_rate = 1.6
		5:
			# Throws 3 bombs
			damage = 80
			fire_rate = 1.5
