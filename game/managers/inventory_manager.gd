extends Node
class_name InventoryManager
## Owns the player's inventory and hotbar contents.
## Slots hold an ItemConfig.Keys value, or null when empty.

const INVENTORY_SIZE := 28
const HOTBAR_SIZE := 9

var inventory: Array = []
var hotbar: Array = []


func _enter_tree() -> void:
	EventSystem.pickup_requested.connect(_on_pickup_requested)
	EventSystem.inventory_refresh_requested.connect(_emit_inventory)
	EventSystem.slot_swap_requested.connect(_on_slot_swap_requested)
	EventSystem.item_add_requested.connect(add_item)
	EventSystem.blueprint_costs_removal_requested.connect(_on_blueprint_costs_removal_requested)
	EventSystem.slot_clear_requested.connect(_on_slot_clear_requested)
	EventSystem.slot_fill_requested.connect(_on_slot_fill_requested)


func _ready() -> void:
	inventory.resize(INVENTORY_SIZE)
	hotbar.resize(HOTBAR_SIZE)


func get_free_slot_count() -> int:
	return inventory.count(null)


func add_item(item_key: ItemConfig.Keys) -> void:
	var free_index := inventory.find(null)
	if free_index != -1:
		inventory[free_index] = item_key
	_emit_inventory()


func remove_item(item_key: ItemConfig.Keys) -> void:
	var index := inventory.rfind(item_key)
	if index != -1:
		inventory[index] = null


func _emit_inventory() -> void:
	EventSystem.inventory_updated.emit(inventory)


func _emit_hotbar() -> void:
	EventSystem.hotbar_updated.emit(hotbar)


func _emit_slots(is_hotbar: bool) -> void:
	if is_hotbar:
		_emit_hotbar()
	else:
		_emit_inventory()


func _slots(is_hotbar: bool) -> Array:
	return hotbar if is_hotbar else inventory


func _on_pickup_requested(item_key: ItemConfig.Keys, on_picked_up: Callable) -> void:
	if get_free_slot_count() == 0:
		return

	add_item(item_key)
	on_picked_up.call()


func _on_slot_swap_requested(from_index: int, from_hotbar: bool, to_index: int, to_hotbar: bool) -> void:
	var from_slots := _slots(from_hotbar)
	var to_slots := _slots(to_hotbar)
	var moved_item: Variant = from_slots[from_index]
	from_slots[from_index] = to_slots[to_index]
	to_slots[to_index] = moved_item

	_emit_inventory()
	_emit_hotbar()


func _on_blueprint_costs_removal_requested(costs: Array[CraftingBlueprintCostDataResource]) -> void:
	for cost in costs:
		for i in cost.amount:
			remove_item(cost.item_key)


func _on_slot_clear_requested(index: int, is_hotbar: bool) -> void:
	_slots(is_hotbar)[index] = null
	_emit_slots(is_hotbar)


func _on_slot_fill_requested(item_key: ItemConfig.Keys, index: int, is_hotbar: bool) -> void:
	_slots(is_hotbar)[index] = item_key
	_emit_slots(is_hotbar)
