extends Node
class_name WaveManager
## Handles wave timing, progression, and difficulty scaling.

@export var wave_duration: float = 45.0  ## Seconds per wave
@export var intermission_duration: float = 5.0

var current_wave: int = 0
var wave_timer: float = 0.0
var _is_intermission: bool = false
var _spawner: EnemySpawner


func _ready() -> void:
	_spawner = get_tree().get_first_node_in_group("spawner")
	if not _spawner:
		# Fallback if group not set
		_spawner = get_parent().get_node_or_null("EnemySpawner")
		
	# Start first wave immediately
	_start_wave(1)


func _process(delta: float) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return

	wave_timer -= delta
	EventBus.wave_timer_updated.emit(wave_timer)
	
	if wave_timer <= 0.0:
		if _is_intermission:
			_start_wave(current_wave + 1)
		else:
			_start_intermission()


func _start_wave(wave: int) -> void:
	current_wave = wave
	GameManager.current_wave = wave
	_is_intermission = false
	wave_timer = wave_duration
	
	EventBus.wave_started.emit(current_wave)
	
	if _spawner:
		_spawner.set_process(true)
		_spawner.increase_difficulty(current_wave)


func _start_intermission() -> void:
	_is_intermission = true
	wave_timer = intermission_duration
	EventBus.wave_completed.emit(current_wave)
	
	if _spawner:
		# Stop spawning during intermission
		_spawner.set_process(false)
		
	# Kill all existing enemies? Or let player clear them?
	# Typical survivor games let you clear them. We'll leave them alive.
