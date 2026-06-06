extends Node
## Global event bus for decoupled communication between systems.
## Signals are emitted and connected to here instead of direct node references.

# Player signals
signal player_health_changed(current_hp: int, max_hp: int)
signal player_died
signal player_level_changed(level: int)
signal player_xp_changed(current_xp: int, required_xp: int)

# Wave signals
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal wave_timer_updated(time_remaining: float)

# Enemy signals
signal enemy_died(enemy_position: Vector2, enemy_type: String)
signal enemy_spawned(enemy: Node2D)

# Pickup signals
signal coin_collected(amount: int)
signal xp_collected(amount: int)

# UI signals
signal level_up_choices_ready(choices: Array)
signal upgrade_selected(upgrade_data: Dictionary)
signal show_damage_number(amount: int, position: Vector2, is_critical: bool)
