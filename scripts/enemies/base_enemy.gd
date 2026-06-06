extends CharacterBody2D
class_name BaseEnemy
## Base enemy class. All enemies inherit from this.
## Handles movement toward player, health, death effects.

@export var move_speed: float = 100.0
@export var contact_damage: int = 10
@export var xp_value: int = 5
@export var coin_drop_chance: float = 0.15
@export var enemy_type: String = "base"

# ¾-view placeholder drawing
@export var body_color: Color = Color(0.3, 0.6, 0.2)
@export var body_width: float = 14.0
@export var body_height: float = 12.0

var _player: Node2D = null
var _is_dying: bool = false
var _flash_timer: float = 0.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var hitbox: HitboxComponent = $HitboxComponent
@onready var contact_timer: Timer = $ContactTimer


func _ready() -> void:
	add_to_group("enemies")
	_player = get_tree().get_first_node_in_group("player")

	# Connect health signals
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)

	# Set hitbox damage
	hitbox.damage = contact_damage

	EventBus.enemy_spawned.emit(self)


func _physics_process(delta: float) -> void:
	if _is_dying:
		return

	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Flash fade
	if _flash_timer > 0:
		_flash_timer -= delta

	# Move toward player
	if _player and is_instance_valid(_player):
		var direction := (_player.global_position - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

	queue_redraw()


func _draw() -> void:
	# Override in subclasses for unique visuals
	_draw_enemy_placeholder()


func _draw_enemy_placeholder() -> void:
	var color := body_color
	if _flash_timer > 0:
		color = Color.WHITE

	# Ground shadow
	_draw_ellipse(Vector2(0, body_height * 0.8), Vector2(body_width, body_height * 0.4), Color(0, 0, 0, 0.2))

	# Body
	_draw_ellipse(Vector2.ZERO, Vector2(body_width, body_height), color)

	# Eyes
	var eye_y := -body_height * 0.3
	draw_circle(Vector2(-body_width * 0.25, eye_y), 2.5, Color.WHITE)
	draw_circle(Vector2(body_width * 0.25, eye_y), 2.5, Color.WHITE)
	draw_circle(Vector2(-body_width * 0.25, eye_y), 1.2, Color(0.1, 0.08, 0.05))
	draw_circle(Vector2(body_width * 0.25, eye_y), 1.2, Color(0.1, 0.08, 0.05))

	# HP bar (only show when damaged)
	if health_component and health_component.current_hp < health_component.max_hp:
		_draw_hp_bar()


func _draw_hp_bar() -> void:
	var bar_width := body_width * 2.0
	var bar_height := 3.0
	var bar_y := -body_height - 6.0
	var bar_x := -bar_width / 2.0

	# Background
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.2, 0.05, 0.05, 0.8))
	# Fill
	var fill_width := bar_width * health_component.get_hp_percent()
	draw_rect(Rect2(bar_x, bar_y, fill_width, bar_height), Color(0.9, 0.2, 0.15))


func _draw_ellipse(center: Vector2, size: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	var point_count := 24
	for i in point_count:
		var angle := (float(i) / point_count) * TAU
		points.append(center + Vector2(cos(angle) * size.x, sin(angle) * size.y))
	draw_colored_polygon(points, color)


func _on_health_changed(_current_hp: int, _max_hp: int) -> void:
	# Flash white on hit
	_flash_timer = 0.12
	queue_redraw()


func _on_died() -> void:
	if _is_dying:
		return
	_is_dying = true

	# Notify systems
	EventBus.enemy_died.emit(global_position, enemy_type)
	GameManager.enemies_killed += 1

	# Death animation: shrink and fade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(_drop_loot)
	tween.chain().tween_callback(queue_free)


func _drop_loot() -> void:
	# Spawn XP gem
	_spawn_xp(global_position, xp_value)

	# Chance to drop coin
	if randf() < coin_drop_chance:
		_spawn_coin(global_position)


func _spawn_xp(pos: Vector2, value: int) -> void:
	var pickups_container := get_tree().get_first_node_in_group("pickups_container")
	if not pickups_container:
		return

	var xp_gem := preload("res://scenes/pickups/xp_gem.tscn").instantiate()
	xp_gem.global_position = pos
	xp_gem.xp_value = value
	pickups_container.add_child(xp_gem)


func _spawn_coin(pos: Vector2) -> void:
	var pickups_container := get_tree().get_first_node_in_group("pickups_container")
	if not pickups_container:
		return

	var coin := preload("res://scenes/pickups/coin.tscn").instantiate()
	coin.global_position = pos
	pickups_container.add_child(coin)
