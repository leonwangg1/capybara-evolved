extends Area2D
class_name HurtboxComponent
## Reusable hurtbox — receives damage from HitboxComponents.
## Attach to players, enemies, or destructible objects.

signal hurt(damage: int, hitbox: HitboxComponent)

## Path to the HealthComponent node (auto-routed damage)
@export var health_component_path: NodePath
var health_component: HealthComponent
var _is_invincible: bool = false


func _ready() -> void:
	monitorable = true
	monitoring = true
	area_entered.connect(_on_area_entered)

	# Resolve the health component from the path
	if health_component_path:
		health_component = get_node(health_component_path) as HealthComponent


func _on_area_entered(area: Area2D) -> void:
	if _is_invincible:
		return

	if area is HitboxComponent:
		var hitbox := area as HitboxComponent
		hurt.emit(hitbox.damage, hitbox)

		if health_component:
			health_component.take_damage(hitbox.damage)


func set_invincible(value: bool) -> void:
	_is_invincible = value
