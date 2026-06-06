extends Node
## Global game state manager. Tracks current wave, score, and game flow.

enum GameState { MENU, PLAYING, PAUSED, LEVEL_UP, GAME_OVER }

var current_state: GameState = GameState.MENU
var current_wave: int = 0
var total_coins: int = 0
var total_leaves: int = 0
var enemies_killed: int = 0
var time_survived: float = 0.0

# Arena bounds (set by the arena scene)
var arena_bounds: Rect2 = Rect2(0, 0, 3840, 2160)


func _ready() -> void:
	pass


func start_game() -> void:
	current_state = GameState.PLAYING
	current_wave = 0
	total_coins = 0
	total_leaves = 0
	enemies_killed = 0
	time_survived = 0.0


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false


func game_over() -> void:
	current_state = GameState.GAME_OVER
	get_tree().paused = true


func add_coins(amount: int) -> void:
	total_coins += amount
	EventBus.coin_collected.emit(amount)


func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		time_survived += delta
