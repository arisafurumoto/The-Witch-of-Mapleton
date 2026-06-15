extends Node

# Autoload singleton. Runtime inventory keyed by item id -> quantity.
# Persists across scene changes (shop <-> forest). Stores only ids and counts;
# display data comes from ItemDatabase. Quantities are never negative.

signal inventory_changed
signal gold_changed

var _items: Dictionary = {}
var gold: int = 0

func add_gold(amount: int) -> void:
	if amount == 0:
		return
	gold = max(0, gold + amount)
	gold_changed.emit()

func get_gold() -> int:
	return gold

func add_item(id: String, quantity: int = 1) -> void:
	if quantity <= 0:
		push_warning("Inventory: add_item needs quantity > 0 (%s, %d)" % [id, quantity])
		return
	if not ItemDatabase.has_item(id):
		push_warning("Inventory: add_item unknown item id '%s'" % id)
		return
	_items[id] = get_quantity(id) + quantity
	inventory_changed.emit()

func remove_item(id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		push_warning("Inventory: remove_item needs quantity > 0 (%s, %d)" % [id, quantity])
		return false
	var have := get_quantity(id)
	if have < quantity:
		return false
	var left := have - quantity
	if left > 0:
		_items[id] = left
	else:
		_items.erase(id)
	inventory_changed.emit()
	return true

func get_quantity(id: String) -> int:
	return int(_items.get(id, 0))

func has_item(id: String, quantity: int = 1) -> bool:
	return get_quantity(id) >= quantity

func has_ingredients(ingredients: Dictionary) -> bool:
	for id in ingredients:
		if get_quantity(id) < int(ingredients[id]):
			return false
	return true

func get_all() -> Dictionary:
	return _items.duplicate()

func clear() -> void:
	_items.clear()
	inventory_changed.emit()

# Replaces the whole inventory + gold (used by SaveSystem on load).
func load_from(items: Dictionary, new_gold: int) -> void:
	_items.clear()
	for id in items:
		var quantity := int(items[id])
		if quantity <= 0:
			continue
		if not ItemDatabase.has_item(id):
			push_warning("Inventory: load ignored unknown item '%s'" % id)
			continue
		_items[id] = quantity
	gold = maxi(0, new_gold)
	inventory_changed.emit()
	gold_changed.emit()
