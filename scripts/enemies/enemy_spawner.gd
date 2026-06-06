extends Node
class_name EnemySpawner
## Spawns enemies from screen edges at increasing rates.

@export var base_spawn_interval: float = 1.5   ## Seconds between spawns at wave start
@export var min_spawn_interval: float = 0.3     ## Minimum interval cap
@export var spawn_margin: float = 100.0          ## Distance outside screen edge

var _spawn_timer: float = 0.0
var _current_interval: float = 1.5
var _enemies_alive: int = 0
var _max_enemies: int = 80

# Enemy scenes
var _frog_scene: PackedScene


func _ready() -> void:
	_frog_scene = preload("res://scenes/enemies/frog.tscn")
	_current_interval = base_spawn_interval


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	_enemies_alive = get_tree().get_nodes_in_group("enemies").size()

	if _enemies_alive >= _max_enemies:
		return

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_enemy()
		_spawn_timer = _current_interval


func _spawn_enemy() -> void:
	var spawn_pos := _get_spawn_position()

	var enemy := _frog_scene.instantiate()
	enemy.global_position = spawn_pos

	var enemies_container := get_tree().get_first_node_in_group("enemies_container")
	if enemies_container:
		enemies_container.add_child(enemy)
	else:
		get_tree().current_scene.add_child(enemy)


func _get_spawn_position() -> Vector2:
	var cam := get_viewport().get_camera_2d()
	if not cam:
		return Vector2.ZERO

	var viewport_size := get_viewport().get_visible_rect().size
	var cam_pos := cam.global_position

	# Pick a random edge (0=top, 1=right, 2=bottom, 3=left)
	var edge := randi() % 4
	var spawn_pos := Vector2.ZERO

	match edge:
		0: # Top
			spawn_pos = Vector2(
				cam_pos.x + randf_range(-viewport_size.x / 2.0, viewport_size.x / 2.0),
				cam_pos.y - viewport_size.y / 2.0 - spawn_margin
			)
		1: # Right
			spawn_pos = Vector2(
				cam_pos.x + viewport_size.x / 2.0 + spawn_margin,
				cam_pos.y + randf_range(-viewport_size.y / 2.0, viewport_size.y / 2.0)
			)
		2: # Bottom
			spawn_pos = Vector2(
				cam_pos.x + randf_range(-viewport_size.x / 2.0, viewport_size.x / 2.0),
				cam_pos.y + viewport_size.y / 2.0 + spawn_margin
			)
		3: # Left
			spawn_pos = Vector2(
				cam_pos.x - viewport_size.x / 2.0 - spawn_margin,
				cam_pos.y + randf_range(-viewport_size.y / 2.0, viewport_size.y / 2.0)
			)

	# Clamp to arena bounds
	var bounds := GameManager.arena_bounds
	spawn_pos.x = clampf(spawn_pos.x, bounds.position.x + 20, bounds.end.x - 20)
	spawn_pos.y = clampf(spawn_pos.y, bounds.position.y + 20, bounds.end.y - 20)

	return spawn_pos


## Increase difficulty — call from WaveManager
func increase_difficulty(wave: int) -> void:
	_current_interval = maxf(base_spawn_interval - wave * 0.1, min_spawn_interval)
	_max_enemies = mini(80, 30 + wave * 5)
