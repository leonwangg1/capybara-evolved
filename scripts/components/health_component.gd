extends Node
class_name HealthComponent
## Reusable health component. Attach to any entity that has HP.
## Emits signals when health changes or entity dies.

signal health_changed(current_hp: int, max_hp: int)
signal died

@export var max_hp: int = 100

var current_hp: int


func _ready() -> void:
	current_hp = max_hp


func take_damage(amount: int) -> void:
	current_hp = maxi(current_hp - amount, 0)
	health_changed.emit(current_hp, max_hp)

	if current_hp <= 0:
		died.emit()


func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	health_changed.emit(current_hp, max_hp)


func get_hp_percent() -> float:
	if max_hp == 0:
		return 0.0
	return float(current_hp) / float(max_hp)
