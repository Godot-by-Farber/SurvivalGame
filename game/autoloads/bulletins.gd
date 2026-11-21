extends CanvasLayer
## Global UI panel service (autoload "Bulletins"): opens and closes bulletins
## (menus, prompts), keeping at most one instance per BulletinConfig key.

const LAYER := 2 # above the HUD

var _open: Dictionary[BulletinConfig.Keys, Bulletin] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = LAYER


## Opens the bulletin for [param key] unless it is already open.
## [param arg] is passed to [method Bulletin.initialize] before the bulletin enters the tree.
func create(key: BulletinConfig.Keys, arg: Variant = null) -> void:
	if _open.has(key):
		return

	var bulletin := BulletinConfig.get_bulletin(key)
	bulletin.bulletin_key = key
	bulletin.initialize(arg)
	add_child(bulletin)
	_open[key] = bulletin


func destroy(key: BulletinConfig.Keys) -> void:
	if _open.has(key):
		_open[key].queue_free()
		_open.erase(key)


func destroy_all() -> void:
	for bulletin in _open.values():
		bulletin.queue_free()
	_open.clear()


func is_open(key: BulletinConfig.Keys) -> bool:
	return _open.has(key)
