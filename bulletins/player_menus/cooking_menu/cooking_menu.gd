extends PlayerMenuBase
## Menu for a campfire: drop a raw ingredient in, cook it, take the cooked food out.
## Opened with the InteractableCooker as its argument.

@onready var starting_cooking_slot: StartingCookingSlot = %StartingCookingSlot
@onready var cooking_progress_bar: TextureProgressBar = %CookingProgressBar
@onready var final_cooking_slot: FinalCookingSlot = %FinalCookingSlot
@onready var cook_button: Button = %CookButton


var interactable_cooker: InteractableCooker
var cooking_recipe: CookingRecipeResource
var time_cooked := 0.0


func initialize(arg: Variant) -> void:
	interactable_cooker = arg as InteractableCooker
	if interactable_cooker:
		cooking_recipe = interactable_cooker.cooking_recipe
		time_cooked = interactable_cooker.get_time_cooked()


func _ready() -> void:
	starting_cooking_slot.starting_ingredient_enabled.connect(_on_uncooked_item_added)
	starting_cooking_slot.starting_ingredient_disabled.connect(_on_uncooked_item_removed)
	final_cooking_slot.cooked_food_taken.connect(interactable_cooker.cooked_item_removed)

	match interactable_cooker.state:
		InteractableCooker.CookingStates.ReadyToCook:
			starting_cooking_slot.set_item_key(cooking_recipe.uncooked_item)
			cook_button.disabled = false
		InteractableCooker.CookingStates.Cooking:
			starting_cooking_slot.set_item_key(cooking_recipe.uncooked_item)
			start_cooking()
		InteractableCooker.CookingStates.Cooked:
			final_cooking_slot.set_item_key(cooking_recipe.cooked_item)

	super()


func start_cooking() -> void:
	starting_cooking_slot.cooking_in_progress = true
	cook_button.disabled = true
	cooking_progress_bar.value = time_cooked / cooking_recipe.cooking_time * cooking_progress_bar.max_value

	var tween := create_tween()
	tween.tween_property(
		cooking_progress_bar,
		"value",
		cooking_progress_bar.max_value,
		cooking_recipe.cooking_time - time_cooked
	)
	tween.tween_callback(_on_cooking_finished)

	if interactable_cooker.state != InteractableCooker.CookingStates.Cooking:
		interactable_cooker.start_cooking()
		Audio.play_sfx(SFXConfig.Keys.UIClick)


func _on_uncooked_item_added() -> void:
	cook_button.disabled = false
	cooking_recipe = ItemConfig.get_item_resource(starting_cooking_slot.item_key).cooking_recipe
	time_cooked = 0
	interactable_cooker.uncooked_item_added(cooking_recipe)


func _on_uncooked_item_removed() -> void:
	cook_button.disabled = true
	cooking_recipe = null
	time_cooked = 0
	interactable_cooker.uncooked_item_removed()


func _on_cooking_finished() -> void:
	final_cooking_slot.set_item_key(cooking_recipe.cooked_item)
	starting_cooking_slot.set_item_key(null)
	cooking_progress_bar.value = 0
	starting_cooking_slot.cooking_in_progress = false
