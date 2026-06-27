extends CanvasLayer

# Autoload singleton. Read-only notebook for checking current quest requirements
# and known recipe ingredient counts.

const TAB_QUESTS := "quests"
const TAB_RECIPES := "recipes"

const TEXT_COLOR := Color(0.98, 0.86, 0.6, 1)
const MUTED_COLOR := Color(0.78, 0.68, 0.55, 1)
const READY_COLOR := Color(0.78, 0.88, 0.62, 1)
const MISSING_COLOR := Color(0.92, 0.46, 0.36, 1)
const OUTLINE_COLOR := Color(0.08, 0.04, 0.03, 1)

@onready var _close_button: Button = $Panel/Margin/VBox/Header/CloseButton
@onready var _quests_tab_button: Button = $Panel/Margin/VBox/Tabs/QuestsTabButton
@onready var _recipes_tab_button: Button = $Panel/Margin/VBox/Tabs/RecipesTabButton
@onready var _quest_page: HBoxContainer = $Panel/Margin/VBox/Body/QuestPage
@onready var _recipe_page: HBoxContainer = $Panel/Margin/VBox/Body/RecipePage
@onready var _quest_rows: VBoxContainer = $Panel/Margin/VBox/Body/QuestPage/ListSection/QuestScroll/QuestRows
@onready var _quest_detail_title_label: Label = $Panel/Margin/VBox/Body/QuestPage/DetailSection/QuestDetailTitleLabel
@onready var _quest_detail_rows: VBoxContainer = $Panel/Margin/VBox/Body/QuestPage/DetailSection/QuestDetailRows
@onready var _recipe_rows: VBoxContainer = $Panel/Margin/VBox/Body/RecipePage/ListSection/RecipeScroll/RecipeRows
@onready var _recipe_detail_title_label: Label = $Panel/Margin/VBox/Body/RecipePage/DetailSection/RecipeDetailTitleLabel
@onready var _recipe_detail_rows: VBoxContainer = $Panel/Margin/VBox/Body/RecipePage/DetailSection/RecipeDetailRows

var _current_tab: String = TAB_QUESTS
var _selected_quest_id: String = ""
var _selected_recipe_id: String = ""
var _open_quest_ids: PackedStringArray = PackedStringArray()
var _completed_quest_ids: PackedStringArray = PackedStringArray()
var _visible_recipe_ids: PackedStringArray = PackedStringArray()
var _quest_row_text_by_id: Dictionary = {}
var _recipe_row_text_by_id: Dictionary = {}
var _quest_detail_lines: PackedStringArray = PackedStringArray()
var _recipe_detail_lines: PackedStringArray = PackedStringArray()

func _ready() -> void:
	layer = 88
	visible = false
	_close_button.pressed.connect(close)
	_quests_tab_button.pressed.connect(_select_tab.bind(TAB_QUESTS))
	_recipes_tab_button.pressed.connect(_select_tab.bind(TAB_RECIPES))
	Inventory.inventory_changed.connect(_on_data_changed)
	QuestSystem.quest_state_changed.connect(_on_data_changed.unbind(2))
	RecipeKnowledgeSystem.recipe_unlocked.connect(_on_data_changed.unbind(1))
	_sync_tab_visibility()

func is_active() -> bool:
	return visible

func open() -> void:
	if not _can_open():
		return
	_current_tab = TAB_QUESTS
	_selected_quest_id = ""
	_selected_recipe_id = ""
	visible = true
	_rebuild()

func close() -> void:
	visible = false

func get_current_tab() -> String:
	return _current_tab

func get_open_quest_ids() -> Array[String]:
	var ids: Array[String] = []
	for quest_id in _open_quest_ids:
		ids.append(String(quest_id))
	return ids

func get_completed_quest_ids() -> Array[String]:
	var ids: Array[String] = []
	for quest_id in _completed_quest_ids:
		ids.append(String(quest_id))
	return ids

func get_visible_recipe_ids() -> Array[String]:
	var ids: Array[String] = []
	for recipe_id in _visible_recipe_ids:
		ids.append(String(recipe_id))
	return ids

func get_quest_row_text(quest_id: String) -> String:
	return String(_quest_row_text_by_id.get(quest_id, ""))

func get_recipe_row_text(recipe_id: String) -> String:
	return String(_recipe_row_text_by_id.get(recipe_id, ""))

