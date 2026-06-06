extends CharacterBody2D
## Player character — the capybara. Handles movement, facing direction,
## and basic stats. Weapons and abilities are managed by child nodes.

@export var move_speed: float = 100.0
## Movement speed (px/s) at which the run animation plays at its native 12 fps.
## The animation's playback rate is scaled by velocity / this value so the legs
## cycle in step with how fast the capybara actually moves (no foot-sliding).
## Lower it if the legs look too slow for the movement; raise it if too frantic.
@export var run_anim_match_speed: float = 120.0

# Stats
var max_hp: int = 100
var current_hp: int = 100
var level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100

# Internal
var _facing_direction: Vector2 = Vector2.RIGHT
var _is_invincible: bool = false

# Directional run animations. Each is a SpriteFrames with a single "run" animation.
# Front/back are intentionally reversed (see _update_animation):
#   FRONT sheet plays when moving up (away from the camera)
#   BACK  sheet plays when moving down (toward the camera)
#   SIDE  = running left/right and along diagonals (flipped horizontally for left)
const SPRITE_FRONT: SpriteFrames = preload("res://assets/sprites/player/hero_run_front.tres")
const SPRITE_BACK: SpriteFrames = preload("res://assets/sprites/player/hero_run_back.tres")
const SPRITE_SIDE: SpriteFrames = preload("res://assets/sprites/player/hero_run.tres")

# Frame each run sheet rests on while idle (the pose that reads best standing still).
# The front direction uses a dedicated standing sprite instead (see StandingFront).
const IDLE_FRAME_SIDE: int = 3
const IDLE_FRAME_BACK: int = 8

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var standing_front: Sprite2D = $StandingFront
@onready var camera: Camera2D = $Camera2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var weapon_manager: Node2D = $WeaponManager


func _ready() -> void:
	add_to_group("player")

	# Initialize health
	max_hp = health_component.max_hp
	current_hp = health_component.current_hp
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_die)
	hurtbox.hurt.connect(_on_hurt)

	EventBus.player_health_changed.emit(current_hp, max_hp)
	EventBus.player_level_changed.emit(level)
	EventBus.player_xp_changed.emit(current_xp, xp_to_next_level)

	# Connect damage number signal
	EventBus.show_damage_number.connect(_on_show_damage_number)

	# Clamp camera to arena bounds
	_setup_camera_limits()

	# Equip starting weapon — Pea Shooter
	_equip_starting_weapons()


func _equip_starting_weapons() -> void:
	var pea_shooter_script := preload("res://scripts/weapons/pea_shooter.gd")
	var pea_shooter := Node2D.new()
	pea_shooter.set_script(pea_shooter_script)
	weapon_manager.add_child(pea_shooter)


func _physics_process(_delta: float) -> void:
	var input_dir := _get_input_direction()

	if input_dir != Vector2.ZERO:
		_facing_direction = input_dir.normalized()
		velocity = _facing_direction * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * 0.2)

	move_and_slide()

	# Clamp to arena bounds
	var bounds := GameManager.arena_bounds
	global_position.x = clampf(global_position.x, bounds.position.x + 20, bounds.end.x - 20)
	global_position.y = clampf(global_position.y, bounds.position.y + 20, bounds.end.y - 20)

	_update_animation(input_dir)


