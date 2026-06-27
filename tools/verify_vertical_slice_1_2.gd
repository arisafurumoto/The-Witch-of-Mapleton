extends SceneTree

const MAPLETON_LANE_SCENE := "res://scenes/world/MapletonLane.tscn"
const CAMELLIA_DELIVERY_QUEST := "camellia_cordial_delivery"
const SAGE_RESTOCK_QUEST := "sage_seedling_restock"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_quest_data()
	_check_scene_wiring()
	await _check_board_sequence_and_turn_in()
	if _failures.is_empty():
		print("Vertical Slice 1.2 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_quest_data() -> void:
	var quest_database: Node = root.get_node("QuestDatabase")
	var quest: Dictionary = quest_database.call("get_quest", SAGE_RESTOCK_QUEST)
	_check(not quest.is_empty(), "Sage restock quest is missing")
	_check(String(quest.get("title", "")) == "A Gentle Restock", "Sage restock quest title is incorrect")
	_check(String(quest.get("npc_name", "")) == "Sage", "Sage restock quest NPC is incorrect")
	_check(String(quest.get("turn_in_item_id", "")) == "root_wake_tonic", "Sage restock quest turn-in item is incorrect")
	_check(int(quest.get("turn_in_quantity", 0)) == 1, "Sage restock quest turn-in quantity is not 1")
	_check(int(quest.get("reward_gold", 0)) == 45, "Sage restock quest reward gold is not 45")
	_check(quest_database.call("get_minimum_day", SAGE_RESTOCK_QUEST) == 4, "Sage restock quest minimum day is not 4")
	var required_ids: Array = quest_database.call("get_required_quest_ids", SAGE_RESTOCK_QUEST)
	_check(required_ids.has(CAMELLIA_DELIVERY_QUEST), "Sage restock quest does not require Camellia's delivery")

func _check_scene_wiring() -> void:
	_check(ResourceLoader.exists(MAPLETON_LANE_SCENE), "MapletonLane.tscn does not exist")
	var lane := _instantiate_scene(MAPLETON_LANE_SCENE)
	if lane == null:
		return

	_check(lane.has_node("PlantStall"), "Mapleton Lane is missing Sage's plant stall")
	_check(lane.has_node("PlantStall/CollisionShape2D"), "Sage plant stall has no collision")
	_check(lane.has_node("Sage"), "Mapleton Lane is missing lane Sage")
	_check(lane.has_node("Sage/Visual"), "Lane Sage has no visual sprite")
	_check(lane.has_node("Sage/CollisionShape2D"), "Lane Sage has no interaction collision")

	var board := lane.get_node("NoticeBoard")
	_check(String(board.get("quest_id")) == CAMELLIA_DELIVERY_QUEST, "Notice board no longer keeps its compatibility quest_id")
	var board_quest_ids: PackedStringArray = board.get("quest_ids")
	_check(board_quest_ids.has(CAMELLIA_DELIVERY_QUEST), "Notice board quest list is missing Camellia delivery")
	_check(board_quest_ids.has(SAGE_RESTOCK_QUEST), "Notice board quest list is missing Sage restock")

	var sage := lane.get_node("Sage")
	_check(String(sage.get("quest_id")) == SAGE_RESTOCK_QUEST, "Lane Sage is not wired to the Sage restock quest")
	var sage_visual := lane.get_node("Sage/Visual") as AnimatedSprite2D
	_check(sage_visual.sprite_frames != null, "Lane Sage has no SpriteFrames")
	if sage_visual.sprite_frames != null:
		_check(sage_visual.sprite_frames.resource_path == "res://art/characters/npcs/sage/Sage.tres", "Lane Sage does not use the existing Sage SpriteFrames")

	lane.free()

func _check_board_sequence_and_turn_in() -> void:
	var error := change_scene_to_file(MAPLETON_LANE_SCENE)
	_check(error == OK, "Could not load Mapleton Lane for 1.2 flow")
	await process_frame
	await process_frame
	if current_scene == null:
		_failures.append("Mapleton Lane did not become the current scene")
		return

	var board := current_scene.get_node("NoticeBoard")
	var sage := current_scene.get_node("Sage")
	var inventory: Node = root.get_node("Inventory")
	var quest_system: Node = root.get_node("QuestSystem")
	var day_system: Node = root.get_node("DaySystem")
	var notebook: Node = root.get_node("NotebookPanel")

	inventory.call("load_from", {}, 0)
	quest_system.call("load_from", {})
	day_system.call("apply_state", 4, {})
	_check(not bool(quest_system.call("is_quest_available", SAGE_RESTOCK_QUEST)), "Sage restock is available before Camellia delivery is complete")

	quest_system.call("load_from", {
		"sage_first_request": "completed",
		"camellia_first_request": "completed",
	})
	day_system.call("apply_state", 3, {})
	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", CAMELLIA_DELIVERY_QUEST)) == "active", "Notice board no longer starts Camellia delivery first")

	quest_system.call("load_from", {
		"sage_first_request": "completed",
		"camellia_first_request": "completed",
		CAMELLIA_DELIVERY_QUEST: "completed",
	})
	day_system.call("apply_state", 3, {})
	_check(not bool(quest_system.call("is_quest_available", SAGE_RESTOCK_QUEST)), "Sage restock is available before Day 4")
	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", SAGE_RESTOCK_QUEST)) == "not_started", "Notice board started Sage restock before Day 4")

	day_system.call("apply_state", 4, {})
	_check(bool(quest_system.call("is_quest_available", SAGE_RESTOCK_QUEST)), "Sage restock is not available on Day 4 after Camellia delivery")
	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", SAGE_RESTOCK_QUEST)) == "active", "Notice board did not start Sage restock")

	notebook.call("open")
	await process_frame
	var open_quest_ids := _as_string_array(notebook.call("get_open_quest_ids"))
	_check(open_quest_ids.has(SAGE_RESTOCK_QUEST), "Notebook does not show active Sage restock")
	_check(String(notebook.call("get_quest_row_text", SAGE_RESTOCK_QUEST)).contains("Root-Wake Tonic 0/1"), "Notebook does not show Sage restock 0/1 tonic progress")

	inventory.call("add_item", "root_wake_tonic", 1)
	await process_frame
	_check(String(quest_system.call("get_quest_state", SAGE_RESTOCK_QUEST)) == "ready_to_turn_in", "Sage restock did not become ready with one tonic")
	_check(String(notebook.call("get_quest_row_text", SAGE_RESTOCK_QUEST)).contains("Root-Wake Tonic 1/1"), "Notebook does not show Sage restock 1/1 tonic progress")
	notebook.call("close")

	var starting_gold: int = int(inventory.call("get_gold"))
	sage.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", SAGE_RESTOCK_QUEST)) == "completed", "Lane Sage did not complete the restock quest")
	_check(int(inventory.call("get_quantity", "root_wake_tonic")) == 0, "Sage restock did not consume exactly one tonic")
	_check(int(inventory.call("get_gold")) == starting_gold + 45, "Sage restock did not award 45 gold")

	var save_data: Dictionary = quest_system.call("get_save_data")
	quest_system.call("load_from", {})
	_check(String(quest_system.call("get_quest_state", SAGE_RESTOCK_QUEST)) == "not_started", "Sage restock reset check failed before save round trip")
	quest_system.call("load_from", save_data)
	_check(String(quest_system.call("get_quest_state", SAGE_RESTOCK_QUEST)) == "completed", "Completed Sage restock did not survive quest save-data round trip")

func _finish_dialogue() -> void:
	var dialogue: Node = root.get_node("DialogueBox")
	for _index in range(10):
		await process_frame
		if not bool(dialogue.call("is_active")):
			await process_frame
			return
		dialogue.call("_advance")
	_check(not bool(dialogue.call("is_active")), "Dialogue did not close during verification")

func _as_string_array(value: Variant) -> Array[String]:
	var ids: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return ids
	for item in value:
		ids.append(String(item))
	return ids

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
