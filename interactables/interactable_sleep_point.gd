extends Interactable
class_name InteractableSleepPoint


func start_interaction() -> void:
	EventSystem.sleep_requested.emit()
	Audio.play_sfx(SFXConfig.Keys.GoInTent)
