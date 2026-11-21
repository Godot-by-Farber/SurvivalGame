extends Node
## Shows or hides the HUD on request. It starts hidden until the player spawns.

@onready var hud: Control = $HUD


func _enter_tree() -> void:
	EventSystem.hud_visibility_requested.connect(_on_hud_visibility_requested)


func _ready() -> void:
	hud.hide()


func _on_hud_visibility_requested(visible: bool) -> void:
	hud.visible = visible
