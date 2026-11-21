extends TextureRect
class_name InventorySlot
## A drag-and-drop slot showing one item. Subclasses: HotbarSlot and the cooking slots.

const DRAG_PREVIEW_SIZE := Vector2(80, 80)

@onready var icon_texture_rect: TextureRect = $MarginContainer/IconTextureRect

## ItemConfig.Keys value, or null when the slot is empty (so it can't be statically typed).
var item_key: Variant = null
var display_name := ""
var description := ""


func _enter_tree() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	# Don't update the description while dragging.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return

	if item_key != null:
		EventSystem.item_info_text_changed.emit(display_name + "\n\n" + description)
	else:
		EventSystem.item_info_text_changed.emit("")


func _on_mouse_exited() -> void:
	EventSystem.item_info_text_changed.emit("")


## [param new_item_key] is an ItemConfig.Keys value, or null to clear the slot.
func set_item_key(new_item_key: Variant) -> void:
	item_key = new_item_key
	update()


func update() -> void:
	if item_key == null:
		icon_texture_rect.texture = null
		display_name = ""
		description = ""
		return

	var item_resource := ItemConfig.get_item_resource(item_key)
	icon_texture_rect.texture = item_resource.icon
	display_name = item_resource.display_name
	description = item_resource.description


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_key == null:
		return null # nothing to drag

	var texture_rect := TextureRect.new()
	texture_rect.modulate = Color(1, 1, 1, 0.75)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.texture = icon_texture_rect.texture
	texture_rect.custom_minimum_size = DRAG_PREVIEW_SIZE
	# Center the icon under the mouse pointer.
	texture_rect.position = -0.5 * DRAG_PREVIEW_SIZE
	var drag_preview := Control.new()
	drag_preview.add_child(texture_rect)
	set_drag_preview(drag_preview)

	Audio.play_sfx(SFXConfig.Keys.UIClick)
	return self # the dragged data is the source slot


func _can_drop_data(_at_position: Vector2, slot: Variant) -> bool:
	# An occupied slot swaps its item with the dragged one,
	# so the item must also fit where the dragged one came from.
	if item_key != null:
		if slot is HotbarSlot:
			return ItemConfig.get_item_resource(item_key).is_equippable

		if slot is StartingCookingSlot:
			return ItemConfig.get_item_resource(item_key).cooking_recipe != null

		if slot is FinalCookingSlot:
			return false

	return slot is InventorySlot


func _drop_data(_at_position: Vector2, source_slot: Variant) -> void:
	var is_hotbar := self is HotbarSlot

	if source_slot is StartingCookingSlot:
		var own_item_key: Variant = item_key
		EventSystem.slot_fill_requested.emit(source_slot.item_key, get_index(), is_hotbar)
		source_slot.set_item_key(own_item_key)
		source_slot.starting_ingredient_disabled.emit()

	elif source_slot is FinalCookingSlot:
		EventSystem.slot_fill_requested.emit(source_slot.item_key, get_index(), is_hotbar)
		source_slot.set_item_key(null)
		source_slot.cooked_food_taken.emit()

	else:
		EventSystem.slot_swap_requested.emit(
			source_slot.get_index(),
			source_slot is HotbarSlot,
			get_index(),
			is_hotbar
		)

	Audio.play_sfx(SFXConfig.Keys.UIClick)
