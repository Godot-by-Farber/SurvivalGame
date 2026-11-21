extends Bulletin
class_name FadingBulletin


const TRANSPARENT_COLOR := Color(0, 0, 0, 0)
const BG_NORMAL_COLOR := Color(0, 0, 0, 0.7)
const BG_FADE_TIME := 0.25

@onready var background: ColorRect = $ColorRect


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	background.color = TRANSPARENT_COLOR
	fade_in()
	EventSystem.hud_visibility_requested.emit(false)


func fade_in() -> void:
	create_tween().tween_property(background, "color", BG_NORMAL_COLOR, BG_FADE_TIME)


func fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", TRANSPARENT_COLOR, BG_FADE_TIME / 2.0)
	tween.tween_callback(destroy_self)


func destroy_self() -> void:
	Bulletins.destroy(bulletin_key)
