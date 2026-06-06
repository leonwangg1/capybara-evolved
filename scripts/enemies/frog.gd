extends BaseEnemy
class_name FrogEnemy
## Frog — fast melee enemy that hops toward the player.

var _hop_timer: float = 0.0
var _hop_interval: float = 0.8
var _is_hopping: bool = false
var _hop_progress: float = 0.0
var _visual_y_offset: float = 0.0  # For hop animation


func _ready() -> void:
	super._ready()
	enemy_type = "frog"
	move_speed = 140.0
	contact_damage = 8
	xp_value = 5
	body_color = Color(0.25, 0.55, 0.15)  # Green frog
	body_width = 12.0
	body_height = 10.0
	_hop_timer = randf_range(0, _hop_interval)  # Stagger hops


func _physics_process(delta: float) -> void:
	if _is_dying or GameManager.current_state != GameManager.GameState.PLAYING:
		return

	# Flash fade
	if _flash_timer > 0:
		_flash_timer -= delta

	# Hop timing
	_hop_timer -= delta
	if _hop_timer <= 0:
		_hop_timer = _hop_interval
		_is_hopping = true
		_hop_progress = 0.0

	# Hop animation
	if _is_hopping:
		_hop_progress += delta / 0.3  # 0.3s hop duration
		if _hop_progress >= 1.0:
			_is_hopping = false
			_hop_progress = 1.0
			_visual_y_offset = 0.0
		else:
			# Parabolic arc
			_visual_y_offset = -sin(_hop_progress * PI) * 20.0

	# Move toward player (only during hop)
	if _player and is_instance_valid(_player) and _is_hopping:
		var direction := (_player.global_position - global_position).normalized()
		velocity = direction * move_speed * 2.0  # Faster during hop
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	queue_redraw()


func _draw() -> void:
	var color := body_color
	if _flash_timer > 0:
		color = Color.WHITE

	# Ground shadow (stays on ground even during hop)
	var shadow_scale: float = 1.0 - absf(_visual_y_offset) / 40.0
	_draw_ellipse(Vector2(0, body_height * 0.8), Vector2(body_width * shadow_scale, body_height * 0.35 * shadow_scale), Color(0, 0, 0, 0.2))

	# Apply hop offset for all body parts
	var offset := Vector2(0, _visual_y_offset)

	# Body (round, frog-like)
	_draw_ellipse(offset + Vector2(0, 0), Vector2(body_width, body_height), color)

	# Belly
	_draw_ellipse(offset + Vector2(0, body_height * 0.3), Vector2(body_width * 0.7, body_height * 0.5), color.lightened(0.2))

	# Eyes (big, on top — frog style)
	var eye_size := 5.0
	draw_circle(offset + Vector2(-body_width * 0.4, -body_height * 0.6), eye_size, Color.WHITE)
	draw_circle(offset + Vector2(body_width * 0.4, -body_height * 0.6), eye_size, Color.WHITE)
	# Pupils
	draw_circle(offset + Vector2(-body_width * 0.4, -body_height * 0.6), 2.5, Color(0.15, 0.1, 0.05))
	draw_circle(offset + Vector2(body_width * 0.4, -body_height * 0.6), 2.5, Color(0.15, 0.1, 0.05))

	# Mouth line
	var mouth_y := offset.y + body_height * 0.1
	draw_line(
		Vector2(-body_width * 0.3, mouth_y),
		Vector2(body_width * 0.3, mouth_y),
		color.darkened(0.3), 1.5
	)

	# HP bar
	if health_component and health_component.current_hp < health_component.max_hp:
		_draw_hp_bar()
