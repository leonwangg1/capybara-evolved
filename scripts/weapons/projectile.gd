extends Area2D
class_name Projectile
## A projectile that moves in a direction and deals damage on contact.

@export var speed: float = 500.0
@export var damage: int = 10
@export var pierce: int = 1          ## How many enemies it can hit before dying
@export var lifetime: float = 3.0    ## Auto-despawn after this many seconds

var direction: Vector2 = Vector2.RIGHT
var _hits_remaining: int = 1
var _lifetime_timer: float = 0.0

# Projectile visual
@export var projectile_color: Color = Color(0.95, 0.85, 0.3)  # Yellow-ish
@export var projectile_radius: float = 4.0


func _ready() -> void:
	_hits_remaining = pierce
	_lifetime_timer = lifetime

	# Set up collision
	collision_layer = 4  # PlayerProjectiles layer
	collision_mask = 2   # Enemies layer
	monitoring = true
	monitorable = false

	# Create collision shape if not present
	if get_child_count() == 0 or not has_node("CollisionShape2D"):
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = projectile_radius
		shape.shape = circle
		add_child(shape)

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	# Lifetime
	_lifetime_timer -= delta
	if _lifetime_timer <= 0.0:
		queue_free()
		return

	# Check if off-screen with generous margin
	var screen_rect := get_viewport_rect()
	var cam := get_viewport().get_camera_2d()
	if cam:
		var cam_pos := cam.global_position
		var margin := 200.0
		var visible_rect := Rect2(
			cam_pos - screen_rect.size / 2.0 - Vector2(margin, margin),
			screen_rect.size + Vector2(margin * 2, margin * 2)
		)
		if not visible_rect.has_point(global_position):
			queue_free()


func _draw() -> void:
	# Trail
	var trail_length := direction * -8.0
	draw_line(Vector2.ZERO, trail_length, projectile_color.darkened(0.3), projectile_radius * 0.8)

	# Main body
	draw_circle(Vector2.ZERO, projectile_radius, projectile_color)

	# Glow
	draw_circle(Vector2.ZERO, projectile_radius * 0.5, projectile_color.lightened(0.4))


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		_hit(area)


func _on_body_entered(body: Node2D) -> void:
	if body.has_node("HurtboxComponent"):
		_hit(body.get_node("HurtboxComponent"))


func _hit(hurtbox: Node2D) -> void:
	# Deal damage through the hurtbox
	if hurtbox is HurtboxComponent:
		if hurtbox.health_component:
			hurtbox.health_component.take_damage(damage)

	_hits_remaining -= 1
	if _hits_remaining <= 0:
		queue_free()
