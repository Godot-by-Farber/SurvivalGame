extends Stage


func _on_start_button_pressed() -> void:
	Stages.change_stage(StageConfig.Keys.Island)


func _on_settings_button_pressed() -> void:
	Bulletins.create(BulletinConfig.Keys.SettingsMenu, false)


func _on_credits_button_pressed() -> void:
	Stages.change_stage(StageConfig.Keys.Credits)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
