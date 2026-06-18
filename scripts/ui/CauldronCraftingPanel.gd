extends CanvasLayer

# Autoload singleton. Compact cauldron UI for selecting known recipes and
# brewing one or more batches when the inventory has enough ingredients.

const ICON_SIZE := Vector2(16, 16)

@onready var _recipe_rows: VBoxContainer = $Panel/Margin/VBox/Body/RecipeSection/RecipeScroll/RecipeRows
@onready var _selected_title_label: Label = $Panel/Margin/VBox/Body/DetailSection/SelectedTitleLabel
@onready var _output_label: Label = $Panel/Margin/VBox/Body/DetailSection/OutputLabel
@onready var _ingredient_rows: VBoxContainer = $Panel/Margin/VBox/Body/DetailSection/IngredientRows
@onready var _minus_button: Button = $Panel/Margin/VBox/Body/DetailSection/QuantityRow/MinusButton
@onready var _quantity_label: Label = $Panel/Margin/VBox/Body/DetailSection/QuantityRow/QuantityLabel
@onready var _plus_button: Button = $Panel/Margin/VBox/Body/DetailSection/QuantityRow/PlusButton
@onready var _result_label: Label = $Panel/Margin/VBox/Body/DetailSection/ResultLabel
@onready var _brew_button: Button = $Panel/Margin/VBox/Body/DetailSection/BrewButton
@onready var _close_button: Button = $Panel/Margin/VBox/Header/CloseButton

var _station: String = "cauldron"
var _preferred_recipe_ids: PackedStringArray = PackedStringArray()
var _selected_recipe_id: String = ""
var _brew_quantity: int = 1

func _ready() -> void:
	layer = 90
	visible = false
	_brew_button.pressed.connect(_on_brew_pressed)
	_minus_button.pressed.connect(_change_quantity.bind(-1))
	_plus_button.pressed.connect(_change_quantity.bind(1))
	_close_button.pressed.connect(close)
	Inventory.inventory_changed.connect(_rebuild)
	RecipeKnowledgeSystem.recipe_unlocked.connect(_on_recipe_unlocked)
	QuestSystem.quest_state_changed.connect(_on_quest_state_changed)

func is_active() -> bool:
	return visible

func open(station: String, preferred_recipe_ids: PackedStringArray) -> void:
	_station = station
	_preferred_recipe_ids = preferred_recipe_ids
	_selected_recipe_id = ""
	_brew_quantity = 1
	_result_label.text = ""
	visible = true
	_select_first_craftable_recipe()
	_rebuild()

func close() -> void:
	visible = false
	_selected_recipe_id = ""
	_brew_quantity = 1

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _rebuild() -> void:
	if not is_node_ready():
		return
	_keep_selection_valid()
	_clamp_quantity()
	_clear_rows(_recipe_rows)
	_clear_rows(_ingredient_rows)
	_build_recipe_rows()
	_build_detail_panel()

func _clear_rows(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func _build_recipe_rows() -> void:
	var recipes: Array[Dictionary] = _known_recipes()
	if recipes.is_empty():
		_recipe_rows.add_child(_make_empty_label("No known recipes"))
		return

	for recipe in recipes:
		_recipe_rows.add_child(_make_recipe_row(recipe))

func _make_recipe_row(recipe: Dictionary) -> Button:
	var recipe_id: String = String(recipe.get("id", ""))
	var recipe_name: String = String(recipe.get("name", recipe_id))
	var max_quantity: int = _max_brew_quantity(recipe)
	var button := Button.new()
	button.text = recipe_name
	if max_quantity <= 0:
		button.text += " (need ingredients)"
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(184, 22)
	button.pressed.connect(_select_recipe.bind(recipe_id))
	return button

func _build_detail_panel() -> void:
	var recipe: Dictionary = _selected_recipe()
	if recipe.is_empty():
		_selected_title_label.text = "Choose a recipe"
		_output_label.text = "Gather ingredients to brew."
		_ingredient_rows.add_child(_make_empty_label("No recipe selected"))
		_quantity_label.text = "0"
		_minus_button.disabled = true
		_plus_button.disabled = true
		_brew_button.disabled = true
		return

	var recipe_name: String = String(recipe.get("name", _selected_recipe_id))
	var output: Dictionary = recipe.get("output", {})
	var output_id: String = String(output.get("item_id", ""))
	var output_quantity: int = int(output.get("quantity", 1)) * _brew_quantity
	var max_quantity: int = _max_brew_quantity(recipe)
	_selected_title_label.text = recipe_name
	_output_label.text = "Makes %s x%d" % [ItemDatabase.get_item_name(output_id), output_quantity]
	_build_ingredient_rows(recipe)
	_quantity_label.text = str(_brew_quantity)
	_minus_button.disabled = _brew_quantity <= 1
	_plus_button.disabled = _brew_quantity >= max_quantity
	_brew_button.disabled = max_quantity <= 0

func _build_ingredient_rows(recipe: Dictionary) -> void:
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var ids: Array = ingredients.keys()
	ids.sort()
	for id in ids:
		var item_id := String(id)
		var needed: int = int(ingredients[item_id]) * _brew_quantity
		var have: int = Inventory.get_quantity(item_id)
		_ingredient_rows.add_child(_make_ingredient_row(item_id, needed, have))

func _make_ingredient_row(item_id: String, needed: int, have: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(_make_icon(item_id))

	var label := Label.new()
	label.text = "%s %d/%d" % [ItemDatabase.get_item_name(item_id), have, needed]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var enough: bool = have >= needed
	label.add_theme_color_override("font_color", Color(0.98, 0.86, 0.6, 1) if enough else Color(0.92, 0.46, 0.36, 1))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.03, 1))
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", 11)
	row.add_child(label)
	return row

