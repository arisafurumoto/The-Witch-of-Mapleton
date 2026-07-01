extends "res://scripts/core/Door.gd"

# Door variant that stays closed until a specific quest is completed.

@export var required_completed_quest_id: String = ""
@export var locked_speaker: String = "Marigold"
@export_multiline var locked_dialogue: String = "The path is still tangled with sleepy roots."

var _busy: bool = false

func interact() -> void:
	if is_unlocked():
		super.interact()
		return
	if _busy:
		return
	interacted.emit()
	_busy = true

	var lines: Array = _locked_lines()
	if not lines.is_empty():
		DialogueBox.show_dialogue(locked_speaker, lines)
		if DialogueBox.is_active():
			await DialogueBox.dialogue_finished
	_busy = false

func show_prompt(value: bool) -> void:
	super.show_prompt(value and not _busy)

func is_unlocked() -> bool:
	if required_completed_quest_id == "":
		return true
	return QuestSystem.get_quest_state(required_completed_quest_id) == QuestSystem.STATE_COMPLETED

func _locked_lines() -> Array:
	var text: String = locked_dialogue.strip_edges()
	if text == "":
		return []
	return text.split("\n", false)
