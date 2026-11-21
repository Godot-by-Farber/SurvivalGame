extends RayCast3D
class_name InteractionRayCast
## Shows an interaction prompt for the Interactable under the crosshair and starts it on "interact".

var _is_hitting := false


func check_interaction() -> void:
	var interactable := get_collider() as Interactable if is_colliding() else null

	if interactable:
		if Input.is_action_just_pressed("interact"):
			interactable.start_interaction()

		if not _is_hitting:
			_is_hitting = true
			Bulletins.create(BulletinConfig.Keys.InteractionPrompt, interactable.prompt)

	elif _is_hitting:
		_is_hitting = false
		Bulletins.destroy(BulletinConfig.Keys.InteractionPrompt)
