extends InventorySlot
class_name HotbarSlot

const ACTIVE_COLOR := Color.WHITE
const INACTIVE_COLOR := Color(0.8, 0.8, 0.8, 0.6)


func _ready() -> void:
	($HotkeyTextureRect/HotkeyLabel as Label).text = str(get_index() + 1)


func _can_drop_data(_at_position: Vector2, slot: Variant) -> bool:
	return slot is InventorySlot and slot.item_key != null and ItemConfig.get_item_resource(slot.item_key).is_equippable


func set_active(active: bool) -> void:
	modulate = ACTIVE_COLOR if active else INACTIVE_COLOR