func get_quest_detail_text() -> String:
	return "\n".join(_quest_detail_lines)

func get_recipe_detail_text() -> String:
	return "\n".join(_recipe_detail_lines)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_notebook"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()
		return
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func _can_open() -> bool:
	return not DialogueBox.is_active() and not CauldronCraftingPanel.is_active() and not HUD.is_day_transition_active()

func _on_data_changed() -> void:
	if visible:
		_rebuild()

func _select_tab(tab: String) -> void:
	_current_tab = tab
	_sync_tab_visibility()

func _sync_tab_visibility() -> void:
	_quest_page.visible = _current_tab == TAB_QUESTS
	_recipe_page.visible = _current_tab == TAB_RECIPES
	_quests_tab_button.button_pressed = _current_tab == TAB_QUESTS
	_recipes_tab_button.button_pressed = _current_tab == TAB_RECIPES

func _rebuild() -> void:
	if not is_node_ready():
		return
	_collect_visible_data()
	_keep_selection_valid()
	_clear_rows(_quest_rows)
	_clear_rows(_quest_detail_rows)
	_clear_rows(_recipe_rows)
	_clear_rows(_recipe_detail_rows)
	_build_quest_rows()
	_build_quest_detail()
	_build_recipe_rows()
	_build_recipe_detail()
	_sync_tab_visibility()

func _collect_visible_data() -> void:
	_open_quest_ids = _collect_quest_ids([QuestSystem.STATE_READY, QuestSystem.STATE_ACTIVE])
	_completed_quest_ids = _collect_quest_ids([QuestSystem.STATE_COMPLETED])
	_visible_recipe_ids = _collect_visible_recipe_ids()

func _collect_quest_ids(states: Array[String]) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for state in states:
		for raw_quest_id in QuestDatabase.get_all_ids():
			var quest_id := String(raw_quest_id)
			if QuestSystem.get_quest_state(quest_id) == state:
				ids.append(quest_id)
	return ids

func _collect_visible_recipe_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for raw_recipe_id in RecipeDatabase.get_all_ids():
		var recipe_id := String(raw_recipe_id)
		var recipe: Dictionary = RecipeDatabase.get_recipe(recipe_id)
		if _is_recipe_visible(recipe):
			ids.append(recipe_id)
	ids.sort()
	return ids

func _keep_selection_valid() -> void:
	if _selected_quest_id == "" or not _quest_is_visible(_selected_quest_id):
		_selected_quest_id = ""
		if not _open_quest_ids.is_empty():
			_selected_quest_id = String(_open_quest_ids[0])
		elif not _completed_quest_ids.is_empty():
			_selected_quest_id = String(_completed_quest_ids[0])

	if _selected_recipe_id == "" or not _visible_recipe_ids.has(_selected_recipe_id):
		_selected_recipe_id = ""
		if not _visible_recipe_ids.is_empty():
			_selected_recipe_id = String(_visible_recipe_ids[0])

func _quest_is_visible(quest_id: String) -> bool:
	return _open_quest_ids.has(quest_id) or _completed_quest_ids.has(quest_id)

