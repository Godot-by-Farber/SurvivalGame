extends TextureRect
class_name CraftButton
## A crafting menu entry. Hovering shows the item description and its crafting requirements.


@onready var icon_texture_rect: TextureRect = $MarginContainer/IconTextureRect
@onready var button: Button = $Button

var item_key: ItemConfig.Keys
var display_name := ""
var description := ""
var requirements := ""


func _ready() -> void:
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)


func set_item_key(new_item_key: ItemConfig.Keys) -> void:
	item_key = new_item_key
	update()


func update() -> void:
	var item_resource := ItemConfig.get_item_resource(item_key)
	icon_texture_rect.texture = item_resource.icon
	display_name = item_resource.display_name
	description = item_resource.description
	requirements = _build_requirements_text(ItemConfig.get_crafting_blueprint_resource(item_key))


func _build_requirements_text(blueprint: CraftingBlueprintResource) -> String:
	var lines: PackedStringArray = ["Requirements", ""]

	if blueprint.needs_multitool:
		lines.append("Multitool")
	if blueprint.needs_tinderbox:
		lines.append("Tinderbox")

	for cost in blueprint.costs:
		lines.append("%s: %d" % [ItemConfig.get_item_resource(cost.item_key).display_name, cost.amount])

	return "\n".join(lines)


func _on_mouse_entered() -> void:
	# Don't update the description while dragging.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	EventSystem.item_info_text_changed.emit(display_name + "\n\n" + description)
	EventSystem.extra_info_text_changed.emit(requirements)


func _on_mouse_exited() -> void:
	EventSystem.item_info_text_changed.emit("")
	EventSystem.extra_info_text_changed.emit("")
