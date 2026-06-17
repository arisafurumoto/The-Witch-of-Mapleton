extends Node

# Autoload singleton. Loads crafting recipes from data/recipes.json and
# validates that referenced items exist in ItemDatabase.

const RECIPES_PATH := "res://data/recipes.json"
const REQUIRED_FIELDS := ["id", "name", "station", "ingredients", "output"]

var _recipes: Dictionary = {}

func _ready() -> void:
	_load_recipes()

func _load_recipes() -> void:
	_recipes.clear()
	if not FileAccess.file_exists(RECIPES_PATH):
		push_error("RecipeDatabase: file not found: " + RECIPES_PATH)
		return
	var text := FileAccess.get_file_as_string(RECIPES_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("RecipeDatabase: expected a JSON array in " + RECIPES_PATH)
		return
	for entry in parsed:
		_add_recipe(entry)
	print("RecipeDatabase: loaded ", _recipes.size(), " recipes")

func _add_recipe(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		push_warning("RecipeDatabase: skipping non-object entry")
		return
	for field in REQUIRED_FIELDS:
		if not entry.has(field):
			push_warning("RecipeDatabase: recipe missing field '%s': %s" % [field, str(entry)])
			return
	var id: String = entry["id"]
	if _recipes.has(id):
		push_warning("RecipeDatabase: duplicate recipe id '%s' ignored" % id)
		return
	# Validate ingredient items exist.
	for ingredient_id in entry["ingredients"]:
		if not ItemDatabase.has_item(ingredient_id):
			push_warning("RecipeDatabase: recipe '%s' uses unknown ingredient '%s'" % [id, ingredient_id])
			return
	# Validate output item exists.
	var output: Dictionary = entry["output"]
	var out_id := String(output.get("item_id", ""))
	if not ItemDatabase.has_item(out_id):
		push_warning("RecipeDatabase: recipe '%s' outputs unknown item '%s'" % [id, out_id])
		return
	_recipes[id] = entry

func has_recipe(id: String) -> bool:
	return _recipes.has(id)

func get_recipe(id: String) -> Dictionary:
	if not _recipes.has(id):
		push_warning("RecipeDatabase: unknown recipe id '%s'" % id)
		return {}
	return _recipes[id]

func get_recipes_for_station(station: String) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for id in _recipes:
		var recipe: Dictionary = _recipes[id]
		if String(recipe.get("station", "")) == station:
			results.append(recipe)
	return results

func find_matching_recipe(station: String, ingredients: Dictionary, preferred_ids: PackedStringArray = PackedStringArray()) -> Dictionary:
	for id in preferred_ids:
		var recipe_id := String(id)
		if not _recipes.has(recipe_id):
			continue
		var recipe: Dictionary = _recipes[recipe_id]
		if String(recipe.get("station", "")) == station and ingredients_match(recipe.get("ingredients", {}), ingredients):
			return recipe

	for recipe in get_recipes_for_station(station):
		var recipe_id := String(recipe.get("id", ""))
		if preferred_ids.has(recipe_id):
			continue
		if ingredients_match(recipe.get("ingredients", {}), ingredients):
			return recipe
	return {}

func ingredients_match(expected: Dictionary, actual: Dictionary) -> bool:
	if expected.size() != actual.size():
		return false
	for id in expected:
		var item_id := String(id)
		if int(expected[item_id]) != int(actual.get(item_id, 0)):
			return false
	return true

func get_all_ids() -> Array:
	return _recipes.keys()
