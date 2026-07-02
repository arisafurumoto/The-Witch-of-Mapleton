extends "res://scripts/core/Interactable.gd"

# Shop shelf. Each display holds a stack of one sellable crafted item.

signal stock_changed

@export var display_id: String = "main_display"
@export var accepted_item_id: String = "calming_tea"
@export var accepted_quantity: int = 1

var _stock_item_id: String = ""
var _stock_quantity: int = 0
var _reserved: bool = false

@onready var _item_icon: Sprite2D = get_node_or_null("ItemIcon") as Sprite2D
@onready var _quantity_label: Label = get_node_or_null("QuantityLabel") as Label

func _ready() -> void:
	super._ready()
	add_to_group("shop_displays")
	DaySystem.day_changed.connect(_on_day_changed)
	load_from_save(ShopState.get_display_stock(display_id))
	_update_visual()

func interact() -> void:
	interacted.emit()
	if _reserved:
		HUD.show_toast("Customer has chosen this item")
		return
	DisplayStockPanel.open(self)

func has_stock() -> bool:
	return _stock_item_id != "" and _stock_quantity > 0

func get_stock_item_id() -> String:
	return _stock_item_id

func get_stock_quantity() -> int:
	return _stock_quantity

func get_available_stock_quantity() -> int:
	if not has_stock():
		return 0
	return _stock_quantity - (1 if _reserved else 0)

func can_retrieve_stock() -> bool:
	return has_stock() and not _reserved

func retrieve_stock_to_inventory() -> bool:
	if not can_retrieve_stock():
		return false
	var item_name := ItemDatabase.get_item_name(_stock_item_id)
	var quantity := _stock_quantity
	Inventory.add_item(_stock_item_id, _stock_quantity)
	_stock_item_id = ""
	_stock_quantity = 0
	_reserved = false
	_sync_shop_state()
	HUD.show_toast("Retrieved %s x%d" % [item_name, quantity])
	_update_visual()
	stock_changed.emit()
	return true

func get_stock_total_price() -> int:
	if not has_stock():
		return 0
	return ItemDatabase.get_sell_price(_stock_item_id) * _stock_quantity

func reserve_stock() -> bool:
	if get_available_stock_quantity() <= 0:
		return false
	_reserved = true
	_sync_shop_state()
	_update_visual()
	stock_changed.emit()
	return true

func consume_stock() -> Dictionary:
	if not has_stock():
		return {}
	var sold_quantity := 1
	var sold_stock := {
		"item_id": _stock_item_id,
		"quantity": sold_quantity,
		"gold": ItemDatabase.get_sell_price(_stock_item_id) * sold_quantity,
	}
	_stock_quantity -= sold_quantity
	if _stock_quantity <= 0:
		_stock_item_id = ""
		_stock_quantity = 0
	_reserved = false
	_sync_shop_state()
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
	elif has_stock() and _is_stockable_item(_stock_item_id) and Inventory.has_item(_stock_item_id, accepted_quantity):
		prompt = "Manage display"
	elif has_stock():
		prompt = "Manage display"
	else:
		prompt = "Stock display"
	if _label:
		_label.text = prompt
	super.show_prompt(value)

func can_stock_item(item_id: String) -> bool:
	if _reserved or accepted_quantity <= 0:
		return false
	if item_id == "" or not Inventory.has_item(item_id, accepted_quantity):
		return false
	if not _is_stockable_item(item_id):
		return false
	if has_stock() and _stock_item_id != item_id:
		return false
	var stack_limit := ItemDatabase.get_stack_limit(item_id)
	if stack_limit > 0 and _stock_quantity + accepted_quantity > stack_limit:
		return false
	return true

func stock_item_from_inventory(item_id: String) -> bool:
	if not can_stock_item(item_id):
		return false
	if not Inventory.remove_item(item_id, accepted_quantity):
		return false
	if has_stock():
		_stock_quantity += accepted_quantity
	else:
		_stock_item_id = item_id
		_stock_quantity = accepted_quantity
		_reserved = false
	_sync_shop_state()
	HUD.show_toast("Stocked %s x%d" % [ItemDatabase.get_item_name(_stock_item_id), _stock_quantity])
	_update_visual()
	stock_changed.emit()
	return true

