class_name BulletinConfig


enum Keys {
	InteractionPrompt,
	CraftingMenu,
	CookingMenu,
	PauseMenu,
	SettingsMenu,
}

const BULLETIN_PATHS: Dictionary[Keys, String] = {
	Keys.InteractionPrompt: "res://bulletins/interaction_prompt/interaction_prompt.tscn",
	Keys.CraftingMenu: "res://bulletins/player_menus/crafting_menu/crafting_menu.tscn",
	Keys.CookingMenu: "res://bulletins/player_menus/cooking_menu/cooking_menu.tscn",
	Keys.PauseMenu: "res://bulletins/pause_menu/pause_menu.tscn",
	Keys.SettingsMenu: "res://bulletins/settings_menu/settings_menu.tscn",
}


static func get_bulletin(key: Keys) -> Bulletin:
	return (load(BULLETIN_PATHS[key]) as PackedScene).instantiate() as Bulletin
