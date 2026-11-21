extends CharacterBody3D
class_name Player


@export var normal_speed := 3.0
@export var sprint_speed := 5.0
@export var walking_energy_consumption_per_1m := -0.05
@export var jump_velocity := 4.0
@export var gravity := 0.2
@export var mouse_sensitivity := 0.005
@export var walking_footstep_audio_interval := 0.6
@export var sprinting_footstep_audio_interval := 0.3

@onready var head: Node3D = $Head
@onready var interaction_ray_cast: InteractionRayCast = %InteractionRayCast
@onready var item_holder: ItemHolder = %ItemHolder
@onready var footstep_audio_timer: Timer = $FootstepAudioTimer


var is_grounded := true
var is_sprinting := false


func _enter_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	EventSystem.player_freeze_requested.connect(set_freeze)


func _ready() -> void:
	EventSystem.hud_visibility_requested.emit(true)


func _exit_tree() -> void:
	EventSystem.hud_visibility_requested.emit(false)


func set_freeze(frozen: bool) -> void:
	set_process(not frozen)
	set_physics_process(not frozen)
	set_process_input(not frozen)


func _process(_delta: float) -> void:
	interaction_ray_cast.check_interaction()


func _physics_process(delta: float) -> void:
	move()
	check_walking_consumption(delta)
	
	if Input.is_action_just_pressed("use_equipped_item"):
		item_holder.try_to_use_item()


func move() -> void:
	if is_on_floor():
		is_sprinting = Input.is_action_pressed("sprint")
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		
		if velocity != Vector3.ZERO and footstep_audio_timer.is_stopped():
			Audio.play_sfx_at(SFXConfig.Keys.Footstep, global_position, 0.3)
			footstep_audio_timer.start(sprinting_footstep_audio_interval if is_sprinting else walking_footstep_audio_interval)
		
		if not is_grounded:
			is_grounded = true
			Audio.play_sfx_at(SFXConfig.Keys.JumpLand, global_position)
	
	else:
		velocity.y -= gravity
		is_grounded = false
	
	var speed := sprint_speed if is_sprinting else normal_speed
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.z = direction.z * speed
	velocity.x = direction.x * speed
	
	move_and_slide()


func check_walking_consumption(delta: float) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if horizontal_speed > 0:
		EventSystem.energy_change_requested.emit(delta * walking_energy_consumption_per_1m * horizontal_speed)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_around(event.relative)


func look_around(relative: Vector2) -> void:
	rotate_y(-relative.x * mouse_sensitivity)
	head.rotate_x(-relative.y * mouse_sensitivity)
	head.rotation.x = clampf(head.rotation.x, -PI/2, PI/2)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Bulletins.create(BulletinConfig.Keys.PauseMenu)
	
	elif event.is_action_pressed("open_crafting_menu"):
		Bulletins.create(BulletinConfig.Keys.CraftingMenu)
	
	elif event.is_action_pressed("item_hotkey"):
		EventSystem.hotkey_pressed.emit(int(event.as_text()))
