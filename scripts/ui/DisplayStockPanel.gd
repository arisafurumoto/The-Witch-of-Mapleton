extends CanvasLayer

# Autoload singleton. Lets the player choose which carried crafted good to place on
# a shop display, and retrieve display stock before a customer reserves it.

@onready var _title_label: Label = $Panel/Margin/VBox/Header/TitleLabel
@onready var _close_button: Button = $Panel/Margin/VBox/Header/CloseButton
@onready var _stock_label: Label = $Panel/Margin/VBox/StockLabel
@onready var _item_rows: VBoxContainer = $Panel/Margin/VBox/ItemScroll/ItemRows
@onready var _retrieve_button: Button = $Panel/Margin/VBox/ActionRow/RetrieveButton
@onready var _result_label: Label = $Panel/Margin/VBox/ResultLabel

var _display: Node = null

func _ready() -> void:
	layer = 88
	visible = false
	_close_button.pressed.connect(close)
	_retrieve_button.pressed.connect(_on_retrieve_pressed)
	Inventory.inventory_changed.connect(_rebuild)

func is_active() -> bool:
	return visible

func open(display: Node) -> void:
	_display = display
	_result_label.text = ""
	visible = true
	_rebuild()

func close() -> void:
	visible = false
	_display = null
	_result_label.text = ""

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _rebuild() -> void:
	if not is_node_ready() or not visible:
		return
	_clear_rows()
	if _display == null or not is_instance_valid(_display):
		close()
		return
	_title_label.text = "Shop Display"
	_stock_label.text = _stock_text()
	_retrieve_button.disabled = not _can_retrieve()
	var item_ids := _stockable_inventory_item_ids()
	if item_ids.is_empty():
		_item_rows.add_child(_make_empty_label("No sellable goods carried"))
		return
	for value in item_ids:
		var item_id := String(value)
		_item_rows.add_child(_make_item_button(item_id))

func _clear_rows() -> void:
	for child in _item_rows.get_children():
		child.queue_free()

func _stock_text() -> String:
	if not _has_stock():
		return "Stock: Empty"
	var item_id := String(_display.call("get_stock_item_id"))
	var quantity := int(_display.call("get_stock_quantity"))
	return "Stock: %s x%d" % [ItemDatabase.get_item_name(item_id), quantity]

func _can_retrieve() -> bool:
	if _display == null or not is_instance_valid(_display):
		return false
	if not _display.has_method("can_retrieve_stock"):
		return false
	return bool(_display.call("can_retrieve_stock"))

func _has_stock() -> bool:
	return _display != null and is_instance_valid(_display) and _display.has_method("has_stock") and bool(_display.call("has_stock"))

func _stockable_inventory_item_ids() -> Array[String]:
	var item_ids: Array[String] = []
	if _display == null or not is_instance_valid(_display) or not _display.has_method("can_stock_item"):
		return item_ids
	var carried_ids: Array = Inventory.get_all().keys()
	carried_ids.sort()
	for value in carried_ids:
		var item_id := String(value)
		if bool(_display.call("can_stock_item", item_id)):
			item_ids.append(item_id)
	return item_ids

func _make_item_button(item_id: String) -> Button:
	var button := Button.new()
	var quantity := Inventory.get_quantity(item_id)
	var command := "Add" if _has_stock() else "Stock"
	button.text = "%s %s  x%d" % [command, ItemDatabase.get_item_name(item_id), quantity]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(240, 24)
	button.pressed.connect(_on_stock_pressed.bind(item_id))
	return button

func _make_empty_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.78, 0.68, 0.55, 1))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.03, 1))
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", 11)
	return label

func _on_stock_pressed(item_id: String) -> void:
	if _display == null or not is_instance_valid(_display):
		close()
		return
	if not _display.has_method("stock_item_from_inventory"):
		return
	if bool(_display.call("stock_item_from_inventory", item_id)):
		_result_label.text = "Stocked %s" % ItemDatabase.get_item_name(item_id)
	_rebuild()

func _on_retrieve_pressed() -> void:
	if _display == null or not is_instance_valid(_display):
		close()
		return
	if not _display.has_method("retrieve_stock_to_inventory"):
		return
	if bool(_display.call("retrieve_stock_to_inventory")):
		_result_label.text = "Returned stock to inventory"
	_rebuild()
