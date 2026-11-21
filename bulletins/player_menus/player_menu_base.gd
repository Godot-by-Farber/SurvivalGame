extends Bulletin
class_name PlayerMenuBase
## Base for menus that show the inventory (crafting, cooking). Freezes the player while open.


@onready var inventory_slot_container: GridContainer = %InventorySlotContainer
@onready var item_info_label: Label = %ItemInfoLabel
@onready var extra_info_label: Label = %ExtraInfoLabel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventSystem.inventory_updated.connect(update_inventory)
	EventSystem.item_info_text_changed.connect(item_info_label.set_text)
	EventSystem.extra_info_text_changed.connect(extra_info_label.set_text)
	EventSystem.player_freeze_requested.emit(true)
	EventSystem.inventory_refresh_requested.emit()
	Audio.play_sfx(SFXConfig.Keys.UIClick)


func update_inventory(inventory: Array) -> void:
	for i in inventory.size():
		(inventory_slot_container.get_child(i) as InventorySlot).set_item_key(inventory[i])


func close() -> void:
	Bulletins.destroy(bulletin_key)
	EventSystem.player_freeze_requested.emit(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Audio.play_sfx(SFXConfig.Keys.UIClick)
