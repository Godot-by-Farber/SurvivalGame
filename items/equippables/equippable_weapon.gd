extends EquippableItem
class_name EquippableWeapon

const HITBOX_LAYER_MASK := 8 # physics layer 4: hitbox


@onready var hit_check_marker: Marker3D = $HitCheckMarker

var weapon_item_resource: WeaponItemResource


func _ready() -> void:
	hit_check_marker.position.z = -weapon_item_resource.range
	super()


func consume_energy() -> void:
	EventSystem.energy_change_requested.emit(weapon_item_resource.energy_change_per_use)


func check_hit() -> void:
	var space_state := get_world_3d().direct_space_state
	var ray_query_params := PhysicsRayQueryParameters3D.new()
	ray_query_params.collide_with_areas = true
	ray_query_params.collide_with_bodies = false
	ray_query_params.collision_mask = HITBOX_LAYER_MASK
	ray_query_params.from = global_position
	ray_query_params.to = hit_check_marker.global_position
	
	var result := space_state.intersect_ray(ray_query_params)
	
	if result.is_empty():
		return

	var hitbox := result.collider as Hitbox
	if hitbox == null:
		return

	hitbox.take_hit(weapon_item_resource)
	EventSystem.vfx_spawn_requested.emit(
		VFXConfig.get_vfx(hitbox.hit_particles_key),
		Transform3D(Basis(), result.position)
	)


func play_swoosh_audio() -> void:
	Audio.play_sfx(SFXConfig.Keys.WeaponSwoosh)
