extends Node3D
class_name EquippableItem
## Base class for items held in the player's hand; "use_item" animations call into subclasses.

const EQUIPPABLE_VISUAL_LAYER := 2 # rendered only by the equippable camera

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	for child in $MeshHolder.get_children():
		if child is VisualInstance3D:
			child.layers = EQUIPPABLE_VISUAL_LAYER


func try_to_use() -> void:
	if animation_player.is_playing():
		return
	
	animation_player.play("use_item")
