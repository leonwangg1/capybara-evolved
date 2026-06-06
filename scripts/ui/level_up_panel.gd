extends CanvasLayer
class_name LevelUpPanel
## Displays random upgrade options when the player levels up.

signal upgrade_selected(upgrade_id: String)

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var options_container: HBoxContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/OptionsContainer

var _current_choices: Array = []


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep running while paused
	
	EventBus.player_level_changed.connect(_on_player_level_up)


func _on_player_level_up(level: int) -> void:
	if level > 1: # Ignore level 1 (start)
		_show_upgrades()


func _show_upgrades() -> void:
	# Pause the game
	GameManager.pause_game()
	
	# Generate choices
	_generate_choices()
	_populate_ui()
	
	# Show panel with a pop animation
	visible = true
	panel_container.scale = Vector2(0.5, 0.5)
	panel_container.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel_container, "modulate:a", 1.0, 0.2)


func _generate_choices() -> void:
	_current_choices.clear()
	
	# Hardcoded pool for Phase 3. 
	# In a full game, this would query a data file or resource.
	var pool := [
		{"id": "pea_shooter", "name": "Pea Shooter", "desc": "Fire a fast projectile."},
		{"id": "spread_shot", "name": "Spread Shot", "desc": "Fire a fan of projectiles."},
		{"id": "acorn_bomb", "name": "Acorn Bomb", "desc": "Lob an explosive bomb."},
		{"id": "max_hp", "name": "Max HP", "desc": "Increase max health by 20."},
		{"id": "speed", "name": "Move Speed", "desc": "Increase movement speed by 10%."}
	]
	
	# Pick 3 unique random choices
	pool.shuffle()
	_current_choices = pool.slice(0, 3)


func _populate_ui() -> void:
	# Clear old buttons
	for child in options_container.get_children():
		child.queue_free()
		
	# Create new buttons
	for choice in _current_choices:
		var btn = Button.new()
		btn.text = choice["name"] + "\n\n" + choice["desc"]
		btn.custom_minimum_size = Vector2(200, 300)
		btn.pressed.connect(func(): _on_upgrade_selected(choice["id"]))
		
		# Add some styling
		btn.add_theme_font_size_override("font_size", 16)
		# A real game would use a custom StyleBox here
		
		options_container.add_child(btn)

func _on_upgrade_selected(id: String) -> void:
	# Apply upgrade
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	if id == "pea_shooter" or id == "spread_shot" or id == "acorn_bomb":
		var weapon_mgr = player.get_node("WeaponManager")
		var weapon_name = id.replace("_", " ").capitalize()
		# Very naive weapon leveling for prototype
		if weapon_mgr.has_weapon(weapon_name):
			weapon_mgr.level_up_weapon(weapon_name)
		else:
			var script_path = "res://scripts/weapons/" + id + ".gd"
			weapon_mgr.add_weapon_by_script(load(script_path))
			
	elif id == "max_hp":
		var health = player.get_node("HealthComponent")
		health.max_hp += 20
		player.heal(20)
		
	elif id == "speed":
		player.move_speed *= 1.1
		
	# Hide panel and resume
	visible = false
	GameManager.resume_game()
