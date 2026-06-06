extends Node2D
## Arena — Defines the playable area boundaries and draws the environment.
## For Phase 1 this is a simple colored rectangle with bounds.

@export var arena_size: Vector2 = Vector2(3840, 2160)

# Colors for the placeholder arena
const GROUND_COLOR := Color(0.48, 0.41, 0.28)       # Sandy riverbank tan
const BORDER_COLOR := Color(0.35, 0.25, 0.15)        # Brown border
const BORDER_WIDTH := 16.0
const GRID_COLOR := Color(0.25, 0.40, 0.18, 0.3)     # Subtle grid lines
const GRID_SPACING := 128.0


func _ready() -> void:
	# Set the arena bounds in GameManager so other systems know
	GameManager.arena_bounds = Rect2(Vector2.ZERO, arena_size)


func _draw() -> void:
	# Ground fill
	draw_rect(Rect2(Vector2.ZERO, arena_size), GROUND_COLOR)

	# Subtle grid for spatial reference
	for x in range(0, int(arena_size.x), int(GRID_SPACING)):
		draw_line(Vector2(x, 0), Vector2(x, arena_size.y), GRID_COLOR, 1.0)
	for y in range(0, int(arena_size.y), int(GRID_SPACING)):
		draw_line(Vector2(0, y), Vector2(arena_size.x, y), GRID_COLOR, 1.0)

	# Border
	draw_rect(Rect2(Vector2.ZERO, arena_size), BORDER_COLOR, false, BORDER_WIDTH)

	# Corner markers (decorative)
	var corner_size := 48.0
	var corners := [
		Vector2(BORDER_WIDTH, BORDER_WIDTH),
		Vector2(arena_size.x - BORDER_WIDTH - corner_size, BORDER_WIDTH),
		Vector2(BORDER_WIDTH, arena_size.y - BORDER_WIDTH - corner_size),
		Vector2(arena_size.x - BORDER_WIDTH - corner_size, arena_size.y - BORDER_WIDTH - corner_size),
	]
	for corner in corners:
		draw_rect(Rect2(corner, Vector2(corner_size, corner_size)), BORDER_COLOR.lightened(0.2))
