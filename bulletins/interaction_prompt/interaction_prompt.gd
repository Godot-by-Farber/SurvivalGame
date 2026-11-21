extends Bulletin
class_name InteractionPrompt


@onready var label: Label = $Label


var prompt_text := ""


func initialize(arg: Variant) -> void:
	if arg is String:
		prompt_text = "E\n" + arg


func _ready() -> void:
	label.text = prompt_text

