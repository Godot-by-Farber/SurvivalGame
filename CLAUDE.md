# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a 3D survival game built in Godot 4.7 following a course by Eerik Hirvonen. The game features resource gathering, crafting, construction, and survival mechanics on an island setting.

## Development Commands

Since this is a Godot project, development is primarily done through the Godot editor rather than command line tools. The project uses:

- **Engine**: Godot 4.7 (Forward Plus rendering)
- **Main Scene**: `res://game/main_game.tscn`
- **Project Config**: `project.godot` contains input maps and layer configurations

## Code Architecture

### Autoloads (`game/autoloads/`)
Game-wide services are autoload singletons called directly:
- `Audio` - `play_sfx()`, `play_sfx_at()`, `play_music()`
- `Settings` - settings resource, setters, `save()`
- `Fade` - `await fade_in()` / `await fade_out()` (scene autoload `fade.tscn`)
- `Bulletins` - `create(key, arg)`, `destroy(key)`, `destroy_all()`
- `Stages` - `change_stage(key)`; loads the stage on a background thread during the fade

### Event Bus (`game/autoloads/event_system.gd`)
`EventSystem` holds typed signals with named params, grouped by domain (Inventory, Player,
Equipment, World, HUD). `*_requested` signals are commands; past-tense signals are notifications.
Only cross-object gameplay events go here. Never add signals for the services above.
Some methods are called by name from scenes (signal connections, AnimationPlayer method tracks,
e.g. `check_hit`, `consume`, `destroy_self`, `try_to_construct`), so rename them in the `.tscn` files too.

### Core Systems

**Player System** (`actors/player/`)
- `Player` class handles movement, input, and basic interactions
- Uses `InteractionRayCast` for object interaction
- `ItemHolder` manages equipped items

**Inventory System** (`game/managers/inventory_manager.gd`)
- Fixed-size inventory (28 slots) and hotbar (9 slots)
- Uses `ItemConfig.Keys` enum for item identification
- Supports drag-and-drop between inventory and hotbar

**Item System** (`game/configs/item_config.gd`)
- Central configuration for all items using enum-based keys
- Separates pickuppable, equippable, craftable, and constructable items
- Maps item keys to their respective resource files and scenes

**Crafting System** (`resources/crafting_blueprints/`)
- Blueprint-based crafting with cost requirements
- Some items require tools (multitool, tinderbox)
- Managed through dedicated UI systems

**Interactable System** (`interactables/`)
- Base `Interactable` class for all interactive objects
- Includes pickuppables, hittable objects, and constructables
- Uses Area3D for interaction detection

### Manager Pattern
Per-run managers in `game/managers/` live in the Player and Island scenes:
- `InventoryManager` - Item storage and manipulation
- `EquippedItemManager` - Currently held items
- `PlayerStatsManager` - Health, energy tracking
- `SleepManager`, `Spawner`, `HUDController`, `DayNightCycleAnimationPlayer`

### UI System (`bulletins/`)
The game uses a "bulletin" system for UI management:
- The `Bulletins` autoload creates/destroys UI panels and sets each one's `bulletin_key`
- Player menus inherit from `PlayerMenuBase`
- Includes crafting, cooking, settings, and pause menus

### Physics Layers
Defined in `project.godot`:
1. ground
2. actor  
3. interactable
4. hitbox
5. big_rigid_pickuppable
6. small_rigid_pickuppable
7. static_body
8. water

## Third-Party Addons

**Proton Scatter** (`addons/proton_scatter/`, upstream main 7198cc0)
- Used for procedural placement of foliage and environmental objects
- Scatter nodes don't rebuild at runtime; a `ScatterCache` node per stage restores them from
  `stages/*/*_scatter_cache.res` (refreshed on scene save in the editor). Generating it needs a GPU:
  the Relax modifier falls back to an O(n²) CPU path in `--headless` mode
- Provides modifier-based scattering system
- Includes various creation and transformation modifiers

## Development Notes

- All items are defined in `ItemConfig.Keys` enum and mapped to resources
- Scene files use `.tscn` extension, scripts use `.gd`
- Audio files are in `audio/` with separate music and SFX folders
- 3D models and textures are in `meshes/` and `textures/`
- The game uses a day/night cycle system
- Player stats include energy consumption for movement
- Construction system allows building tents, campfires, and rafts