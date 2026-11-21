extends Area3D
class_name Hitbox


## Forwarded to the owning object, which applies the damage.
signal register_hit(weapon_item_resource: WeaponItemResource)


@export var hit_audio_key := SFXConfig.Keys.TreeHit
@export var hit_particles_key := VFXConfig.Keys.HitParticlesWood


func take_hit(weapon_item_resource: WeaponItemResource) -> void:
	register_hit.emit(weapon_item_resource)
	Audio.play_sfx_at(hit_audio_key, global_position)
