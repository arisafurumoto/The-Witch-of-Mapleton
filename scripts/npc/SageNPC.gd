extends "res://scripts/core/Interactable.gd"

# Sage's one-request vertical-slice behavior. He appears from day 1, then
# leaves once his quest is done.

@export var quest_id: String = "sage_first_request"

var _busy: bool = false
var _present: bool = true

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()
	DaySystem.day_changed.connect(_on_world_state_changed)
	QuestSystem.quest_state_changed.connect(_on_quest_state_changed)
	_on_world_state_changed(DaySystem.get_day())

func interact() -> void:
	if _busy or not _present:
		return
	interacted.emit()
	_busy = true
	var quest := QuestDatabase.get_quest(quest_id)
	if quest.is_empty():
		_busy = false
		return

	var state := QuestSystem.get_quest_state(quest_id)
	var speaker_name := String(quest.get("npc_name", "Sage"))
	if state == QuestSystem.STATE_NOT_STARTED:
		await _say(speaker_name, quest.get("start_lines", []))
		QuestSystem.start_quest(quest_id)
	elif QuestSystem.can_turn_in(quest_id):
		await _say(speaker_name, quest.get("complete_lines", []))
		if QuestSystem.complete_quest(quest_id):
			_set_present(false)
	else:
		await _say(speaker_name, quest.get("reminder_lines", []))

	_busy = false

func show_prompt(value: bool) -> void:
	super.show_prompt(value and _present and not _busy)

func _say(speaker_name: String, lines: Array) -> void:
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished

func _on_world_state_changed(_day: int) -> void:
	_refresh_presence()

func _on_quest_state_changed(changed_quest_id: String, _state: String) -> void:
	if changed_quest_id == quest_id:
		_refresh_presence()

func _refresh_presence() -> void:
	var state := QuestSystem.get_quest_state(quest_id)
	if state == QuestSystem.STATE_COMPLETED:
		_set_present(false)
		return
	if state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
		_set_present(true)
		return
	_set_present(_can_offer_quest())

func _can_offer_quest() -> bool:
	return DaySystem.get_day() >= 1

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	if _collision_shape:
		_collision_shape.disabled = not value
	if not value:
		super.show_prompt(false)
