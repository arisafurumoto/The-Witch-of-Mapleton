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
	print("QuestDatabase: loaded ", _quests.size(), " quests")

func _add_quest(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		push_warning("QuestDatabase: skipping non-object entry")
		return
	for field in REQUIRED_FIELDS:
		if not entry.has(field):
			push_warning("QuestDatabase: quest missing field '%s': %s" % [field, str(entry)])
			return
	var id: String = entry["id"]
	if _quests.has(id):
		push_warning("QuestDatabase: duplicate quest id '%s' ignored" % id)
		return
	if not ItemDatabase.has_item(String(entry["turn_in_item_id"])):
		push_warning("QuestDatabase: quest '%s' turns in unknown item '%s'" % [id, entry["turn_in_item_id"]])
		return
	var reward_items: Dictionary = entry["reward_items"]
	for item_id in reward_items:
		if not ItemDatabase.has_item(String(item_id)):
			push_warning("QuestDatabase: quest '%s' rewards unknown item '%s'" % [id, item_id])
			return
	_quests[id] = entry

func has_quest(id: String) -> bool:
	return _quests.has(id)

func get_quest(id: String) -> Dictionary:
	if not _quests.has(id):
		push_warning("QuestDatabase: unknown quest id '%s'" % id)
		return {}
	return _quests[id]

func get_all_ids() -> Array:
	return _quests.keys()
