extends Interactable


func start_interaction() -> void:
	Stages.change_stage(StageConfig.Keys.Credits)