func _make_icon(item_id: String) -> Control:
	var icon_path := String(ItemDatabase.get_item(item_id).get("icon", ""))
	if icon_path != "" and ResourceLoader.exists(icon_path):
		var texture_rect := TextureRect.new()
		texture_rect.texture = load(icon_path)
		texture_rect.custom_minimum_size = ICON_SIZE
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		return texture_rect

	var swatch := ColorRect.new()
	swatch.color = _swatch_color(item_id)
	swatch.custom_minimum_size = ICON_SIZE
	return swatch

func _make_empty_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color(0.78, 0.68, 0.55, 1))
	label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.03, 1))
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", 11)
	return label

func _select_recipe(recipe_id: String) -> void:
	_selected_recipe_id = recipe_id
	_brew_quantity = 1
	_result_label.text = ""
	_rebuild()

func _change_quantity(delta: int) -> void:
	var recipe: Dictionary = _selected_recipe()
	if recipe.is_empty():
		return
	var max_quantity: int = _max_brew_quantity(recipe)
	_brew_quantity = clampi(_brew_quantity + delta, 1, maxi(1, max_quantity))
	_result_label.text = ""
	_rebuild()

func _on_brew_pressed() -> void:
	var recipe: Dictionary = _selected_recipe()
	if recipe.is_empty():
		_result_label.text = "Choose a recipe."
		return
	var max_quantity: int = _max_brew_quantity(recipe)
	if max_quantity <= 0:
		_result_label.text = "Need ingredients."
		return
	_clamp_quantity()

	if not CraftingSystem.craft_quantity(_selected_recipe_id, _brew_quantity):
		_result_label.text = "Need ingredients."
		return

	var output: Dictionary = recipe.get("output", {})
	var output_id: String = String(output.get("item_id", ""))
	AudioSystem.play_craft()
	_result_label.text = "Made %s x%d" % [ItemDatabase.get_item_name(output_id), int(output.get("quantity", 1)) * _brew_quantity]
	_brew_quantity = 1
	_rebuild()

func _selected_recipe() -> Dictionary:
	if _selected_recipe_id == "" or not RecipeDatabase.has_recipe(_selected_recipe_id):
		return {}
	var recipe: Dictionary = RecipeDatabase.get_recipe(_selected_recipe_id)
	if not _is_recipe_known(recipe):
		return {}
	return recipe

func _select_first_craftable_recipe() -> void:
	for recipe in _known_recipes():
		if _max_brew_quantity(recipe) > 0:
			_selected_recipe_id = String(recipe.get("id", ""))
			return
	var recipes: Array[Dictionary] = _known_recipes()
	if not recipes.is_empty():
		_selected_recipe_id = String(recipes[0].get("id", ""))

func _keep_selection_valid() -> void:
	if _selected_recipe_id == "":
		_select_first_craftable_recipe()
		return
	if _selected_recipe().is_empty():
		_selected_recipe_id = ""
		_select_first_craftable_recipe()

func _clamp_quantity() -> void:
	var recipe: Dictionary = _selected_recipe()
	if recipe.is_empty():
		_brew_quantity = 1
		return
	var max_quantity: int = _max_brew_quantity(recipe)
	_brew_quantity = clampi(_brew_quantity, 1, maxi(1, max_quantity))

func _max_brew_quantity(recipe: Dictionary) -> int:
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var max_quantity: int = 999
	for id in ingredients:
		var item_id := String(id)
		var needed_per_batch: int = int(ingredients[item_id])
		if needed_per_batch <= 0:
			continue
		max_quantity = mini(max_quantity, int(floor(float(Inventory.get_quantity(item_id)) / float(needed_per_batch))))
	if max_quantity == 999:
		return 0
	var quest_id := String(recipe.get("quest_id", ""))
	if quest_id != "" and _is_quest_recipe_active(quest_id):
		return mini(max_quantity, 1)
	return max_quantity

func _known_recipes() -> Array[Dictionary]:
	var recipes: Array[Dictionary] = []
	for recipe in _ordered_candidate_recipes():
		if _is_recipe_known(recipe):
			recipes.append(recipe)
	return recipes

func _ordered_candidate_recipes() -> Array[Dictionary]:
	var recipes: Array[Dictionary] = []
	for recipe_id in _preferred_recipe_ids:
		var id := String(recipe_id)
		if RecipeDatabase.has_recipe(id):
			var recipe: Dictionary = RecipeDatabase.get_recipe(id)
			if String(recipe.get("station", "")) == _station:
				recipes.append(recipe)

	for recipe in RecipeDatabase.get_recipes_for_station(_station):
		var recipe_id: String = String(recipe.get("id", ""))
		if not _preferred_recipe_ids.has(recipe_id):
			recipes.append(recipe)
	return recipes

func _is_recipe_known(recipe: Dictionary) -> bool:
	var recipe_id := String(recipe.get("id", ""))
	if RecipeKnowledgeSystem.is_recipe_known(recipe_id):
		return true
	var quest_id: String = String(recipe.get("quest_id", ""))
	return quest_id != "" and _is_quest_recipe_active(quest_id)

func _is_quest_recipe_active(quest_id: String) -> bool:
	var state := QuestSystem.get_quest_state(quest_id)
	return state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY

func _on_recipe_unlocked(_recipe_id: String) -> void:
	_rebuild()

func _on_quest_state_changed(_quest_id: String, _state: String) -> void:
	_rebuild()

func _swatch_color(item_id: String) -> Color:
	var hue: float = float(hash(item_id) % 360) / 360.0
	return Color.from_hsv(hue, 0.45, 0.85)
