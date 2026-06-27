extends "res://scripts/core/Interactable.gd"

# One-request notice board for the Mapleton Lane delivery slice.

@export var quest_id: String = "camellia_cordial_delivery"

var _busy: bool = false

func _ready() -> void:
	super._ready()

func interact() -> void:
	if _busy:
		return
	interacted.emit()
	_busy = true

	var quest: Dictionary = QuestDatabase.get_quest(quest_id)
	if quest.is_empty():
		_busy = false
		return

	var state: String = QuestSystem.get_quest_state(quest_id)
	var speaker_name: String = String(quest.get("board_speaker", "Notice Board"))
	if state == QuestSystem.STATE_COMPLETED:
		await _say(speaker_name, _quest_lines(quest, "board_completed_lines", [
			"The board is tidy. Nothing here needs Marigold today.",
		]))
	elif state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
		await _say(speaker_name, _quest_lines(quest, "board_active_lines", [
			"Camellia's note is still pinned here.",
		]))
	elif QuestSystem.is_quest_available(quest_id):
		await _say(speaker_name, _quest_lines(quest, "board_start_lines", [
			"Camellia has posted a request.",
		]))
		QuestSystem.start_quest(quest_id)
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
