extends Node

# Owns stable shop display stock even while the shop scene is unloaded.

var _display_stock: Dictionary = {}

func get_display_stock(display_id: String) -> Dictionary:
	var value: Variant = _display_stock.get(display_id, {})
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate()

func set_display_stock(display_id: String, item_id: String, quantity: int) -> void:
	if display_id == "":
		return
	if item_id == "" or quantity <= 0 or not ItemDatabase.has_item(item_id):
		_display_stock.erase(display_id)
		return
	_display_stock[display_id] = {
		"item_id": item_id,
		"quantity": quantity,
	}

func clear_display_stock(display_id: String) -> void:
	_display_stock.erase(display_id)

func clear() -> void:
	_display_stock.clear()

func get_save_data() -> Dictionary:
	return _display_stock.duplicate(true)

func load_from(data: Variant) -> void:
	_display_stock.clear()
	if typeof(data) != TYPE_DICTIONARY:
		return
	var source: Dictionary = data
	for id in source:
		var display_id := String(id)
		var value: Variant = source[id]
		if display_id == "" or typeof(value) != TYPE_DICTIONARY:
			continue
		var stock: Dictionary = value
		set_display_stock(display_id, String(stock.get("item_id", "")), int(stock.get("quantity", 0)))
