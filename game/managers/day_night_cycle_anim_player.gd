extends AnimationPlayer
class_name DayNightCycleAnimationPlayer
## Drives the day/night cycle animation, where the animation position is the hour of day.

const START_HOUR := 12.0


func _enter_tree() -> void:
	EventSystem.time_skip_requested.connect(_on_time_skip_requested)


func _ready() -> void:
	await get_tree().physics_frame
	seek(START_HOUR)


func _on_time_skip_requested(hours: float) -> void:
	seek(fmod(current_animation_position + hours, current_animation_length))
