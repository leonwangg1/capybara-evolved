# Capybara Evolved

A top-down wave-defense survival game featuring a capybara protagonist, built with [Godot 4.4](https://godotengine.org/).

Survive endless waves of enemies, collect XP and coins, and level up to grow your arsenal of weapons. Inspired by the auto-attacking survivor genre.

> Built for [Stardance](https://stardance.hackclub.com/) 🌟

## Gameplay

- **Move** to dodge enemies and collect pickups — weapons fire automatically.
- **Survive** escalating waves of enemies that get tougher over time.
- **Level up** by collecting XP gems and choose new weapons or upgrades.
- **Collect coins** dropped by defeated enemies.

### Controls

| Action | Keys |
| --- | --- |
| Move | `WASD` / Arrow keys |
| Pause | `Esc` |

## Weapons

- **Pea Shooter** — rapid auto-firing starter weapon.
- **Acorn Bomb** — lobbed explosive with area damage.
- **Spread Shot** — fires multiple projectiles in a fan.

## Enemies

- **Frog** — basic chasing enemy, spawned in increasing numbers each wave.

## Tech

- **Engine:** Godot 4.4 (Forward+ renderer)
- **Language:** GDScript
- **Architecture:** Component-based (health, hitbox, hurtbox) with autoload singletons (`GameManager`, `EventBus`) for global state and decoupled event signalling.

## Project structure

```
scenes/        # Godot scene files (.tscn)
  main/        # Root game scene
  player/      # Player
  enemies/     # Enemy scenes
  weapons/     # Weapon & projectile scenes
  pickups/     # XP gems, coins
  ui/          # HUD, level-up panel
  environment/ # Arena
scripts/       # GDScript source
  autoload/    # GameManager, EventBus singletons
  components/  # Reusable health/hitbox/hurtbox components
  player/      # Player & weapon manager
  enemies/     # Enemy logic, spawner, wave manager
  weapons/     # Weapon implementations
  pickups/     # Pickup logic
  effects/     # Damage numbers, etc.
  ui/          # HUD, level-up panel
  environment/ # Arena
assets/        # Art and other game assets
```

## Running the game

1. Install [Godot 4.4](https://godotengine.org/download).
2. Clone this repository.
3. Open `project.godot` in Godot, or run from the command line:
   ```bash
   godot project.godot
   ```
4. Press **F5** (or the Play button) to launch.

## Status

Early development — version `0.1.0`.