## Picks the run animation (front/back/side) from the movement direction and
## plays it. While idle, shows a per-direction rest pose: a chosen run frame for
## side/back, or the dedicated StandingFront sprite when facing front.
func _update_animation(input_dir: Vector2) -> void:
	if input_dir == Vector2.ZERO:
		# Idle: rest pose for the current facing direction.
		animated_sprite.stop()
		if animated_sprite.sprite_frames == SPRITE_FRONT:
			# Front idle uses the dedicated standing sprite, not a run frame.
			animated_sprite.visible = false
			standing_front.visible = true
		else:
			animated_sprite.frame = _idle_frame_for(animated_sprite.sprite_frames)
		return

	# Moving: ensure the run sprite is showing (not the standing pose).
	standing_front.visible = false
	animated_sprite.visible = true

	# Cycle the legs in step with the actual movement speed so the run
	# animation matches the distance travelled (avoids foot-sliding) and
	# keeps pace with any future move-speed upgrades.
	animated_sprite.speed_scale = velocity.length() / run_anim_match_speed

	var frames: SpriteFrames
	if absf(input_dir.x) >= absf(input_dir.y):
		# Horizontal-dominant movement, including diagonals -> side view.
		frames = SPRITE_SIDE
		animated_sprite.flip_h = input_dir.x < 0.0
	elif input_dir.y > 0.0:
		# Moving down — front/back reversed: use the back sheet + animation.
		frames = SPRITE_BACK
		animated_sprite.flip_h = false
	else:
		# Moving up — front/back reversed: use the front sheet + animation.
		frames = SPRITE_FRONT
		animated_sprite.flip_h = false

	if animated_sprite.sprite_frames != frames:
		animated_sprite.sprite_frames = frames
		animated_sprite.play("run")
	elif not animated_sprite.is_playing():
		animated_sprite.play("run")


## Returns the frame to rest on while idle for the given run sheet.
## (Front is handled separately via the standing sprite and never passed here.)
func _idle_frame_for(frames: SpriteFrames) -> int:
	if frames == SPRITE_BACK:
		return IDLE_FRAME_BACK
	return IDLE_FRAME_SIDE


func _get_input_direction() -> Vector2:
	return Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()


func _on_hurt(damage: int, _hitbox: HitboxComponent) -> void:
	if _is_invincible:
		return

	# HealthComponent already took the damage via HurtboxComponent
	current_hp = health_component.current_hp
	EventBus.player_health_changed.emit(current_hp, max_hp)

	# Brief invincibility after taking damage
	_is_invincible = true
	hurtbox.set_invincible(true)
	invincibility_timer.start()

	# Flash red
	animated_sprite.modulate = Color.RED
	var tween := create_tween()
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.2)


func _on_health_changed(hp: int, _max: int) -> void:
	current_hp = hp
	EventBus.player_health_changed.emit(current_hp, max_hp)


func take_damage(amount: int) -> void:
	# Legacy interface — route through health component
	if _is_invincible:
		return
	health_component.take_damage(amount)


func heal(amount: int) -> void:
	health_component.heal(amount)
	current_hp = health_component.current_hp
	EventBus.player_health_changed.emit(current_hp, max_hp)


func add_xp(amount: int) -> void:
	current_xp += amount
	EventBus.player_xp_changed.emit(current_xp, xp_to_next_level)

	while current_xp >= xp_to_next_level:
		_level_up()


func _level_up() -> void:
	current_xp -= xp_to_next_level
	level += 1
	xp_to_next_level = _calculate_xp_requirement(level)
	EventBus.player_level_changed.emit(level)
	EventBus.player_xp_changed.emit(current_xp, xp_to_next_level)


func _calculate_xp_requirement(lvl: int) -> int:
	return int(100 * pow(lvl, 1.2))


func _die() -> void:
	EventBus.player_died.emit()
	GameManager.game_over()


func _setup_camera_limits() -> void:
	var bounds := GameManager.arena_bounds
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)


func _on_invincibility_timer_timeout() -> void:
	_is_invincible = false
	hurtbox.set_invincible(false)


func _on_show_damage_number(amount: int, pos: Vector2, is_critical: bool) -> void:
	var dmg_num := DamageNumber.new()
	dmg_num.amount = amount
	dmg_num.is_critical = is_critical
	dmg_num.global_position = pos

	var effects_container := get_tree().get_first_node_in_group("effects_container")
	if effects_container:
		effects_container.add_child(dmg_num)
	else:
		get_tree().current_scene.add_child(dmg_num)
