extends Node
class_name EquippedItemManager
## Tracks which hotbar slot is active and equips or unequips items in response to hotkeys.

const NO_SLOT := -1

var active_slot := NO_SLOT
var hotbar: Array = []


func _enter_tree() -> void:
	EventSystem.hotbar_updated.connect(_on_hotbar_updated)
	EventSystem.hotkey_pressed.connect(_on_hotkey_pressed)
	EventSystem.equipped_item_used_up.connect(_on_equipped_item_used_up)


func _ready() -> void:
	EventSystem.active_hotbar_slot_changed.emit(NO_SLOT)


func _on_hotbar_updated(new_hotbar: Array) -> void:
	hotbar = new_hotbar

	if active_slot != NO_SLOT and hotbar[active_slot] == null:
		active_slot = NO_SLOT
		EventSystem.item_unequipped.emit()


func _on_hotkey_pressed(slot_number: int) -> void:
	var index := slot_number - 1

	if index < 0 or index >= hotbar.size() or hotbar[index] == null:
		return

	if index == active_slot:
		active_slot = NO_SLOT
		EventSystem.item_unequipped.emit()
		return

	active_slot = index
	EventSystem.item_equipped.emit(hotbar[index])
	EventSystem.active_hotbar_slot_changed.emit(index)


func _on_equipped_item_used_up() -> void:
	if active_slot == NO_SLOT:
		return

	EventSystem.slot_clear_requested.emit(active_slot, true)
	EventSystem.active_hotbar_slot_changed.emit(NO_SLOT)
	active_slot = NO_SLOT
