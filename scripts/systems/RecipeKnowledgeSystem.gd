extends Node

# Tracks recipes learned through progression. Default-known recipes come from data.

signal recipe_unlocked(recipe_id: String)

var _unlocked_recipes: Dictionary = {}

func is_recipe_known(recipe_id: String) -> bool:
	if not RecipeDatabase.has_recipe(recipe_id):
		return false
	var recipe := RecipeDatabase.get_recipe(recipe_id)
	return bool(recipe.get("known_by_default", false)) or _unlocked_recipes.has(recipe_id)

func unlock_recipe(recipe_id: String, notify: bool = true) -> bool:
	if not RecipeDatabase.has_recipe(recipe_id):
		return false
	var recipe := RecipeDatabase.get_recipe(recipe_id)
	if bool(recipe.get("known_by_default", false)) or _unlocked_recipes.has(recipe_id):
		return false
	_unlocked_recipes[recipe_id] = true
	if notify:
		recipe_unlocked.emit(recipe_id)
	return true

func get_save_data() -> Array[String]:
	var recipe_ids: Array[String] = []
	for recipe_id in _unlocked_recipes:
		recipe_ids.append(String(recipe_id))
	recipe_ids.sort()
	return recipe_ids

func load_from(data: Variant) -> void:
	_unlocked_recipes.clear()
	if typeof(data) != TYPE_ARRAY:
		return
	for value in data:
		unlock_recipe(String(value), false)
