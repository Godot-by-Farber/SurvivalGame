extends CanvasLayer
## Global screen fade service (autoload "Fade", scene fade.tscn).
## Fades the screen and the master volume together. Both methods are coroutines,
## so use [code]await Fade.fade_in(...)[/code] to continue after the fade ends.

const MASTER_BUS := &"Master"
const CLEAR := Color(0, 0, 0, 0)

@onready var _overlay: ColorRect = $Overlay
@onready var _animation_player: AnimationPlayer = $Overlay/AnimationPlayer


## Fades to black and silence. Shows the pulsing "Loading" label when it is done if requested.
func fade_in(duration: float, show_loading_label := false) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color", Color.BLACK, duration)
	tween.parallel().tween_method(_set_master_volume, 1.0, 0.0, duration)
	await tween.finished

	if show_loading_label:
		_animation_player.play("loading_animation")


## Fades back from black, restoring the master volume.
func fade_out(duration: float) -> void:
	_animation_player.play("RESET")
	var tween := create_tween()
	tween.tween_property(_overlay, "color", CLEAR, duration)
	tween.parallel().tween_method(_set_master_volume, 0.0, 1.0, duration)
	await tween.finished


func _set_master_volume(volume_linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS), linear_to_db(volume_linear))
