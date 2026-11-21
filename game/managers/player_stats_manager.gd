extends Node
class_name PlayerStatsManager
## Owns the player's energy and health. Running out of energy drains health,
## and running out of health ends the game.

const MAX_ENERGY := 100.0
const MAX_HEALTH := 100.0

var energy := MAX_ENERGY
var health := MAX_HEALTH


func _enter_tree() -> void:
	EventSystem.energy_change_requested.connect(change_energy)
	EventSystem.health_change_requested.connect(change_health)


func change_energy(amount: float) -> void:
	energy += amount

	if energy <= 0:
		change_health(energy)

	energy = clampf(energy, 0, MAX_ENERGY)
	EventSystem.energy_updated.emit(MAX_ENERGY, energy)


func change_health(amount: float) -> void:
	health = minf(health + amount, MAX_HEALTH)
	EventSystem.health_updated.emit(MAX_HEALTH, health)

	if health <= 0:
		EventSystem.player_freeze_requested.emit(true)
		Stages.change_stage(StageConfig.Keys.MainMenu)
