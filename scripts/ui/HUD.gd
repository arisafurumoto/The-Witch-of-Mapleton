extends CanvasLayer

# Autoload singleton. Minimal heads-up display for gold, day, save/load toasts,
# and the current tiny quest objective.

@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel
@onready var _day_label: Label = $Panel/Margin/VBox/DayLabel
@onready var _quest_panel: PanelContainer = $QuestPanel
@onready var _quest_title_label: Label = $QuestPanel/Margin/VBox/TitleLabel
@onready var _quest_objective_label: Label = $QuestPanel/Margin/VBox/ObjectiveLabel
@onready var _toast_label: Label = $ToastLabel
@onready var _day_transition: Control = $DayTransition
@onready var _new_day_text: VBoxContainer = $DayTransition/NewDayText
@onready var _new_day_label: Label = $DayTransition/NewDayText/DayLabel

var _toast_tween: Tween
var _day_transition_tween: Tween
var _day_transition_active: bool = false

func _ready() -> void:
	layer = 50
	Inventory.gold_changed.connect(_update_gold)
	Inventory.inventory_changed.connect(_update_quest_tracker)
	DaySystem.day_changed.connect(_update_day)
	SaveSystem.game_saved.connect(_on_game_saved)
	SaveSystem.game_loaded.connect(_on_game_loaded)
	QuestSystem.quest_state_changed.connect(_on_quest_state_changed)
	QuestSystem.quest_started.connect(_on_quest_started)
	QuestSystem.quest_completed.connect(_on_quest_completed)
	_update_gold()
	_update_day(DaySystem.get_day())
	_update_quest_tracker()
	_toast_label.visible = false
	_day_transition.visible = false

func is_day_transition_active() -> bool:
	return _day_transition_active

func fade_to_night() -> void:
	_day_transition_active = true
	_day_transition.visible = true
	_day_transition.modulate = Color(1, 1, 1, 0)
	_new_day_text.visible = false
	_day_transition_tween = create_tween()
	_day_transition_tween.tween_property(_day_transition, "modulate:a", 1.0, 0.55)
	await _day_transition_tween.finished

func reveal_new_day(day: int) -> void:
	_new_day_label.text = "Day %d" % day
	_new_day_text.visible = true
	_new_day_text.modulate = Color(1, 1, 1, 0)
	_day_transition_tween = create_tween()
	_day_transition_tween.tween_property(_new_day_text, "modulate:a", 1.0, 0.25)
	_day_transition_tween.tween_interval(0.9)
	_day_transition_tween.tween_property(_new_day_text, "modulate:a", 0.0, 0.2)
	_day_transition_tween.tween_property(_day_transition, "modulate:a", 0.0, 0.55)
	await _day_transition_tween.finished
	_day_transition.visible = false
	_day_transition_active = false

func _update_gold() -> void:
	_gold_label.text = "Gold: %d" % Inventory.get_gold()

func _update_day(day: int) -> void:
	_day_label.text = "Day %d" % day

func _on_game_saved(_day: int, _gold: int) -> void:
	show_toast("Game saved")

func _on_game_loaded(day: int, _gold: int) -> void:
	show_toast("Loaded Day %d" % day)

func _on_quest_state_changed(_quest_id: String, _state: String) -> void:
	_update_quest_tracker()

func _on_quest_started(quest_id: String) -> void:
	var quest := QuestDatabase.get_quest(quest_id)
	show_toast("Quest started: " + String(quest.get("title", quest_id)))
	_update_quest_tracker()

func _on_quest_completed(quest_id: String) -> void:
	var quest := QuestDatabase.get_quest(quest_id)
	show_toast("Quest complete: " + String(quest.get("title", quest_id)))
	_update_quest_tracker()

func _update_quest_tracker() -> void:
	var quest_id := _get_tracked_quest_id()
	if quest_id == "":
		_quest_panel.visible = false
		return

	var quest := QuestDatabase.get_quest(quest_id)
	var state := QuestSystem.get_quest_state(quest_id)
	_quest_title_label.text = String(quest.get("title", quest_id))
	_quest_objective_label.text = _quest_objective_text(quest, state)
	_quest_panel.visible = true

func _get_tracked_quest_id() -> String:
	for quest_id in QuestDatabase.get_all_ids():
		var id := String(quest_id)
		var state := QuestSystem.get_quest_state(id)
		if state == QuestSystem.STATE_READY:
			return id
	for quest_id in QuestDatabase.get_all_ids():
		var id := String(quest_id)
		var state := QuestSystem.get_quest_state(id)
		if state == QuestSystem.STATE_ACTIVE:
			return id
	return ""

func _quest_objective_text(quest: Dictionary, state: String) -> String:
	var item_id := String(quest.get("turn_in_item_id", ""))
	var item_name := ItemDatabase.get_item_name(item_id)
	var npc_name := String(quest.get("npc_name", "Sage"))
	if state == QuestSystem.STATE_READY:
		return "Bring %s to %s" % [item_name, npc_name]
	var recipe := RecipeDatabase.get_recipe_for_output(item_id)
	if recipe.is_empty() or Inventory.has_item(item_id, int(quest.get("turn_in_quantity", 1))):
		return "Craft %s" % item_name
	return "Craft %s\n%s" % [item_name, _ingredient_progress_text(recipe)]

func show_toast(message: String) -> void:
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_label.text = message
	_toast_label.visible = true
	_toast_label.modulate = Color.WHITE
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.4)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(_hide_toast)

func _hide_toast() -> void:
	_toast_label.visible = false

func _ingredient_progress_text(recipe: Dictionary) -> String:
	var ingredients: Dictionary = recipe.get("ingredients", {})
	var ids: Array = ingredients.keys()
	ids.sort()
	var parts: PackedStringArray = PackedStringArray()
	for id in ids:
		var item_id := String(id)
		var needed: int = int(ingredients[item_id])
		var have: int = mini(Inventory.get_quantity(item_id), needed)
		parts.append("%s %d/%d" % [ItemDatabase.get_item_name(item_id), have, needed])
	return "\n".join(parts)
