extends "res://scripts/core/Interactable.gd"

# An interactable crafting station. For now, it either crafts one authored
# recipe or picks the first available recipe from a tiny ordered list.

@export var recipe_id: String = "calming_tea"
@export var recipe_ids: PackedStringArray = PackedStringArray()

var _message_token: int = 0

func interact() -> void:
	interacted.emit()
	var selected_recipe_id := _select_recipe_id()
	if selected_recipe_id == "":
		_flash_message("No recipe")
		return
	var recipe := RecipeDatabase.get_recipe(selected_recipe_id)
	if recipe.is_empty():
		_flash_message("No recipe")
		return
	if CraftingSystem.craft(selected_recipe_id):
		var out_id := String(recipe["output"]["item_id"])
		AudioSystem.play_craft()
		_flash_message("Made " + ItemDatabase.get_item_name(out_id))
	else:
		_flash_message("Need ingredients")

func _select_recipe_id() -> String:
	var fallback_recipe_id := ""
	for candidate_id in _get_candidate_recipe_ids():
		var recipe := RecipeDatabase.get_recipe(candidate_id)
		if recipe.is_empty() or not _is_recipe_available(recipe):
			continue
		if fallback_recipe_id == "":
			fallback_recipe_id = candidate_id
		if CraftingSystem.can_craft(candidate_id):
			return candidate_id
	return fallback_recipe_id

func _get_candidate_recipe_ids() -> Array[String]:
	var candidate_ids: Array[String] = []
	if recipe_ids.size() > 0:
		for candidate_id in recipe_ids:
			candidate_ids.append(String(candidate_id))
	elif recipe_id != "":
		candidate_ids.append(recipe_id)
	return candidate_ids

func _is_recipe_available(recipe: Dictionary) -> bool:
	var quest_id := String(recipe.get("quest_id", ""))
	if quest_id == "":
		return true
	var state := QuestSystem.get_quest_state(quest_id)
	if state == QuestSystem.STATE_NOT_STARTED or state == QuestSystem.STATE_COMPLETED:
		return false
	var output: Dictionary = recipe.get("output", {})
	var out_id := String(output.get("item_id", ""))
	var out_qty := int(output.get("quantity", 1))
	return out_id == "" or not Inventory.has_item(out_id, out_qty)

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
