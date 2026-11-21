extends InventorySlot
class_name StartingCookingSlot
## Cooking menu input slot: accepts only items that have a cooking recipe.


signal starting_ingredient_enabled
signal starting_ingredient_disabled

var cooking_in_progress := false


func _get_drag_data(at_position: Vector2) -> Variant:
	if cooking_in_progress:
		return null

	return super(at_position)


func _can_drop_data(_at_position: Vector2, slot: Variant) -> bool:
	if item_key != null or not slot is InventorySlot or slot.item_key == null:
		return false

	return ItemConfig.get_item_resource(slot.item_key).cooking_recipe != null


func _drop_data(_at_position: Vector2, source_slot: Variant) -> void:
	set_item_key(source_slot.item_key)
	EventSystem.slot_clear_requested.emit(source_slot.get_index(), source_slot is HotbarSlot)
	starting_ingredient_enabled.emit()
	Audio.play_sfx(SFXConfig.Keys.UIClick)
