extends "res://scripts/core/Interactable.gd"

# Tiny authored-sequence notice board for Mapleton Lane deliveries.

@export var quest_id: String = "camellia_cordial_delivery"
@export var quest_ids: PackedStringArray = PackedStringArray()

var _busy: bool = false

func _ready() -> void:
	super._ready()

func interact() -> void:
	if _busy:
		return
	interacted.emit()
	_busy = true

	var selected_quest_id := _selected_quest_id()
	var quest: Dictionary = QuestDatabase.get_quest(selected_quest_id)
	if quest.is_empty():
		_busy = false
		return

	var state: String = QuestSystem.get_quest_state(selected_quest_id)
	var speaker_name: String = String(quest.get("board_speaker", "Notice Board"))
	if state == QuestSystem.STATE_COMPLETED:
		await _say(speaker_name, _quest_lines(quest, "board_completed_lines", [
			"The board is tidy. Nothing here needs Marigold today.",
		]))
	elif state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
		await _say(speaker_name, _quest_lines(quest, "board_active_lines", [
			"A request note is still pinned here.",
		]))
	elif QuestSystem.is_quest_available(selected_quest_id):
		await _say(speaker_name, _quest_lines(quest, "board_start_lines", [
			"A Mapleton neighbor has posted a request.",
		]))
		QuestSystem.start_quest(selected_quest_id)
	else:
		await _say(speaker_name, _quest_lines(quest, "board_unavailable_lines", [
			"The board is freshly swept, but there are no requests for Marigold today.",
		]))

	_busy = false

func show_prompt(value: bool) -> void:
	super.show_prompt(value and not _busy)

func _say(speaker_name: String, lines: Array) -> void:
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished

func _quest_lines(quest: Dictionary, key: String, fallback: Array) -> Array:
	var value: Variant = quest.get(key, fallback)
	if typeof(value) == TYPE_ARRAY:
		return value
	return fallback

func _selected_quest_id() -> String:
	var ids := _ordered_quest_ids()
	for id in ids:
		var current_quest_id := String(id)
		var state := QuestSystem.get_quest_state(current_quest_id)
		if state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
			return current_quest_id
	for id in ids:
		var current_quest_id := String(id)
		if QuestSystem.is_quest_available(current_quest_id):
			return current_quest_id
	for index in range(ids.size() - 1, -1, -1):
		var current_quest_id := String(ids[index])
		if QuestSystem.get_quest_state(current_quest_id) == QuestSystem.STATE_COMPLETED:
			return current_quest_id
	if not ids.is_empty():
		return String(ids[0])
	return quest_id

func _ordered_quest_ids() -> PackedStringArray:
	if not quest_ids.is_empty():
		return quest_ids
	var ids: PackedStringArray = PackedStringArray()
	if quest_id != "":
		ids.append(quest_id)
	return ids
