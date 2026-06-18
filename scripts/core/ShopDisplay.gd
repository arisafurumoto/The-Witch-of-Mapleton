extends "res://scripts/core/Interactable.gd"

# One-item display prototype for the first Moonlighter-style shop loop.
# Stock is intentionally simple: one configured item, one quantity.

signal stock_changed

@export var display_id: String = "main_display"
@export var accepted_item_id: String = "calming_tea"
@export var accepted_quantity: int = 1

var _stock_item_id: String = ""
var _stock_quantity: int = 0
var _reserved: bool = false

@onready var _item_icon: Sprite2D = get_node_or_null("ItemIcon") as Sprite2D

func _ready() -> void:
	super._ready()
	add_to_group("shop_displays")
	DaySystem.day_changed.connect(_on_day_changed)
	SaveSystem.apply_pending_shop_display(self)
	_update_visual()

func interact() -> void:
	interacted.emit()
	if _reserved:
		HUD.show_toast("Customer has chosen this item")
		return
	if has_stock():
		_return_stock_to_inventory()
		return
	_stock_from_inventory()

func has_stock() -> bool:
	return _stock_item_id != "" and _stock_quantity > 0

func get_stock_item_id() -> String:
	return _stock_item_id

func get_stock_quantity() -> int:
	return _stock_quantity

func get_stock_total_price() -> int:
	if not has_stock():
		return 0
	return ItemDatabase.get_sell_price(_stock_item_id) * _stock_quantity

func reserve_stock() -> bool:
	if not has_stock() or _reserved:
		return false
	_reserved = true
	_update_visual()
	stock_changed.emit()
	return true

func consume_stock() -> Dictionary:
	if not has_stock():
		return {}
	var sold_stock := {
		"item_id": _stock_item_id,
		"quantity": _stock_quantity,
		"gold": get_stock_total_price(),
	}
	_stock_item_id = ""
	_stock_quantity = 0
	_reserved = false
	_update_visual()
	stock_changed.emit()
	return sold_stock

func get_save_id() -> String:
	return display_id

func get_save_data() -> Dictionary:
	if not has_stock():
		return {}
	return {
		"item_id": _stock_item_id,
		"quantity": _stock_quantity,
	}

func load_from_save(data: Dictionary) -> void:
	var item_id := String(data.get("item_id", ""))
	var quantity := int(data.get("quantity", 0))
	if item_id == "" or quantity <= 0 or not ItemDatabase.has_item(item_id):
		_stock_item_id = ""
		_stock_quantity = 0
	else:
		_stock_item_id = item_id
		_stock_quantity = quantity
	_reserved = false
	_update_visual()
	stock_changed.emit()

func show_prompt(value: bool) -> void:
	if _reserved:
		prompt = "Item chosen"
	else:
		prompt = "Take item" if has_stock() else "Stock display"
	if _label:
		_label.text = prompt
	super.show_prompt(value)

func _stock_from_inventory() -> void:
	if accepted_item_id == "" or accepted_quantity <= 0:
		return
	if not Inventory.remove_item(accepted_item_id, accepted_quantity):
		HUD.show_toast("Need %s x%d" % [ItemDatabase.get_item_name(accepted_item_id), accepted_quantity])
		return
	_stock_item_id = accepted_item_id
	_stock_quantity = accepted_quantity
	_reserved = false
	HUD.show_toast("Stocked %s x%d" % [ItemDatabase.get_item_name(_stock_item_id), _stock_quantity])
	_update_visual()
	stock_changed.emit()

func _return_stock_to_inventory() -> void:
	if not has_stock():
		return
	Inventory.add_item(_stock_item_id, _stock_quantity)
	HUD.show_toast("Returned %s x%d" % [ItemDatabase.get_item_name(_stock_item_id), _stock_quantity])
	_stock_item_id = ""
	_stock_quantity = 0
	_reserved = false
	_update_visual()
	stock_changed.emit()

func _update_visual() -> void:
	if _item_icon == null:
		return
	_item_icon.visible = has_stock() and not _reserved
	if not has_stock():
		_item_icon.texture = null
		return
	var icon_path := String(ItemDatabase.get_item(_stock_item_id).get("icon", ""))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		_item_icon.texture = load(icon_path)

func _on_day_changed(_day: int) -> void:
	_return_stock_to_inventory()
