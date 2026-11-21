extends Node
## Global stage service (autoload "Stages"): swaps the current stage (main menu, island, credits)
## behind a fade, loading the next stage on a background thread while the screen fades.

const FADE_TIME := 1.0

var current_stage: Stage

var _is_changing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_stage(stage_key: StageConfig.Keys) -> void:
	if _is_changing:
		return
	_is_changing = true

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Start loading right away, so the load overlaps with the fade.
	var path := StageConfig.get_stage_path(stage_key)
	ResourceLoader.load_threaded_request(path)

	await Fade.fade_in(FADE_TIME, true)

	Bulletins.destroy_all()
	get_tree().paused = false # e.g. when leaving the island from the pause menu

	if is_instance_valid(current_stage):
		current_stage.queue_free()
		current_stage = null

	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame

	var packed_stage := ResourceLoader.load_threaded_get(path) as PackedScene
	current_stage = packed_stage.instantiate() as Stage
	add_child(current_stage)

	if not current_stage.is_loaded:
		await current_stage.loading_complete

	await Fade.fade_out(FADE_TIME)
	_is_changing = false
