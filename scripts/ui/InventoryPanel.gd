extends CanvasLayer

# Autoload singleton. A small, non-modal inventory panel toggled with the
# "toggle_inventory" action. Lists carried items (id -> quantity from Inventory)
# with each item's icon when the art exists, or a colored fallback swatch until it
# does. Rebuilds whenever the inventory changes. Display data comes from ItemDatabase.

const ICON_SIZE := Vector2(16, 16)

@onready var _rows: VBoxContainer = $Panel/Margin/VBox/Rows

func _ready() -> void:
	layer = 55
	visible = false
	Inventory.inventory_changed.connect(_rebuild)
	_rebuild()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		visible = not visible

func _rebuild() -> void:
	for child in _rows.get_children():
		child.queue_free()

	var items: Dictionary = Inventory.get_all()
	if items.is_empty():
		_rows.add_child(_make_empty_label())
		return

	for id in items:
		var item_id := String(id)
		var quantity := int(items[item_id])
		_rows.add_child(_make_row(item_id, quantity))

func _make_empty_label() -> Label:
	var label := Label.new()
	label.text = "Empty"
	label.add_theme_color_override("font_color", Color(0.78, 0.68, 0.55, 1))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.03, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_font_size_override("font_size", 13)
	return label

func _make_row(item_id: String, quantity: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(_make_icon(item_id))
	row.add_child(_make_label(item_id, quantity))
	return row

func _make_icon(item_id: String) -> Control:
	var icon_path := String(ItemDatabase.get_item(item_id).get("icon", ""))
	var texture := _load_icon_texture(icon_path)
	if texture != null:
		var texture_rect := TextureRect.new()
		texture_rect.texture = texture
		texture_rect.custom_minimum_size = ICON_SIZE
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return texture_rect

	var swatch := ColorRect.new()
	swatch.color = _swatch_color(item_id)
	swatch.custom_minimum_size = ICON_SIZE
	return swatch

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

func _make_label(item_id: String, quantity: int) -> Label:
	var label := Label.new()
	label.text = "%s  x%d" % [ItemDatabase.get_item_name(item_id), quantity]
	label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.6, 1))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.03, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_font_size_override("font_size", 13)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

# Deterministic placeholder color per item id (until real icon art exists).
func _swatch_color(item_id: String) -> Color:
	var hue := float(hash(item_id) % 360) / 360.0
	return Color.from_hsv(hue, 0.45, 0.85)
