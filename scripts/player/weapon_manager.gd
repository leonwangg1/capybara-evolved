extends Node2D
## WeaponManager — manages all equipped weapons on the player.
## Weapons are child nodes of this manager.

var equipped_weapons: Array[BaseWeapon] = []


func _ready() -> void:
	# Collect any weapons already attached as children
	for child in get_children():
		if child is BaseWeapon:
			equipped_weapons.append(child)


func add_weapon(weapon_scene: PackedScene) -> BaseWeapon:
	var weapon := weapon_scene.instantiate() as BaseWeapon
	add_child(weapon)
	equipped_weapons.append(weapon)
	return weapon


func add_weapon_by_script(weapon_script: Script) -> BaseWeapon:
	var weapon := Node2D.new()
	weapon.set_script(weapon_script)
	add_child(weapon)
	equipped_weapons.append(weapon as BaseWeapon)
	return weapon as BaseWeapon


func get_weapon(weapon_name: String) -> BaseWeapon:
	for weapon in equipped_weapons:
		if weapon.weapon_name == weapon_name:
			return weapon
	return null


func has_weapon(weapon_name: String) -> bool:
	return get_weapon(weapon_name) != null


func level_up_weapon(weapon_name: String) -> bool:
	var weapon := get_weapon(weapon_name)
	if weapon and weapon.weapon_level < weapon.max_level:
		weapon.level_up()
		return true
	return false
