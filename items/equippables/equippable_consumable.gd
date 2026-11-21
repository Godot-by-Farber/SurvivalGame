extends EquippableItem
class_name EquippableConsumable

var consumable_item_resource: ConsumableItemResource


func consume() -> void:
	EventSystem.health_change_requested.emit(consumable_item_resource.health_change)
	EventSystem.energy_change_requested.emit(consumable_item_resource.energy_change)
	EventSystem.equipped_item_used_up.emit()
	Audio.play_sfx(SFXConfig.Keys.Eat)


func destroy_self() -> void:
	EventSystem.item_unequipped.emit()
