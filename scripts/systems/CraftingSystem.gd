extends Node

# Autoload singleton. Turns a recipe's ingredients into its output using the
# Inventory. Validates first, so a failed craft never consumes ingredients.

signal crafting_completed(item_id: String, quantity: int)

func can_craft(recipe_id: String) -> bool:
	var recipe := RecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	return Inventory.has_ingredients(recipe.get("ingredients", {}))

func craft(recipe_id: String) -> bool:
	var recipe := RecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	var ingredients: Dictionary = recipe.get("ingredients", {})
	if not Inventory.has_ingredients(ingredients):
		return false
	for ingredient_id in ingredients:
		Inventory.remove_item(ingredient_id, int(ingredients[ingredient_id]))
	var output: Dictionary = recipe.get("output", {})
	var out_id := String(output.get("item_id", ""))
	var out_qty := int(output.get("quantity", 1))
	if out_id == "":
		push_warning("CraftingSystem: recipe '%s' has no output item" % recipe_id)
		return false
	Inventory.add_item(out_id, out_qty)
	crafting_completed.emit(out_id, out_qty)
	print("Crafted %dx %s" % [out_qty, out_id])
	return true
