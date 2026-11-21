extends Interactable
class_name Pickuppable


@export var item_key: ItemConfig.Keys

@onready var object: Node3D = get_parent()


func start_interaction() -> void:
	EventSystem.pickup_requested.emit(item_key, destroy)


func destroy() -> void:
	Audio.play_sfx(SFXConfig.Keys.ItemPickup)
	object.queue_free()
