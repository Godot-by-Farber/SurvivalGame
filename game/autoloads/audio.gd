extends Node
## Global audio service (autoload "Audio"): UI sounds, positional 3D sounds and music.

const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

var _music_player := AudioStreamPlayer.new()
var _sfx_player := AudioStreamPlayer.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.bus = MUSIC_BUS
	_sfx_player.bus = SFX_BUS
	add_child(_music_player)
	add_child(_sfx_player)


## Plays a non-positional sound effect, e.g. a UI click.
func play_sfx(key: SFXConfig.Keys) -> void:
	_sfx_player.stream = SFXConfig.get_audio_stream(key)
	_sfx_player.play()


## Plays a one-shot sound at a world position, with optional random pitch variation.
func play_sfx_at(key: SFXConfig.Keys, position: Vector3, pitch_randomness := 0.0) -> void:
	var player := AudioStreamPlayer3D.new()
	player.bus = SFX_BUS
	player.stream = SFXConfig.get_audio_stream(key)
	player.pitch_scale = 1.0 + randf_range(-pitch_randomness, pitch_randomness)
	add_child(player)
	player.global_position = position
	player.finished.connect(player.queue_free)
	player.play()


func play_music(key: MusicConfig.Keys) -> void:
	_music_player.stream = MusicConfig.get_audio_stream(key)
	_music_player.play()