func _stock_from_inventory() -> void:
	if accepted_quantity <= 0:
		return
	var item_id := _find_stockable_inventory_item_id()
	if item_id == "":
		HUD.show_toast("Need a sellable crafted good to stock")
		return
	stock_item_from_inventory(item_id)

func _add_matching_stock_from_inventory() -> void:
	if not has_stock():
		return
	if not _is_stockable_item(_stock_item_id):
		HUD.show_toast("Display stocked with %s" % ItemDatabase.get_item_name(_stock_item_id))
		return
	if not Inventory.has_item(_stock_item_id, accepted_quantity):
		HUD.show_toast("Display stocked with %s" % ItemDatabase.get_item_name(_stock_item_id))
		return
	var stack_limit := ItemDatabase.get_stack_limit(_stock_item_id)
	if stack_limit > 0 and _stock_quantity + accepted_quantity > stack_limit:
		HUD.show_toast("Display is full")
		return
	stock_item_from_inventory(_stock_item_id)

func _update_visual() -> void:
	var visible_quantity := get_available_stock_quantity()
	if _item_icon != null:
		_item_icon.visible = visible_quantity > 0
	if _quantity_label != null:
		_quantity_label.visible = visible_quantity > 0
		_quantity_label.text = "x%d" % visible_quantity
	if not has_stock():
		if _item_icon != null:
			_item_icon.texture = null
		return
	var icon_path := String(ItemDatabase.get_item(_stock_item_id).get("icon", ""))
	var texture := _load_icon_texture(icon_path)
	if texture != null and _item_icon != null:
		_item_icon.texture = texture

func _find_stockable_inventory_item_id() -> String:
	if accepted_item_id != "" and Inventory.has_item(accepted_item_id, accepted_quantity) and _is_stockable_item(accepted_item_id):
		return accepted_item_id
	var item_ids: Array = Inventory.get_all().keys()
	item_ids.sort()
	for value in item_ids:
		var item_id := String(value)
		if Inventory.has_item(item_id, accepted_quantity) and _is_stockable_item(item_id):
			return item_id
	return ""

func _is_stockable_item(item_id: String) -> bool:
	if not ItemDatabase.has_item(item_id):
		return false
	var item: Dictionary = ItemDatabase.get_item(item_id)
	if String(item.get("category", "")) != "crafted_good":
		return false
	if ItemDatabase.get_sell_price(item_id) <= 0:
		return false
	var recipe: Dictionary = RecipeDatabase.get_recipe_for_output(item_id)
	if recipe.is_empty():
		return false
	return _is_recipe_available_for_sale(recipe)

func _is_recipe_available_for_sale(recipe: Dictionary) -> bool:
	var recipe_id := String(recipe.get("id", ""))
	if RecipeKnowledgeSystem.is_recipe_known(recipe_id):
		return true
	var quest_id := String(recipe.get("quest_id", ""))
	if quest_id == "":
		return false
	var state := QuestSystem.get_quest_state(quest_id)
	return state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY

func _load_icon_texture(icon_path: String) -> Texture2D:
	if icon_path == "":
		return null
	if _imported_texture_is_ready(icon_path) and ResourceLoader.exists(icon_path):
		return load(icon_path) as Texture2D
	return null

func _imported_texture_is_ready(icon_path: String) -> bool:
	var import_path := icon_path + ".import"
	if not FileAccess.file_exists(import_path):
		return true
	var text := FileAccess.get_file_as_string(import_path)
	for line in text.split("\n"):
		if not line.begins_with("dest_files="):
			continue
		var start: int = line.find("\"")
		var end: int = line.find("\"", start + 1)
		if start >= 0 and end > start:
			return FileAccess.file_exists(line.substr(start + 1, end - start - 1))
	return false

func _on_day_changed(_day: int) -> void:
	if not _reserved:
		return
	_reserved = false
	_sync_shop_state()
	_update_visual()
	stock_changed.emit()

func _sync_shop_state() -> void:
	if has_stock():
		ShopState.set_display_stock(display_id, _stock_item_id, _stock_quantity)
	else:
		ShopState.clear_display_stock(display_id)
