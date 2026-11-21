extends Node3D
class_name Spawner
## Spawns world objects (drops, constructables) and short-lived VFX on request.

const VFX_LIFETIME := 2.0

@export var constructable_holder: Node3D

@onready var object_holder: Node3D = $ObjectHolder


func _enter_tree() -> void:
	EventSystem.scene_spawn_requested.connect(_on_scene_spawn_requested)
	EventSystem.vfx_spawn_requested.connect(_on_vfx_spawn_requested)


func _on_scene_spawn_requested(scene: PackedScene, xform: Transform3D, is_constructable: bool) -> void:
	var object := scene.instantiate() as Node3D
	object.transform = xform # holders sit at the origin, so local == global

	if is_constructable:
		constructable_holder.add_child(object)
		EventSystem.navmesh_rebake_requested.emit()
	else:
		object_holder.add_child(object)


func _on_vfx_spawn_requested(scene: PackedScene, xform: Transform3D) -> void:
	var vfx := scene.instantiate() as Node3D
	vfx.transform = xform # the spawner sits at the origin
	add_child(vfx)

	if vfx is GPUParticles3D:
		vfx.emitting = true

	get_tree().create_timer(VFX_LIFETIME, false).timeout.connect(vfx.queue_free)
