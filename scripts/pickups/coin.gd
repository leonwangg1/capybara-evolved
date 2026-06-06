extends Area2D
class_name CoinPickup
## Coin dropped by enemies. Attracted to player when within pickup radius.

@export var coin_value: int = 1
@export var attract_speed: float = 350.0
@export var attract_radius: float = 60.0

var _is_attracted: bool = false
var _player: Node2D = null
var _bob_timer: float = 0.0

const COIN_COLOR := Color(1.0, 0.85, 0.2)  # Gold
const COIN_RADIUS := 6.0


func _ready() -> void:
	add_to_group("pickups")
	collision_layer = 16  # Pickups layer
	collision_mask = 1    # Player layer
	monitoring = false
	monitorable = true

	_player = get_tree().get_first_node_in_group("player")
	_bob_timer = randf() * TAU  # Random phase

	# Create collision shape
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	add_child(shape)

	# Spawn pop animation
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _physics_process(delta: float) -> void:
	if not _player or not is_instance_valid(_player):
		return

	_bob_timer += delta * 3.0
	var dist := global_position.distance_to(_player.global_position)

	if dist < attract_radius:
		_is_attracted = true

	if _is_attracted:
		var direction := (_player.global_position - global_position).normalized()
		global_position += direction * attract_speed * delta

		if dist < 20.0:
			_collect()

	queue_redraw()


func _collect() -> void:
	GameManager.add_coins(coin_value)
	queue_free()


func _draw() -> void:
	var bob_offset := sin(_bob_timer) * 2.0

	# Shadow
	_draw_ellipse(Vector2(0, COIN_RADIUS + 2), Vector2(COIN_RADIUS * 0.8, COIN_RADIUS * 0.3), Color(0, 0, 0, 0.15))

	# Coin body
	draw_circle(Vector2(0, bob_offset), COIN_RADIUS, COIN_COLOR)

	# Inner circle
	draw_circle(Vector2(0, bob_offset), COIN_RADIUS * 0.65, COIN_COLOR.lightened(0.2))

	# $ symbol (simple lines)
	draw_line(Vector2(0, bob_offset - 3), Vector2(0, bob_offset + 3), COIN_COLOR.darkened(0.3), 1.5)


func _draw_ellipse(center: Vector2, size: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	var point_count := 16
	for i in point_count:
		var angle := (float(i) / point_count) * TAU
		points.append(center + Vector2(cos(angle) * size.x, sin(angle) * size.y))
	draw_colored_polygon(points, color)
