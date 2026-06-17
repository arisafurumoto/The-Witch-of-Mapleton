extends CanvasLayer

# Autoload singleton. Minimal heads-up display for gold, day, save/load toasts,
# and the current tiny quest objective.

@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel
@onready var _day_label: Label = $Panel/Margin/VBox/DayLabel
@onready var _quest_panel: PanelContainer = $QuestPanel
@onready var _quest_title_label: Label = $QuestPanel/Margin/VBox/TitleLabel
@onready var _quest_objective_label: Label = $QuestPanel/Margin/VBox/ObjectiveLabel
@onready var _toast_label: Label = $ToastLabel

var _toast_tween: Tween

func _ready() -> void:
	layer = 50
	Inventory.gold_changed.connect(_update_gold)
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

func _update_gold() -> void:
	_gold_label.text = "Gold: %d" % Inventory.get_gold()

func _update_day(day: int) -> void:
	_day_label.text = "Day %d" % day

func _on_game_saved(_day: int, _gold: int) -> void:
	_show_toast("Game saved")

func _on_game_loaded(day: int, _gold: int) -> void:
	_show_toast("Loaded Day %d" % day)

func _on_quest_state_changed(_quest_id: String, _state: String) -> void:
	_update_quest_tracker()

func _on_quest_started(quest_id: String) -> void:
	var quest := QuestDatabase.get_quest(quest_id)
	_show_toast("Quest started: " + String(quest.get("title", quest_id)))
	_update_quest_tracker()

func _on_quest_completed(quest_id: String) -> void:
	var quest := QuestDatabase.get_quest(quest_id)
	_show_toast("Quest complete: " + String(quest.get("title", quest_id)))
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
	return "Craft %s" % item_name

func _show_toast(message: String) -> void:
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
