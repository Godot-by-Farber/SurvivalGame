extends Node
class_name Stage
## Base class for stages (main menu, island, credits).
##
## A stage is "loaded" once all its scatter nodes have placed their objects, either
## restored from a ProtonScatterCache node or rebuilt from scratch. Stages waits for
## [signal loading_complete] before fading the screen back in.

signal loading_complete

@export var show_mouse := false
@export var music_to_play := MusicConfig.Keys.MainMenuSong
@export var scatter_nodes: Array[Node3D] = []
## Optional ProtonScatterCache node. When its cache file is missing, the scatter nodes are rebuilt.
@export var scatter_cache: Node

var is_loaded := false

var _pending_scatter_nodes := 0


func _ready() -> void:
	Audio.play_music(music_to_play)

	_pending_scatter_nodes = scatter_nodes.size()
	for scatter_node in scatter_nodes:
		scatter_node.connect(&"build_completed", _on_scatter_node_built, CONNECT_ONE_SHOT)

	if _pending_scatter_nodes == 0:
		_finish_loading()
		return

	if scatter_cache:
		var cache_file: String = scatter_cache.get(&"cache_file")
		if not ResourceLoader.exists(cache_file):
			push_warning("Scatter cache %s is missing, rebuilding scatter nodes." % cache_file)
			for scatter_node in scatter_nodes:
				if not scatter_node.get(&"force_rebuild_on_load"): # those rebuild on their own
					scatter_node.call_deferred(&"full_rebuild")


func _on_scatter_node_built() -> void:
	_pending_scatter_nodes -= 1
	if _pending_scatter_nodes == 0:
		_finish_loading()


func _finish_loading() -> void:
	is_loaded = true
	if show_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	loading_complete.emit()
