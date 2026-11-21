class_name StageConfig


enum Keys {
	Island,
	MainMenu,
	Credits,
}

const STAGE_PATHS: Dictionary[Keys, String] = {
	Keys.Island: "res://stages/island/island.tscn",
	Keys.MainMenu: "res://stages/main_menu/main_menu.tscn",
	Keys.Credits: "res://stages/credits/credits_stage.tscn",
}


static func get_stage_path(key: Keys) -> String:
	return STAGE_PATHS[key]
