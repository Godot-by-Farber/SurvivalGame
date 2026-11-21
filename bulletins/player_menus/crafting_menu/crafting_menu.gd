extends PlayerMenuBase
class_name CraftingMenu


@export var craft_button_scene: PackedScene

@onready var craft_button_container: GridContainer = %CraftButtonContainer


func _ready() -> void:
	for item_key in ItemConfig.CRAFTABLE_ITEM_KEYS:
		var craft_button := craft_button_scene.instantiate() as CraftButton
		craft_button_container.add_child(craft_button)
		craft_button.set_item_key(item_key)
		craft_button.button.pressed.connect(_on_craft_button_pressed.bind(item_key))

	super()


func update_inventory(inventory: Array) -> void:
	super(inventory)
	_update_craft_buttons(inventory)


func _update_craft_buttons(inventory: Array) -> void:
	for craft_button: CraftButton in craft_button_container.get_children():
		var blueprint := ItemConfig.get_crafting_blueprint_resource(craft_button.item_key)
		craft_button.button.disabled = not _can_craft(blueprint, inventory)


func _can_craft(blueprint: CraftingBlueprintResource, inventory: Array) -> bool:
	if blueprint.needs_multitool and not ItemConfig.Keys.Multitool in inventory:
		return false

	if blueprint.needs_tinderbox and not ItemConfig.Keys.Tinderbox in inventory:
		return false

	for cost in blueprint.costs:
		if inventory.count(cost.item_key) < cost.amount:
			return false

	return true


func _on_craft_button_pressed(item_key: ItemConfig.Keys) -> void:
	EventSystem.blueprint_costs_removal_requested.emit(ItemConfig.get_crafting_blueprint_resource(item_key).costs)
	EventSystem.item_add_requested.emit(item_key)
	Audio.play_sfx(SFXConfig.Keys.Craft)
