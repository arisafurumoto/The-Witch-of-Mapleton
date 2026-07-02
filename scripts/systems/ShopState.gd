extends Node

# Owns stable shop state even while the shop scene is unloaded.

var _display_stock: Dictionary = {}
var _arrived_visitors: Dictionary = {}

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

func has_visitor_arrived(visitor_id: String) -> bool:
	if visitor_id == "":
		return false
	return bool(_arrived_visitors.get(visitor_id, false))

func set_visitor_arrived(visitor_id: String, value: bool = true) -> void:
	if visitor_id == "":
		return
	if value:
		_arrived_visitors[visitor_id] = true
	else:
		_arrived_visitors.erase(visitor_id)

func clear_visitor_arrival(visitor_id: String) -> void:
	_arrived_visitors.erase(visitor_id)

func clear() -> void:
	_display_stock.clear()
	_arrived_visitors.clear()

func get_save_data() -> Dictionary:
	return _display_stock.duplicate(true)

func load_from(data: Variant) -> void:
	_display_stock.clear()
	_arrived_visitors.clear()
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
