extends Node

# Autoload singleton. Loads customer shop requests from data/shop_requests.json.
# Each request holds the wanted item, payment, and inline dialogue lines.

const REQUESTS_PATH := "res://data/shop_requests.json"
const REQUIRED_FIELDS := ["id", "requested_item_id", "quantity", "offered_gold"]

var _requests: Dictionary = {}

func _ready() -> void:
	_load_requests()

func _load_requests() -> void:
	_requests.clear()
	if not FileAccess.file_exists(REQUESTS_PATH):
		push_error("ShopRequestDatabase: file not found: " + REQUESTS_PATH)
		return
	var text := FileAccess.get_file_as_string(REQUESTS_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("ShopRequestDatabase: expected a JSON array in " + REQUESTS_PATH)
		return
	for entry in parsed:
		_add_request(entry)
	print("ShopRequestDatabase: loaded ", _requests.size(), " requests")

func _add_request(entry: Variant) -> void:
	if typeof(entry) != TYPE_DICTIONARY:
		push_warning("ShopRequestDatabase: skipping non-object entry")
		return
	for field in REQUIRED_FIELDS:
		if not entry.has(field):
			push_warning("ShopRequestDatabase: request missing field '%s': %s" % [field, str(entry)])
			return
	var id: String = entry["id"]
	if _requests.has(id):
		push_warning("ShopRequestDatabase: duplicate request id '%s' ignored" % id)
		return
	if not ItemDatabase.has_item(entry["requested_item_id"]):
		push_warning("ShopRequestDatabase: request '%s' wants unknown item '%s'" % [id, entry["requested_item_id"]])
		return
	_requests[id] = entry

func has_request(id: String) -> bool:
	return _requests.has(id)

func get_request(id: String) -> Dictionary:
	if not _requests.has(id):
		push_warning("ShopRequestDatabase: unknown request id '%s'" % id)
		return {}
	return _requests[id]
