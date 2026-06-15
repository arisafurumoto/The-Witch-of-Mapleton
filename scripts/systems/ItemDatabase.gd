extends Node

# Autoload singleton. Loads item definitions from data/items.json and provides
# read-only lookups. Other systems (inventory, crafting, shop) ask this for
# display names, prices, etc. — item content is never hard-coded elsewhere.

const ITEMS_PATH := "res://data/items.json"
const REQUIRED_FIELDS := ["id", "name", "category", "description", "stack_limit", "sell_price"]

var _items: Dictionary = {}

func _ready() -> void:
	_load_items()

func _load_items() -> void:
	_items.clear()
	if not FileAccess.file_exists(ITEMS_PATH):
		push_error("ItemDatabase: file not found: " + ITEMS_PATH)
		return
	var text := FileAccess.get_file_as_string(ITEMS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("ItemDatabase: expected a JSON array in " + ITEMS_PATH)
		return
	for entry in parsed:
		_add_item(entry)
	print("ItemDatabase: loaded ", _items.size(), " items")

func _add_item(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		push_warning("ItemDatabase: skipping non-object entry")
		return
	for field in REQUIRED_FIELDS:
		if not entry.has(field):
			push_warning("ItemDatabase: item missing field '%s': %s" % [field, str(entry)])
			return
	var id: String = entry["id"]
	if _items.has(id):
		push_warning("ItemDatabase: duplicate item id '%s' ignored" % id)
		return
	if int(entry["stack_limit"]) <= 0:
		push_warning("ItemDatabase: item '%s' has stack_limit <= 0" % id)
		return
	if int(entry["sell_price"]) < 0:
		push_warning("ItemDatabase: item '%s' has negative sell_price" % id)
		return
	_items[id] = entry

func has_item(id: String) -> bool:
	return _items.has(id)

func get_item(id: String) -> Dictionary:
	if not _items.has(id):
		push_warning("ItemDatabase: unknown item id '%s'" % id)
		return {}
	return _items[id]

func get_item_name(id: String) -> String:
	return String(get_item(id).get("name", id))

func get_sell_price(id: String) -> int:
	return int(get_item(id).get("sell_price", 0))

func get_stack_limit(id: String) -> int:
	return int(get_item(id).get("stack_limit", 0))

func get_all_ids() -> Array:
	return _items.keys()
