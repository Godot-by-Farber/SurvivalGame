extends Node
## Global settings service (autoload "Settings"): holds, applies and persists user settings.

const SAVE_PATH := "user://settings.tres"
const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

## The current settings. Read it freely, but change it only through the setters below.
var resource: SettingsResource


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load()
	_apply_all()


func save() -> void:
	ResourceSaver.save(resource, SAVE_PATH)


func set_music_volume(volume_linear: float) -> void:
	resource.music_volume = volume_linear
	_set_bus_volume(MUSIC_BUS, volume_linear)


func set_sfx_volume(volume_linear: float) -> void:
	resource.sfx_volume = volume_linear
	_set_bus_volume(SFX_BUS, volume_linear)


func set_res_scale(scale: float) -> void:
	resource.res_scale = scale
	get_viewport().scaling_3d_scale = scale


func set_ssaa(enabled: bool) -> void:
	resource.ssaa_enabled = enabled
	get_viewport().screen_space_aa = (
		Viewport.SCREEN_SPACE_AA_FXAA if enabled else Viewport.SCREEN_SPACE_AA_DISABLED
	)


func set_fullscreen(enabled: bool) -> void:
	resource.fullscreen_enabled = enabled
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	)


func _load() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		resource = ResourceLoader.load(SAVE_PATH, "SettingsResource") as SettingsResource

	if resource == null:
		resource = SettingsResource.new()


func _apply_all() -> void:
	set_music_volume(resource.music_volume)
	set_sfx_volume(resource.sfx_volume)
	set_res_scale(resource.res_scale)
	set_ssaa(resource.ssaa_enabled)
	set_fullscreen(resource.fullscreen_enabled)


func _set_bus_volume(bus_name: StringName, volume_linear: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(volume_linear))
