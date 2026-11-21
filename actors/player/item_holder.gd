extends Node3D
class_name ItemHolder
## Holds the currently equipped item in the player's hand.

var current_item: EquippableItem


func _enter_tree() -> void:
	EventSystem.item_equipped.connect(equip_item)
	EventSystem.item_unequipped.connect(unequip_item)


func equip_item(item_key: ItemConfig.Keys) -> void:
	unequip_item()
	var item := ItemConfig.get_equippable_item_scene(item_key).instantiate() as EquippableItem

	if item is EquippableWeapon:
		item.weapon_item_resource = ItemConfig.get_item_resource(item_key)
	elif item is EquippableConsumable:
		item.consumable_item_resource = ItemConfig.get_item_resource(item_key)
	elif item is EquippableConstructable:
		item.constructable_item_key = item_key

	add_child(item)
	current_item = item


func unequip_item() -> void:
	for child in get_children():
		child.queue_free()

	current_item = null


func try_to_use_item() -> void:
	if current_item:
		current_item.try_to_use()
