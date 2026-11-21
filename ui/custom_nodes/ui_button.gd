extends Button
class_name UIButton


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	Audio.play_sfx(SFXConfig.Keys.UIClick)
