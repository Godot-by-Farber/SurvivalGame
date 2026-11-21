extends Node
## Global event bus for gameplay events that cross object boundaries.
##
## Naming convention:
## - "*_requested" signals ask a listener to do something (a command).
## - Past-tense signals report that something happened (a notification).
##
## Game-wide services are not reached through this bus. Call their autoloads
## directly instead: Audio, Settings, Bulletins, Fade and Stages.
##
## Inventory and hotbar arrays hold ItemConfig.Keys values, or null for empty slots.


# --- Inventory ---

## Asks the inventory to take an item; [param on_picked_up] runs only if there was room.
signal pickup_requested(item_key: ItemConfig.Keys, on_picked_up: Callable)
## Asks the inventory to re-broadcast [signal inventory_updated] (e.g. when a menu opens).
signal inventory_refresh_requested
signal inventory_updated(inventory: Array)
signal hotbar_updated(hotbar: Array)
## Swaps the contents of two slots, each in either the inventory or the hotbar.
signal slot_swap_requested(from_index: int, from_hotbar: bool, to_index: int, to_hotbar: bool)
## Puts [param item_key] into the first free inventory slot.
signal item_add_requested(item_key: ItemConfig.Keys)
signal blueprint_costs_removal_requested(costs: Array[CraftingBlueprintCostDataResource])
signal slot_clear_requested(index: int, is_hotbar: bool)
signal slot_fill_requested(item_key: ItemConfig.Keys, index: int, is_hotbar: bool)
## Text for the item description label in player menus ("" clears it).
signal item_info_text_changed(text: String)
## Text for the secondary label in player menus, e.g. crafting requirements.
signal extra_info_text_changed(text: String)


# --- Player ---

signal player_freeze_requested(frozen: bool)
signal energy_change_requested(amount: float)
signal energy_updated(max_energy: float, energy: float)
signal health_change_requested(amount: float)
signal health_updated(max_health: float, health: float)
signal sleep_requested


# --- Equipment ---

## [param slot_number] is the 1-based number key that was pressed.
signal hotkey_pressed(slot_number: int)
signal item_equipped(item_key: ItemConfig.Keys)
signal item_unequipped
## The equipped item was consumed or placed and must be removed from the hotbar.
signal equipped_item_used_up
## [param index] is the active hotbar slot, or -1 when nothing is equipped.
signal active_hotbar_slot_changed(index: int)


# --- World ---

signal scene_spawn_requested(scene: PackedScene, xform: Transform3D, is_constructable: bool)
signal vfx_spawn_requested(scene: PackedScene, xform: Transform3D)
## Advances the day/night cycle by [param hours].
signal time_skip_requested(hours: float)
signal navmesh_rebake_requested


# --- HUD ---

signal hud_visibility_requested(visible: bool)
