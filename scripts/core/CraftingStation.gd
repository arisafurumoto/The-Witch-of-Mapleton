extends "res://scripts/core/Interactable.gd"

# An interactable crafting station. Opens the compact cauldron ingredient UI.

@export var recipe_id: String = "calming_tea"
@export var recipe_ids: PackedStringArray = PackedStringArray()

func interact() -> void:
	interacted.emit()
	CauldronCraftingPanel.open("cauldron", _get_candidate_recipe_ids())

func _get_candidate_recipe_ids() -> PackedStringArray:
	var candidate_ids := PackedStringArray()
	if recipe_ids.size() > 0:
		for candidate_id in recipe_ids:
			candidate_ids.append(String(candidate_id))
	elif recipe_id != "":
		candidate_ids.append(recipe_id)
	return candidate_ids
