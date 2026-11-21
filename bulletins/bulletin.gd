extends Control
class_name Bulletin
## Base class for UI panels managed by the Bulletins autoload.

## The key this bulletin was opened with (set by Bulletins.create), so it can close itself.
var bulletin_key: BulletinConfig.Keys


## Receives the optional argument given to [method Bulletins.create], before entering the tree.
func initialize(_arg: Variant) -> void:
	pass

