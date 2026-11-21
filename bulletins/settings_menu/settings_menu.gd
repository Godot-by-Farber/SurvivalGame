extends FadingBulletin
class_name SettingsMenu


@onready var music_volume_label: Label = %MusicVolumeLabel
@onready var sfx_volume_label: Label = %SFXVolumeLabel
@onready var resolution_scale_label: Label = %ResolutionScaleLabel

@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var resolution_scale_slider: HSlider = %ResolutionScaleSlider
@onready var ssaa_check_button: CheckButton = %SSAACheckButton
@onready var fullscreen_check_button: CheckButton = %FullscreenCheckButton


var open_pause_menu_after_closing := false


## [param arg] is true when the menu was opened from the pause menu.
func initialize(arg: Variant) -> void:
	open_pause_menu_after_closing = arg == true


func _ready() -> void:
	_show_current_settings(Settings.resource)

	music_volume_slider.value_changed.connect(_on_music_volume_slider_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_slider_value_changed)
	resolution_scale_slider.value_changed.connect(_on_resolution_scale_slider_value_changed)
	ssaa_check_button.toggled.connect(_on_ssaa_check_button_toggled)
	fullscreen_check_button.toggled.connect(_on_fullscreen_check_button_toggled)

	super()


func fade_in() -> void:
	create_tween().tween_property(background, "color", BG_NORMAL_COLOR, BG_FADE_TIME / 2.0)


func _show_current_settings(settings: SettingsResource) -> void:
	music_volume_slider.value = settings.music_volume
	_set_percent_label(music_volume_label, settings.music_volume)

	sfx_volume_slider.value = settings.sfx_volume
	_set_percent_label(sfx_volume_label, settings.sfx_volume)

	resolution_scale_slider.value = settings.res_scale
	_set_percent_label(resolution_scale_label, settings.res_scale)

	ssaa_check_button.button_pressed = settings.ssaa_enabled
	fullscreen_check_button.button_pressed = settings.fullscreen_enabled


func _set_percent_label(label: Label, value: float) -> void:
	label.text = "%d %%" % roundi(value * 100)


func _on_music_volume_slider_value_changed(value: float) -> void:
	Settings.set_music_volume(value)
	_set_percent_label(music_volume_label, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	Settings.set_sfx_volume(value)
	_set_percent_label(sfx_volume_label, value)


func _on_resolution_scale_slider_value_changed(value: float) -> void:
	Settings.set_res_scale(value)
	_set_percent_label(resolution_scale_label, value)


func _on_ssaa_check_button_toggled(toggled_on: bool) -> void:
	Audio.play_sfx(SFXConfig.Keys.UIClick)
	Settings.set_ssaa(toggled_on)


func _on_fullscreen_check_button_toggled(toggled_on: bool) -> void:
	Audio.play_sfx(SFXConfig.Keys.UIClick)
	Settings.set_fullscreen(toggled_on)


func _on_close_button_pressed() -> void:
	fade_out()
	Settings.save()

	if open_pause_menu_after_closing:
		Bulletins.create(BulletinConfig.Keys.PauseMenu)
