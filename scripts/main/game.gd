extends Node2D
## Main game scene — orchestrates the game session.

func _ready() -> void:
	GameManager.start_game()
