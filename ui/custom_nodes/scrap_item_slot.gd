extends TextureRect
class_name ScrapItemSlot
## Drop target that deletes the dragged inventory or hotbar item.

signal item_scrapped


func _can_drop_data(_at_position: Vector2, slot: Variant) -> bool:
	return slot is InventorySlot and not slot is StartingCookingSlot and not slot is FinalCookingSlot


func _drop_data(_at_position: Vector2, source_slot: Variant) -> void:
	if source_slot is InventorySlot:
		EventSystem.slot_clear_requested.emit(source_slot.get_index(), source_slot is HotbarSlot)
		item_scrapped.emit()
