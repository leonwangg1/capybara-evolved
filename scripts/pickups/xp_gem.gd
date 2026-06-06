extends Area2D
class_name XPGem
## XP gem dropped by enemies. Attracted to player when within pickup radius.

@export var xp_value: int = 5
@export var attract_speed: float = 400.0
@export var attract_radius: float = 80.0

var _is_attracted: bool = false
var _player: Node2D = null

const GEM_COLOR := Color(0.2, 0.9, 0.8)  # Cyan
const GEM_SIZE := Vector2(6, 8)


func _ready() -> void:
	add_to_group("pickups")
	collision_layer = 16  # Pickups layer
	collision_mask = 1    # Player layer
	monitoring = false
	monitorable = true

	_player = get_tree().get_first_node_in_group("player")

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

	var dist := global_position.distance_to(_player.global_position)

	if dist < attract_radius:
		_is_attracted = true

	if _is_attracted:
		var direction := (_player.global_position - global_position).normalized()
		global_position += direction * attract_speed * delta

		# Collect when close enough
		if dist < 20.0:
			_collect()

	queue_redraw()


func _collect() -> void:
	if _player.has_method("add_xp"):
		_player.add_xp(xp_value)
	EventBus.xp_collected.emit(xp_value)
	queue_free()


func _draw() -> void:
	# Diamond shape
	var points := PackedVector2Array([
		Vector2(0, -GEM_SIZE.y),    # Top
		Vector2(GEM_SIZE.x, 0),     # Right
		Vector2(0, GEM_SIZE.y),     # Bottom
		Vector2(-GEM_SIZE.x, 0),    # Left
	])
	draw_colored_polygon(points, GEM_COLOR)

	# Inner highlight
	var inner_points := PackedVector2Array([
		Vector2(0, -GEM_SIZE.y * 0.5),
		Vector2(GEM_SIZE.x * 0.5, 0),
		Vector2(0, GEM_SIZE.y * 0.5),
		Vector2(-GEM_SIZE.x * 0.5, 0),
	])
	draw_colored_polygon(inner_points, GEM_COLOR.lightened(0.4))
