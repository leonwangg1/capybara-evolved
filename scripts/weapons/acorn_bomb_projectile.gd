extends Node2D
class_name AcornBombProjectile
## The actual bomb projectile that arcs through the air and explodes.

@export var damage: int = 25
@export var explosion_radius: float = 60.0
@export var lob_duration: float = 0.8

var _target_pos: Vector2
var _start_pos: Vector2
var _time_elapsed: float = 0.0
var _is_lobbing: bool = false
var _visual_y_offset: float = 0.0


func _ready() -> void:
	# We don't use physics collision for the lob itself, only the explosion
	pass


func lob_to(target_pos: Vector2) -> void:
	_target_pos = target_pos
	_start_pos = global_position
	_time_elapsed = 0.0
	_is_lobbing = true
	
	# Small tween to scale up/down for depth effect during lob
	scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), lob_duration / 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), lob_duration / 2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)


func _process(delta: float) -> void:
	if not _is_lobbing:
		return
		
	_time_elapsed += delta
	var t := _time_elapsed / lob_duration
	
	if t >= 1.0:
		t = 1.0
		_explode()
		
	# Linear interpolation for ground position
	global_position = _start_pos.lerp(_target_pos, t)
	
	# Parabolic arc for visual height
	_visual_y_offset = -sin(t * PI) * 100.0
	
	queue_redraw()


func _explode() -> void:
	_is_lobbing = false
	
	# Screen shake (optional juice)
	
	# Deal AoE damage
	var hitbox := HitboxComponent.new()
	hitbox.damage = damage
	
	# Create temporary explosion area
	var explosion_area := Area2D.new()
	explosion_area.collision_layer = 4 # PlayerProjectiles
	explosion_area.collision_mask = 2  # Enemies
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = explosion_radius
	shape.shape = circle
	
	explosion_area.add_child(shape)
	add_child(explosion_area)
	
	# Force physics update to detect overlaps immediately
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var overlapping = explosion_area.get_overlapping_areas()
	for area in overlapping:
		if area is HurtboxComponent:
			var hurtbox = area as HurtboxComponent
			if hurtbox.health_component:
				hurtbox.health_component.take_damage(damage)
			
	# Cleanup
	explosion_area.queue_free()
	
	# Explosion visuals
	_visual_y_offset = 0.0
	queue_redraw()
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	if _is_lobbing:
		var offset := Vector2(0, _visual_y_offset)
		# Shadow
		var shadow_scale := 1.0 - absf(_visual_y_offset) / 150.0
		_draw_ellipse_shape(Vector2(0, 8), Vector2(8 * shadow_scale, 4 * shadow_scale), Color(0, 0, 0, 0.3))
		
		# Acorn body
		_draw_ellipse_shape(offset, Vector2(6, 8), Color(0.6, 0.4, 0.2))
		# Acorn cap
		_draw_ellipse_shape(offset + Vector2(0, -6), Vector2(8, 4), Color(0.3, 0.2, 0.1))
	else:
		# Explosion flash
		draw_circle(Vector2.ZERO, explosion_radius, Color(1.0, 0.5, 0.1, 0.6))
		draw_circle(Vector2.ZERO, explosion_radius * 0.7, Color(1.0, 0.8, 0.2, 0.8))
		draw_circle(Vector2.ZERO, explosion_radius * 0.3, Color(1.0, 1.0, 1.0, 1.0))


func _draw_ellipse_shape(center: Vector2, size: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	var point_count := 16
	for i in point_count:
		var angle := (float(i) / point_count) * TAU
		points.append(center + Vector2(cos(angle) * size.x, sin(angle) * size.y))
	draw_colored_polygon(points, color)
