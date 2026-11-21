extends Node
class_name SleepManager
## Runs the sleep sequence: fade out, skip time, fade back in.

const FADE_IN_TIME := 2.0
const FADE_OUT_TIME := 1.0
const HOURS_SLEPT := 8.0
const BLACK_SCREEN_TIME := 1.5


func _enter_tree() -> void:
	EventSystem.sleep_requested.connect(_on_sleep_requested)


func _on_sleep_requested() -> void:
	EventSystem.player_freeze_requested.emit(true)
	await Fade.fade_in(FADE_IN_TIME)

	EventSystem.time_skip_requested.emit(HOURS_SLEPT)
	await get_tree().create_timer(BLACK_SCREEN_TIME).timeout

	EventSystem.player_freeze_requested.emit(false)
	Fade.fade_out(FADE_OUT_TIME)
