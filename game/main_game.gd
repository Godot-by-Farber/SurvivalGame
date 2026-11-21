extends Node
## Main scene. It hosts the HUD and boots into the main menu.
## Game-wide services live in autoloads; see project.godot.


func _ready() -> void:
	Stages.change_stage(StageConfig.Keys.MainMenu)