func _clear_rows(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()

func _build_quest_rows() -> void:
	_quest_row_text_by_id.clear()
	_quest_rows.add_child(_make_section_label("Open"))
	if _open_quest_ids.is_empty():
		_quest_rows.add_child(_make_empty_label("No open quests"))
	else:
		for quest_id in _open_quest_ids:
			_quest_rows.add_child(_make_quest_row(String(quest_id)))

	if not _completed_quest_ids.is_empty():
		_quest_rows.add_child(_make_section_label("Completed"))
		for quest_id in _completed_quest_ids:
			_quest_rows.add_child(_make_quest_row(String(quest_id)))

func _make_quest_row(quest_id: String) -> Button:
	var quest := QuestDatabase.get_quest(quest_id)
	var state := QuestSystem.get_quest_state(quest_id)
	var button := _make_row_button()
	if state == QuestSystem.STATE_COMPLETED:
		button.text = "%s\n%s" % [
			String(quest.get("title", quest_id)),
			String(quest.get("npc_name", ""))
		]
	else:
		var item_id := String(quest.get("turn_in_item_id", ""))
		var needed := int(quest.get("turn_in_quantity", 1))
		var have := mini(Inventory.get_quantity(item_id), needed)
		button.text = "%s - %s\n%s %d/%d" % [
			_state_label(state),
			String(quest.get("title", quest_id)),
			ItemDatabase.get_item_name(item_id),
			have,
			needed
		]
	_quest_row_text_by_id[quest_id] = button.text
	button.button_pressed = quest_id == _selected_quest_id
	button.pressed.connect(_select_quest.bind(quest_id))
	return button

func _build_quest_detail() -> void:
	_quest_detail_lines.clear()
	if _selected_quest_id == "":
		_quest_detail_title_label.text = "No quests"
		_add_detail_line(_quest_detail_rows, _quest_detail_lines, "No open or completed quests.", MUTED_COLOR)
		return

	var quest := QuestDatabase.get_quest(_selected_quest_id)
	var state := QuestSystem.get_quest_state(_selected_quest_id)
	var item_id := String(quest.get("turn_in_item_id", ""))
	var item_name := ItemDatabase.get_item_name(item_id)
	var needed := int(quest.get("turn_in_quantity", 1))
	var have := mini(Inventory.get_quantity(item_id), needed)
	var npc_name := String(quest.get("npc_name", ""))
	_quest_detail_title_label.text = String(quest.get("title", _selected_quest_id))
	_add_detail_line(_quest_detail_rows, _quest_detail_lines, "Requester: %s" % npc_name, TEXT_COLOR)
	_add_detail_line(_quest_detail_rows, _quest_detail_lines, "State: %s" % _state_label(state), _state_color(state))
	if state == QuestSystem.STATE_COMPLETED:
		_add_detail_line(_quest_detail_rows, _quest_detail_lines, "Turned in: %s x%d" % [item_name, needed], TEXT_COLOR)
	else:
		_add_detail_line(_quest_detail_rows, _quest_detail_lines, "Need: %s %d/%d" % [item_name, have, needed], _state_color(state))
	_add_detail_line(_quest_detail_rows, _quest_detail_lines, "Objective: %s" % _quest_objective_text(quest, state), MUTED_COLOR)

func _build_recipe_rows() -> void:
	_recipe_row_text_by_id.clear()
	if _visible_recipe_ids.is_empty():
		_recipe_rows.add_child(_make_empty_label("No known recipes"))
		return

	for recipe_id in _visible_recipe_ids:
		_recipe_rows.add_child(_make_recipe_row(String(recipe_id)))

func _make_recipe_row(recipe_id: String) -> Button:
	var recipe := RecipeDatabase.get_recipe(recipe_id)
	var button := _make_row_button()
	var status := _recipe_status_text(recipe)
	button.text = "%s\n%s" % [String(recipe.get("name", recipe_id)), status]
	_recipe_row_text_by_id[recipe_id] = button.text
	button.button_pressed = recipe_id == _selected_recipe_id
	button.pressed.connect(_select_recipe.bind(recipe_id))
	return button

func _build_recipe_detail() -> void:
	_recipe_detail_lines.clear()
	if _selected_recipe_id == "":
		_recipe_detail_title_label.text = "No recipes"
		_add_detail_line(_recipe_detail_rows, _recipe_detail_lines, "No known recipes.", MUTED_COLOR)
		return

	var recipe := RecipeDatabase.get_recipe(_selected_recipe_id)
	var output: Dictionary = recipe.get("output", {})
	var output_id := String(output.get("item_id", ""))
	var output_quantity := int(output.get("quantity", 1))
	var status := _recipe_status_text(recipe)
	_recipe_detail_title_label.text = String(recipe.get("name", _selected_recipe_id))
	_add_detail_line(_recipe_detail_rows, _recipe_detail_lines, "Station: %s" % _display_station(String(recipe.get("station", ""))), TEXT_COLOR)
	_add_detail_line(_recipe_detail_rows, _recipe_detail_lines, "Makes: %s x%d" % [ItemDatabase.get_item_name(output_id), output_quantity], TEXT_COLOR)
	_add_detail_line(_recipe_detail_rows, _recipe_detail_lines, "Status: %s" % status, READY_COLOR if status == "Ready" else MISSING_COLOR)
	_add_detail_line(_recipe_detail_rows, _recipe_detail_lines, "Ingredients", MUTED_COLOR)
	for line in _ingredient_lines(recipe):
		var enough := not line.contains("Missing")
		_add_detail_line(_recipe_detail_rows, _recipe_detail_lines, line.replace("Missing ", ""), READY_COLOR if enough else MISSING_COLOR)

func _select_quest(quest_id: String) -> void:
	_selected_quest_id = quest_id
	_rebuild()

func _select_recipe(recipe_id: String) -> void:
	_selected_recipe_id = recipe_id
	_rebuild()

func _make_row_button() -> Button:
	var button := Button.new()
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(202, 38)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.23, 0.13, 0.08, 1), Color(0.5, 0.32, 0.16, 1)))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.3, 0.18, 0.1, 1), Color(0.72, 0.46, 0.22, 1)))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.36, 0.22, 0.12, 1), Color(0.78, 0.5, 0.22, 1)))
	button.add_theme_color_override("font_color", TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", READY_COLOR)
	button.add_theme_color_override("font_hover_color", TEXT_COLOR)
	button.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	button.add_theme_constant_override("outline_size", 1)
	button.add_theme_font_size_override("font_size", 10)
	return button

func _make_button_style(background_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = border_color
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_right = 3
	style.corner_radius_bottom_left = 3
	return style

func _make_section_label(text: String) -> Label:
	var label := _make_label(text, TEXT_COLOR, 11)
	label.custom_minimum_size = Vector2(202, 16)
	return label

func _make_empty_label(text: String) -> Label:
	var label := _make_label(text, MUTED_COLOR, 10)
	label.custom_minimum_size = Vector2(202, 20)
	return label

func _add_detail_line(container: VBoxContainer, lines: PackedStringArray, text: String, color: Color) -> void:
	lines.append(text)
	var label := _make_label(text, color, 10)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(220, 15)
	container.add_child(label)

func _make_label(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _quest_objective_text(quest: Dictionary, state: String) -> String:
	var item_id := String(quest.get("turn_in_item_id", ""))
	var item_name := ItemDatabase.get_item_name(item_id)
	var npc_name := String(quest.get("npc_name", ""))
	if state == QuestSystem.STATE_COMPLETED:
		return "Completed."
	if state == QuestSystem.STATE_READY:
		return "Bring %s to %s." % [item_name, npc_name]
	var recipe := RecipeDatabase.get_recipe_for_output(item_id)
	if recipe.is_empty():
		return "Find %s for %s." % [item_name, npc_name]
	return "Craft %s for %s." % [item_name, npc_name]

func _state_label(state: String) -> String:
	if state == QuestSystem.STATE_READY:
		return "Ready"
	if state == QuestSystem.STATE_ACTIVE:
		return "In progress"
	if state == QuestSystem.STATE_COMPLETED:
		return "Done"
	return "Not started"

func _state_color(state: String) -> Color:
	if state == QuestSystem.STATE_READY or state == QuestSystem.STATE_COMPLETED:
		return READY_COLOR
	if state == QuestSystem.STATE_ACTIVE:
		return TEXT_COLOR
	return MUTED_COLOR

func _is_recipe_visible(recipe: Dictionary) -> bool:
	var recipe_id := String(recipe.get("id", ""))
	if RecipeKnowledgeSystem.is_recipe_known(recipe_id):
		return true
	var quest_id := String(recipe.get("quest_id", ""))
	return quest_id != "" and _is_quest_recipe_active(quest_id)

func _is_quest_recipe_active(quest_id: String) -> bool:
	var state := QuestSystem.get_quest_state(quest_id)
	return state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY

func _recipe_status_text(recipe: Dictionary) -> String:
	if Inventory.has_ingredients(recipe.get("ingredients", {})):
		return "Ready"
	return "Missing ingredients"

func _ingredient_lines(recipe: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var ids: Array = ingredients.keys()
	ids.sort()
	for id in ids:
		var item_id := String(id)
		var needed := int(ingredients[item_id])
		var have := Inventory.get_quantity(item_id)
		var prefix := "" if have >= needed else "Missing "
		lines.append("%s%s %d/%d" % [prefix, ItemDatabase.get_item_name(item_id), have, needed])
	return lines

func _display_station(station: String) -> String:
	if station == "":
		return "Unknown"
	return station.substr(0, 1).to_upper() + station.substr(1).replace("_", " ")
