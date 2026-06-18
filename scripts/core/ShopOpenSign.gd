extends "res://scripts/core/Interactable.gd"

# Starts the tiny one-customer shop browsing prototype.

@export var display_path: NodePath

func interact() -> void:
	interacted.emit()
	if _has_closed_shop_visitor():
		HUD.show_toast("Finish talking with your visitor first")
		return
	var display := get_node_or_null(display_path)
	if display == null or not display.has_method("has_stock") or not bool(display.call("has_stock")):
		HUD.show_toast("Stock the display first")
		return
	var customer := get_tree().get_first_node_in_group("shop_customers")
	if customer == null or not customer.has_method("start_shop_session"):
		HUD.show_toast("No customer is nearby")
		return
	customer.start_shop_session()

func show_prompt(value: bool) -> void:
	prompt = "Visitor here" if _has_closed_shop_visitor() else "Open shop"
	if _label:
		_label.text = prompt
	super.show_prompt(value)

func _has_closed_shop_visitor() -> bool:
	return get_tree().get_first_node_in_group("closed_shop_visitors") != null
