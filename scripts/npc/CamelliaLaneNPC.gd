extends "res://scripts/core/Interactable.gd"

# Camellia's static Mapleton Lane delivery interaction. This is intentionally
# separate from her shop visitor script so the slice does not grow an NPC framework.

@export var quest_id: String = "camellia_cordial_delivery"
@export var quest_ids: PackedStringArray = PackedStringArray()
@export var home_facing: String = "west"

const DIRECTIONS := [
	"east", "south_east", "south", "south_west",
	"west", "north_west", "north", "north_east",
]

var _busy: bool = false

@onready var _sprite: AnimatedSprite2D = $Visual

func _ready() -> void:
	super._ready()
	_sprite.play("idle_" + home_facing)

func interact() -> void:
	if _busy:
		return
	interacted.emit()
	_busy = true
	_face_player()

	var selected_quest_id: String = _selected_quest_id()
	var quest: Dictionary = QuestDatabase.get_quest(selected_quest_id)
	if quest.is_empty():
		_busy = false
		return

	var state: String = QuestSystem.get_quest_state(selected_quest_id)
	var speaker_name: String = String(quest.get("npc_name", "Camellia"))
	if state == QuestSystem.STATE_COMPLETED:
		await _say(speaker_name, _quest_lines(quest, "post_complete_lines", [
			"The cordial was just right. Mapleton's lunch crowd is already curious.",
		]))
	elif QuestSystem.can_turn_in(selected_quest_id):
		await _say(speaker_name, _quest_lines(quest, "complete_lines", []))
		QuestSystem.complete_quest(selected_quest_id)
	elif state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
		await _say(speaker_name, _quest_lines(quest, "reminder_lines", []))
	else:
		await _say(speaker_name, _quest_lines(quest, "not_started_lines", [
			"I pinned a small request to the notice board, if you have time for town errands.",
		]))

	_busy = false

func show_prompt(value: bool) -> void:
	super.show_prompt(value and not _busy)

func get_selected_quest_id() -> String:
	return _selected_quest_id()

func _say(speaker_name: String, lines: Array) -> void:
	if lines.is_empty():
		return
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished

func _quest_lines(quest: Dictionary, key: String, fallback: Array) -> Array:
	var value: Variant = quest.get(key, fallback)
	if typeof(value) == TYPE_ARRAY:
		return value
	return fallback

func _selected_quest_id() -> String:
	var ids: PackedStringArray = _ordered_quest_ids()
	for id in ids:
		var current_quest_id: String = String(id)
		var state: String = QuestSystem.get_quest_state(current_quest_id)
		if state == QuestSystem.STATE_ACTIVE or state == QuestSystem.STATE_READY:
			return current_quest_id
	for id in ids:
		var current_quest_id: String = String(id)
		if QuestSystem.is_quest_available(current_quest_id):
			return current_quest_id
	for index in range(ids.size() - 1, -1, -1):
		var current_quest_id: String = String(ids[index])
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

func _face_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var direction: String = _direction_for(player.global_position - global_position)
	_sprite.play("idle_" + direction)

func _direction_for(delta_position: Vector2) -> String:
	var index: int = int(round(rad_to_deg(delta_position.angle()) / 45.0))
	index = (index % 8 + 8) % 8
	return DIRECTIONS[index]
