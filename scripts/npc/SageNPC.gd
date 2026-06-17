extends "res://scripts/core/Interactable.gd"

# Sage's one-request vertical-slice behavior. He appears from day 1, then
# leaves once his quest is done.

@export var quest_id: String = "sage_first_request"
@export var exit_offset: Vector2 = Vector2(0, -48)

var _busy: bool = false
var _present: bool = true
var _home_position: Vector2 = Vector2.ZERO
var _leaving: bool = false

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()
	_home_position = position
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
		_leaving = true
		if QuestSystem.complete_quest(quest_id):
			await _leave_shop()
		else:
			_leaving = false
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
	if _leaving:
		return
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

func _leave_shop() -> void:
	_busy = true
	super.show_prompt(false)
	var tween := create_tween()
	tween.tween_property(self, "position", _home_position + exit_offset, 0.45)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	await tween.finished
	_set_present(false)
	position = _home_position
	modulate = Color.WHITE
	_leaving = false
	_busy = false

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	if _collision_shape:
		_collision_shape.disabled = not value
	if not value:
		super.show_prompt(false)
