extends "res://scripts/core/Interactable.gd"

# An interactable crafting station (the cauldron). Tries to craft its recipe and
# shows a short result message on its prompt label.

@export var recipe_id: String = "calming_tea"

var _message_token: int = 0

func interact() -> void:
	interacted.emit()
	var recipe := RecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		_flash_message("No recipe")
		return
	if CraftingSystem.craft(recipe_id):
		var out_id := String(recipe["output"]["item_id"])
		_flash_message("Made " + ItemDatabase.get_item_name(out_id))
	else:
		_flash_message("Need ingredients")

func _flash_message(text: String) -> void:
	if _label == null:
		return
	_message_token += 1
	var token := _message_token
	_label.text = text
	await get_tree().create_timer(1.2).timeout
	# Only restore if no newer message replaced this one.
	if is_instance_valid(_label) and token == _message_token:
		_label.text = prompt
