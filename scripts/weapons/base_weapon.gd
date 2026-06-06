extends Node2D
class_name BaseWeapon
## Base weapon class. All weapons inherit from this.
## Handles auto-fire timing and nearest-enemy targeting.

@export var fire_rate: float = 0.5  ## Seconds between shots
@export var damage: int = 10
@export var max_range: float = 500.0  ## Max distance to target an enemy
@export var weapon_name: String = "Weapon"
@export var weapon_level: int = 1
@export var max_level: int = 5

var _fire_timer: float = 0.0
var _can_fire: bool = true


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_fire_timer -= delta
	if _fire_timer <= 0.0:
		var target := _find_nearest_enemy()
		if target:
			_fire(target)
			_fire_timer = fire_rate


## Override in subclass to implement the actual firing behavior
func _fire(_target: Node2D) -> void:
	pass


## Find nearest enemy within range
func _find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null

	var nearest: Node2D = null
	var nearest_dist := max_range * max_range
	var player_pos := global_position

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist := player_pos.distance_squared_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy

	return nearest


## Spawn a projectile and add it to the Projectiles container
func _spawn_projectile(projectile_scene: PackedScene, spawn_pos: Vector2, direction: Vector2) -> Node2D:
	var projectile := projectile_scene.instantiate()
	projectile.global_position = spawn_pos
	projectile.direction = direction.normalized()
	projectile.damage = damage

	# Add to the Projectiles container in the game scene
	var projectiles_container := get_tree().get_first_node_in_group("projectiles_container")
	if projectiles_container:
		projectiles_container.add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)

	return projectile


## Level up the weapon — override to customize stat scaling
func level_up() -> void:
	if weapon_level >= max_level:
		return
	weapon_level += 1
	_apply_level_stats()


## Override to define how stats scale per level
func _apply_level_stats() -> void:
	pass
