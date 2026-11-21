extends HBoxContainer
## The HUD hotbar: shows hotbar contents and highlights the active slot.


func _enter_tree() -> void:
	EventSystem.hotbar_updated.connect(update_hotbar)
	EventSystem.active_hotbar_slot_changed.connect(update_active_slot)
	EventSystem.item_unequipped.connect(update_active_slot.bind(EquippedItemManager.NO_SLOT))


func update_hotbar(hotbar: Array) -> void:
	for slot: HotbarSlot in get_children():
		slot.set_item_key(hotbar[slot.get_index()])


func update_active_slot(slot_index: int) -> void:
	for slot: HotbarSlot in get_children():
		slot.set_active(slot.get_index() == slot_index)
