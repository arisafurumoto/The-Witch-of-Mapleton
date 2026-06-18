extends Node

# Autoload singleton. Tracks a tiny authored quest state dictionary.
# States are intentionally simple: not_started, active, ready_to_turn_in, completed.

signal quest_state_changed(quest_id: String, state: String)
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)

const STATE_NOT_STARTED := "not_started"
const STATE_ACTIVE := "active"
const STATE_READY := "ready_to_turn_in"
const STATE_COMPLETED := "completed"

var _quest_states: Dictionary = {}

func _ready() -> void:
	Inventory.inventory_changed.connect(_update_ready_states)

func get_quest_state(quest_id: String) -> String:
	return String(_quest_states.get(quest_id, STATE_NOT_STARTED))

func start_quest(quest_id: String) -> void:
	if not QuestDatabase.has_quest(quest_id):
		return
	if get_quest_state(quest_id) != STATE_NOT_STARTED:
		return
	_set_quest_state(quest_id, STATE_ACTIVE)
	_update_ready_state(quest_id)
	quest_started.emit(quest_id)

func can_turn_in(quest_id: String) -> bool:
	var state := get_quest_state(quest_id)
	if state != STATE_ACTIVE and state != STATE_READY:
		return false
	var quest := QuestDatabase.get_quest(quest_id)
	if quest.is_empty():
		return false
	var item_id := String(quest.get("turn_in_item_id", ""))
	var quantity := int(quest.get("turn_in_quantity", 1))
	return Inventory.has_item(item_id, quantity)

func complete_quest(quest_id: String) -> bool:
	if not can_turn_in(quest_id):
		return false
	var quest := QuestDatabase.get_quest(quest_id)
	var item_id := String(quest.get("turn_in_item_id", ""))
	var quantity := int(quest.get("turn_in_quantity", 1))
	if not Inventory.remove_item(item_id, quantity):
		return false

	var reward_gold := int(quest.get("reward_gold", 0))
	if reward_gold > 0:
		Inventory.add_gold(reward_gold)
	var reward_items: Dictionary = quest.get("reward_items", {})
	for reward_item_id in reward_items:
		Inventory.add_item(String(reward_item_id), int(reward_items[reward_item_id]))
	_set_quest_state(quest_id, STATE_COMPLETED)
	quest_completed.emit(quest_id)
	for recipe_id in quest.get("reward_recipes", []):
		RecipeKnowledgeSystem.unlock_recipe(String(recipe_id))
	return true

func get_save_data() -> Dictionary:
	return _quest_states.duplicate()

func load_from(data: Dictionary) -> void:
	_quest_states.clear()
	for quest_id in data:
		var state := String(data[quest_id])
		if _is_valid_state(state) and QuestDatabase.has_quest(String(quest_id)):
			_quest_states[String(quest_id)] = state
	_update_ready_states()

func _update_ready_states() -> void:
	for quest_id in _quest_states.keys():
		_update_ready_state(String(quest_id))

func _update_ready_state(quest_id: String) -> void:
	var state := get_quest_state(quest_id)
	if state != STATE_ACTIVE and state != STATE_READY:
		return
	var next_state := STATE_READY if can_turn_in(quest_id) else STATE_ACTIVE
	if next_state != state:
		_set_quest_state(quest_id, next_state)

func _set_quest_state(quest_id: String, state: String) -> void:
	_quest_states[quest_id] = state
	quest_state_changed.emit(quest_id, state)

func _is_valid_state(state: String) -> bool:
	return state == STATE_NOT_STARTED or state == STATE_ACTIVE or state == STATE_READY or state == STATE_COMPLETED
