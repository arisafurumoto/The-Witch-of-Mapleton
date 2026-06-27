extends Node

# Autoload singleton. Loads tiny quest definitions from data/quests.json.
# This keeps quest text, turn-in items, and rewards out of NPC scripts.

const QUESTS_PATH := "res://data/quests.json"
const REQUIRED_FIELDS := ["id", "title", "npc_name", "turn_in_item_id", "turn_in_quantity", "reward_gold", "reward_items"]

var _quests: Dictionary = {}

func _ready() -> void:
	_load_quests()

func _load_quests() -> void:
	_quests.clear()
	if not FileAccess.file_exists(QUESTS_PATH):
		push_error("QuestDatabase: file not found: " + QUESTS_PATH)
		return
	var text := FileAccess.get_file_as_string(QUESTS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("QuestDatabase: expected a JSON array in " + QUESTS_PATH)
		return
	for entry in parsed:
		_add_quest(entry)
	_validate_required_quests()
	print("QuestDatabase: loaded ", _quests.size(), " quests")

func _add_quest(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		push_warning("QuestDatabase: skipping non-object entry")
		return
	for field in REQUIRED_FIELDS:
		if not entry.has(field):
			push_warning("QuestDatabase: quest missing field '%s': %s" % [field, str(entry)])
			return
	var id: String = String(entry["id"])
	if _quests.has(id):
		push_warning("QuestDatabase: duplicate quest id '%s' ignored" % id)
		return
	var required_quests: Variant = entry.get("required_quests", [])
	if typeof(required_quests) != TYPE_ARRAY:
		push_warning("QuestDatabase: quest '%s' required_quests must be an array" % id)
		return
	for required_quest_id in required_quests:
		if String(required_quest_id) == "":
			push_warning("QuestDatabase: quest '%s' has an empty required_quests entry" % id)
			return
	if int(entry.get("minimum_day", 1)) < 1:
		push_warning("QuestDatabase: quest '%s' minimum_day must be 1 or higher" % id)
		return
	if not ItemDatabase.has_item(String(entry["turn_in_item_id"])):
		push_warning("QuestDatabase: quest '%s' turns in unknown item '%s'" % [id, entry["turn_in_item_id"]])
		return
	var reward_items: Dictionary = entry["reward_items"]
	for item_id in reward_items:
		if not ItemDatabase.has_item(String(item_id)):
			push_warning("QuestDatabase: quest '%s' rewards unknown item '%s'" % [id, item_id])
			return
	var reward_recipes: Variant = entry.get("reward_recipes", [])
	if typeof(reward_recipes) != TYPE_ARRAY:
		push_warning("QuestDatabase: quest '%s' reward_recipes must be an array" % id)
		return
	for recipe_id in reward_recipes:
		if not RecipeDatabase.has_recipe(String(recipe_id)):
			push_warning("QuestDatabase: quest '%s' rewards unknown recipe '%s'" % [id, recipe_id])
			return
	_quests[id] = entry

func _validate_required_quests() -> void:
	for quest_id in _quests:
		var id := String(quest_id)
		for required_quest_id in get_required_quest_ids(id):
			if not _quests.has(required_quest_id):
				push_warning("QuestDatabase: quest '%s' requires unknown quest '%s'" % [id, required_quest_id])

func has_quest(id: String) -> bool:
	return _quests.has(id)

func get_quest(id: String) -> Dictionary:
	if not _quests.has(id):
		push_warning("QuestDatabase: unknown quest id '%s'" % id)
		return {}
	return _quests[id]

func get_required_quest_ids(id: String) -> Array[String]:
	var required_ids: Array[String] = []
	if not _quests.has(id):
		return required_ids
	var quest: Dictionary = _quests[id]
	for required_quest_id in quest.get("required_quests", []):
		required_ids.append(String(required_quest_id))
	return required_ids

func get_minimum_day(id: String) -> int:
	if not _quests.has(id):
		return 1
	var quest: Dictionary = _quests[id]
	return maxi(1, int(quest.get("minimum_day", 1)))

func get_all_ids() -> Array:
	return _quests.keys()
