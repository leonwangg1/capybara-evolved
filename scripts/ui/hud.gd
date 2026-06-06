extends CanvasLayer
## HUD — Displays player health, wave info, XP bar, coins, and level.

@onready var hp_bar: ProgressBar = $TopLeft/VBox/ProfileStats/Stats/HPBar
@onready var hp_label: Label = $TopLeft/VBox/ProfileStats/Stats/HPBar/HPLabel
@onready var hearts_container: HBoxContainer = $TopLeft/VBox/ProfileStats/Stats/HeartsContainer
@onready var wave_label: Label = $TopCenter/VBox/WaveLabel
@onready var timer_label: Label = $TopCenter/VBox/TimerLabel
@onready var wave_progress: ProgressBar = $TopCenter/VBox/WaveProgress
@onready var coin_label: Label = $TopLeft/VBox/Currencies/Coins/Label
@onready var xp_bar: ProgressBar = $BottomLeft/HBox/XPBar
@onready var xp_label: Label = $BottomLeft/HBox/XPBar/XPLabel
@onready var level_label: Label = $BottomLeft/HBox/LevelLabel
@onready var weapons_container: HBoxContainer = $BottomCenter/HBox/WeaponsContainer


func _ready() -> void:
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_level_changed.connect(_on_level_changed)
	EventBus.player_xp_changed.connect(_on_xp_changed)
	EventBus.wave_started.connect(_on_wave_started)
	EventBus.wave_timer_updated.connect(_on_wave_timer_updated)
	EventBus.coin_collected.connect(_on_coin_collected)

	# Initialize display
	_update_coin_display()
	wave_label.text = "WAVE 0"
	timer_label.text = "00:00"
	wave_progress.max_value = 45.0 # hardcoded initial wave length
	wave_progress.value = 45.0


func _on_health_changed(current_hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_label.text = "%d / %d" % [current_hp, max_hp]
	_update_hearts(current_hp, max_hp)


func _on_level_changed(level: int) -> void:
	level_label.text = "Lv. %d" % level


func _on_xp_changed(current_xp: int, required_xp: int) -> void:
	xp_bar.max_value = required_xp
	xp_bar.value = current_xp
	xp_label.text = "%d / %d" % [current_xp, required_xp]


func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "WAVE %d" % wave_number


func _on_wave_timer_updated(time_remaining: float) -> void:
	var minutes := int(time_remaining) / 60
	var seconds := int(time_remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
	wave_progress.value = time_remaining


func _on_coin_collected(_amount: int) -> void:
	_update_coin_display()


func _update_coin_display() -> void:
	coin_label.text = str(GameManager.total_coins)


func _update_hearts(current_hp: int, max_hp: int) -> void:
	var total_hearts := max_hp / 20
	var full_hearts := current_hp / 20
	var has_partial := (current_hp % 20) > 0

	# Clear existing hearts
	for child in hearts_container.get_children():
		child.queue_free()

	for i in total_hearts:
		var heart := Label.new()
		if i < full_hearts:
			heart.text = "♥"
			heart.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		elif i == full_hearts and has_partial:
			heart.text = "♥"
			heart.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
		else:
			heart.text = "♡"
			heart.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		heart.add_theme_font_size_override("font_size", 24)
		hearts_container.add_child(heart)
