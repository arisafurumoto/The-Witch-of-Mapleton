extends "res://scripts/core/Interactable.gd"

# Starts a tiny sequential customer queue from stocked shop displays.

@export var display_path: NodePath

func interact() -> void:
	interacted.emit()
	if _has_closed_shop_visitor():
		HUD.show_toast("Finish talking with your visitor first")
		return
	var customer := get_tree().get_first_node_in_group("shop_customers")
	if customer == null or not customer.has_method("start_shop_session"):
		HUD.show_toast("No customer is nearby")
		return
	if customer.has_method("is_shop_session_active") and bool(customer.call("is_shop_session_active")):
		HUD.show_toast("A customer is already shopping")
		return
	var stock_quantity := _total_available_stock_quantity()
	if stock_quantity <= 0:
		HUD.show_toast("Stock the display first")
		return
	var planned_customers := mini(stock_quantity, 3)
	customer.call("start_shop_session", planned_customers)

func show_prompt(value: bool) -> void:
	prompt = "Visitor here" if _has_closed_shop_visitor() else "Open shop"
	if _label:
		_label.text = prompt
	super.show_prompt(value)

func _has_closed_shop_visitor() -> bool:
	return get_tree().get_first_node_in_group("closed_shop_visitors") != null

func _total_available_stock_quantity() -> int:
	var total := 0
	for display in _stocked_displays():
		total += _display_stock_quantity(display)
	return total

func _stocked_displays() -> Array[Node2D]:
	var displays: Array[Node2D] = []
	for value in get_tree().get_nodes_in_group("shop_displays"):
		var display := value as Node2D
		if display != null and _display_stock_quantity(display) > 0:
			displays.append(display)
	displays.sort_custom(_sort_displays_by_path)
	if displays.is_empty():
		var fallback := get_node_or_null(display_path) as Node2D
		if fallback != null and _display_stock_quantity(fallback) > 0:
			displays.append(fallback)
	return displays

func _display_stock_quantity(display: Node2D) -> int:
	if display.has_method("get_available_stock_quantity"):
		return int(display.call("get_available_stock_quantity"))
	if display.has_method("get_stock_quantity"):
		return int(display.call("get_stock_quantity"))
	if display.has_method("has_stock"):
		return 1 if bool(display.call("has_stock")) else 0
	return 0

func _sort_displays_by_path(a: Node2D, b: Node2D) -> bool:
	return _display_sort_key(a) < _display_sort_key(b)

func _display_sort_key(display: Node2D) -> String:
	if display.has_method("get_save_id"):
		return String(display.call("get_save_id"))
	return String(display.get_path())
