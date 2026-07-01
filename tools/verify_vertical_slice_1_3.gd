extends SceneTree

const FOREST_CLEARING_SCENE := "res://scenes/world/ForestClearing.tscn"
const FOREST_PATH_SCENE := "res://scenes/world/ForestPath.tscn"
const MAPLETON_LANE_SCENE := "res://scenes/world/MapletonLane.tscn"
const CAMELLIA_DELIVERY_QUEST := "camellia_cordial_delivery"
const SAGE_RESTOCK_QUEST := "sage_seedling_restock"
const BROOKMINT_QUEST := "camellia_brookmint_request"
const BROOKMINT_RECIPE := "brookmint_tea"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_data()
	_check_scene_wiring()
	await _check_transition_cat_placement()
	await _check_locked_transition()
	await _check_gatherable_and_save_scene()
	await _check_board_notebook_crafting_and_turn_in()
	if _failures.is_empty():
		print("Vertical Slice 1.3 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_data() -> void:
	var item_database: Node = root.get_node("ItemDatabase")
	var recipe_database: Node = root.get_node("RecipeDatabase")
	var quest_database: Node = root.get_node("QuestDatabase")

	_check(bool(item_database.call("has_item", "brookmint")), "Brookmint item is missing")
	_check(bool(item_database.call("has_item", BROOKMINT_RECIPE)), "Brookmint Tea item is missing")
	_check(String(item_database.call("get_item_name", "brookmint")) == "Brookmint", "Brookmint display name is incorrect")
	_check(String(item_database.call("get_item_name", BROOKMINT_RECIPE)) == "Brookmint Tea", "Brookmint Tea display name is incorrect")
	_check(int(item_database.call("get_sell_price", BROOKMINT_RECIPE)) == 30, "Brookmint Tea sell price is not 30")

	var recipe: Dictionary = recipe_database.call("get_recipe", BROOKMINT_RECIPE)
	_check(not recipe.is_empty(), "Brookmint Tea recipe is missing")
	_check(String(recipe.get("station", "")) == "cauldron", "Brookmint Tea is not a cauldron recipe")
	_check(String(recipe.get("quest_id", "")) == BROOKMINT_QUEST, "Brookmint Tea recipe is not gated by Camellia's Brookmint quest")
	_check(not bool(recipe.get("known_by_default", true)), "Brookmint Tea is known by default")
	var ingredients: Dictionary = recipe.get("ingredients", {})
	_check(int(ingredients.get("brookmint", 0)) == 2, "Brookmint Tea needs the wrong Brookmint count")
	_check(int(ingredients.get("forest_water", 0)) == 1, "Brookmint Tea needs the wrong Forest Water count")
	var output: Dictionary = recipe.get("output", {})
	_check(String(output.get("item_id", "")) == BROOKMINT_RECIPE, "Brookmint Tea recipe outputs the wrong item")

	var quest: Dictionary = quest_database.call("get_quest", BROOKMINT_QUEST)
	_check(not quest.is_empty(), "Camellia Brookmint quest is missing")
	_check(String(quest.get("title", "")) == "A Fresh Pot", "Brookmint quest title is incorrect")
	_check(String(quest.get("npc_name", "")) == "Camellia", "Brookmint quest NPC is incorrect")
	_check(String(quest.get("turn_in_item_id", "")) == BROOKMINT_RECIPE, "Brookmint quest turn-in item is incorrect")
	_check(int(quest.get("turn_in_quantity", 0)) == 1, "Brookmint quest turn-in quantity is not 1")
	_check(int(quest.get("reward_gold", 0)) == 80, "Brookmint quest reward gold is not 80")
	_check(quest_database.call("get_minimum_day", BROOKMINT_QUEST) == 5, "Brookmint quest minimum day is not 5")
	var required_ids: Array = quest_database.call("get_required_quest_ids", BROOKMINT_QUEST)
	_check(required_ids.has(SAGE_RESTOCK_QUEST), "Brookmint quest does not require Sage restock")
	var reward_recipes: Array = quest.get("reward_recipes", [])
	_check(reward_recipes.has(BROOKMINT_RECIPE), "Brookmint quest does not reward the Brookmint Tea recipe")

func _check_scene_wiring() -> void:
	_check(ResourceLoader.exists(FOREST_CLEARING_SCENE), "ForestClearing.tscn does not exist")
	_check(ResourceLoader.exists(FOREST_PATH_SCENE), "ForestPath.tscn does not exist")
	var clearing := _instantiate_scene(FOREST_CLEARING_SCENE)
	var path := _instantiate_scene(FOREST_PATH_SCENE)
	var lane := _instantiate_scene(MAPLETON_LANE_SCENE)
	if clearing == null or path == null or lane == null:
		return

	_check(clearing.has_node("ForestPathDoor"), "Forest Clearing is missing the locked forest path door")
	var path_door: Node = clearing.get_node("ForestPathDoor")
	_check(path_door.has_method("is_unlocked"), "Forest path door does not use QuestLockedDoor behavior")
	_check(String(path_door.get("target_scene")) == FOREST_PATH_SCENE, "Forest path door targets the wrong scene")
	_check(bool(path_door.get("use_target_player_position")), "Forest path door does not set explicit arrival")
	_check(path_door.get("target_player_position") == Vector2(88, 252), "Forest path arrival position is incorrect")
	_check(String(path_door.get("target_player_facing")) == "east", "Forest path arrival facing is incorrect")
	_check(String(path_door.get("required_completed_quest_id")) == SAGE_RESTOCK_QUEST, "Forest path door uses the wrong unlock quest")

	_check(path.has_node("Player"), "Forest Path is missing Player")
	_check(path.has_node("Player/Camera2D"), "Forest Path is missing the player camera")
	_check(path.has_node("Cat"), "Forest Path is missing Saffron")
	_check(path.has_node("Boundaries/CollTop"), "Forest Path is missing top boundary collision")
	_check(path.has_node("Boundaries/CollBottom"), "Forest Path is missing bottom boundary collision")
	_check(path.has_node("Boundaries/CollLeft"), "Forest Path is missing left boundary collision")
	_check(path.has_node("Boundaries/CollRight"), "Forest Path is missing right boundary collision")
	_check(path.has_node("ReturnDoor"), "Forest Path is missing ReturnDoor")
	_check(path.has_node("BrookmintPatchA"), "Forest Path is missing the first Brookmint patch")
	_check(path.has_node("BrookmintPatchB"), "Forest Path is missing the second Brookmint patch")

	var camera := path.get_node("Player/Camera2D") as Camera2D
	_check(camera.limit_right == 720, "Forest Path camera right limit is incorrect")
	_check(camera.limit_bottom == 480, "Forest Path camera bottom limit is incorrect")

	var return_door: Node = path.get_node("ReturnDoor")
	_check(String(return_door.get("target_scene")) == FOREST_CLEARING_SCENE, "Forest Path ReturnDoor targets the wrong scene")
	_check(bool(return_door.get("use_target_player_position")), "Forest Path ReturnDoor does not set explicit return")
	_check(return_door.get("target_player_position") == Vector2(780, 300), "Forest Path return position is incorrect")
	_check(String(return_door.get("target_player_facing")) == "west", "Forest Path return facing is incorrect")

	for patch_name in ["BrookmintPatchA", "BrookmintPatchB"]:
		var patch: Node = path.get_node(String(patch_name))
		_check(String(patch.get("item_id")) == "brookmint", "%s gives the wrong item" % patch_name)
		_check(int(patch.get("item_quantity")) == 1, "%s gives the wrong quantity" % patch_name)
		_check(String(patch.get("gatherable_id")).begins_with("brookmint_patch_"), "%s has an unstable gatherable id" % patch_name)

	var board: Node = lane.get_node("NoticeBoard")
	var board_quest_ids: PackedStringArray = board.get("quest_ids")
	_check(board_quest_ids.has(CAMELLIA_DELIVERY_QUEST), "Notice board quest list lost Camellia delivery")
	_check(board_quest_ids.has(SAGE_RESTOCK_QUEST), "Notice board quest list lost Sage restock")
	_check(board_quest_ids.has(BROOKMINT_QUEST), "Notice board quest list is missing Brookmint request")

	var camellia: Node = lane.get_node("Camellia")
	_check(String(camellia.get("quest_id")) == CAMELLIA_DELIVERY_QUEST, "Lane Camellia no longer keeps its compatibility quest_id")
	var camellia_quest_ids: PackedStringArray = camellia.get("quest_ids")
	_check(camellia_quest_ids.has(CAMELLIA_DELIVERY_QUEST), "Lane Camellia quest list lost delivery")
	_check(camellia_quest_ids.has(BROOKMINT_QUEST), "Lane Camellia quest list is missing Brookmint request")

	clearing.free()
	path.free()
	lane.free()

func _check_transition_cat_placement() -> void:
	root.set_meta("transition_from_scene", FOREST_CLEARING_SCENE)
	root.set_meta("target_player_position", Vector2(88, 252))
	root.set_meta("target_player_facing", "east")
	var path := _instantiate_scene(FOREST_PATH_SCENE)
	if path == null:
		_clear_transition_meta()
		return
	root.add_child(path)
	await process_frame
	var path_cat := path.get_node("Cat") as Node2D
	_check(path_cat.global_position.distance_to(Vector2(40, 252)) < 4.0, "Saffron does not arrive behind Marigold on the forest path")
	path.queue_free()
	await process_frame
	_clear_transition_meta()

	root.set_meta("transition_from_scene", FOREST_PATH_SCENE)
	root.set_meta("target_player_position", Vector2(780, 300))
	root.set_meta("target_player_facing", "west")
	var clearing := _instantiate_scene(FOREST_CLEARING_SCENE)
	if clearing == null:
		_clear_transition_meta()
		return
	root.add_child(clearing)
	await process_frame
	var clearing_cat := clearing.get_node("Cat") as Node2D
	_check(clearing_cat.global_position.distance_to(Vector2(828, 300)) < 4.0, "Saffron does not arrive behind Marigold when returning to the clearing")
	clearing.queue_free()
	await process_frame
	_clear_transition_meta()

func _check_locked_transition() -> void:
	var quest_system: Node = root.get_node("QuestSystem")
	var day_system: Node = root.get_node("DaySystem")
	quest_system.call("load_from", {})
	day_system.call("apply_state", 5, {})

	var error := change_scene_to_file(FOREST_CLEARING_SCENE)
	_check(error == OK, "Could not load ForestClearing for locked transition")
	await process_frame
	await process_frame
	if current_scene == null:
		_failures.append("ForestClearing did not become the current scene")
		return
	var door: Node = current_scene.get_node("ForestPathDoor")
	_check(not bool(door.call("is_unlocked")), "Forest path door is unlocked before Sage restock is complete")
	door.call("interact")
	await _finish_dialogue()
	_check(current_scene != null and current_scene.scene_file_path == FOREST_CLEARING_SCENE, "Locked forest path changed scenes")

	quest_system.call("load_from", {SAGE_RESTOCK_QUEST: "completed"})
	_check(bool(door.call("is_unlocked")), "Forest path door is not unlocked after Sage restock is complete")
	door.call("interact")
	await process_frame
	await process_frame
	_check(current_scene != null and current_scene.scene_file_path == FOREST_PATH_SCENE, "Unlocked forest path did not change to ForestPath")

func _check_gatherable_and_save_scene() -> void:
	var error := change_scene_to_file(FOREST_PATH_SCENE)
	_check(error == OK, "Could not load ForestPath for gatherable check")
	await process_frame
	await process_frame
	if current_scene == null:
		_failures.append("ForestPath did not become the current scene")
		return

	var inventory: Node = root.get_node("Inventory")
	var day_system: Node = root.get_node("DaySystem")
	inventory.call("load_from", {}, 0)
	day_system.call("apply_state", 5, {})
	var patch: Node = current_scene.get_node("BrookmintPatchA")
	patch.call("interact")
	await process_frame
	_stop_audio_players()
	await process_frame
	_check(int(inventory.call("get_quantity", "brookmint")) == 1, "Gathering Brookmint did not add it to inventory")
	_check(bool(patch.get("depleted")), "Brookmint patch did not deplete after gathering")
	_check(bool(day_system.call("is_gatherable_depleted", "brookmint_patch_001")), "Brookmint patch depletion was not saved in DaySystem")

	var player := current_scene.get_node("Player") as Node2D
	player.global_position = Vector2(300, 244)
	var save_system: Node = root.get_node("SaveSystem")
	_check(String(save_system.call("_get_current_scene_path")) == FOREST_PATH_SCENE, "SaveSystem does not report the ForestPath scene path")
	var player_position: Dictionary = save_system.call("_get_player_position_data")
	_check(absf(float(player_position.get("x", 0.0)) - 300.0) < 0.01, "SaveSystem does not capture ForestPath player x position")
	_check(absf(float(player_position.get("y", 0.0)) - 244.0) < 0.01, "SaveSystem does not capture ForestPath player y position")

func _check_board_notebook_crafting_and_turn_in() -> void:
	var error := change_scene_to_file(MAPLETON_LANE_SCENE)
	_check(error == OK, "Could not load Mapleton Lane for Brookmint flow")
	await process_frame
	await process_frame
	if current_scene == null:
		_failures.append("Mapleton Lane did not become the current scene")
		return

	var inventory: Node = root.get_node("Inventory")
	var quest_system: Node = root.get_node("QuestSystem")
	var day_system: Node = root.get_node("DaySystem")
	var recipe_knowledge: Node = root.get_node("RecipeKnowledgeSystem")
	var crafting_system: Node = root.get_node("CraftingSystem")
	var notebook: Node = root.get_node("NotebookPanel")
	var board: Node = current_scene.get_node("NoticeBoard")
	var camellia: Node = current_scene.get_node("Camellia")

	inventory.call("load_from", {}, 0)
	recipe_knowledge.call("load_from", [])
	quest_system.call("load_from", {
		"sage_first_request": "completed",
		"camellia_first_request": "completed",
		CAMELLIA_DELIVERY_QUEST: "completed",
		SAGE_RESTOCK_QUEST: "completed",
	})
	day_system.call("apply_state", 4, {})
	_check(not bool(quest_system.call("is_quest_available", BROOKMINT_QUEST)), "Brookmint request is available before Day 5")
	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", BROOKMINT_QUEST)) == "not_started", "Notice board started Brookmint request before Day 5")

	day_system.call("apply_state", 5, {})
	_check(bool(quest_system.call("is_quest_available", BROOKMINT_QUEST)), "Brookmint request is not available on Day 5 after Sage restock")
	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", BROOKMINT_QUEST)) == "active", "Notice board did not start Brookmint request")
	_check(String(camellia.call("get_selected_quest_id")) == BROOKMINT_QUEST, "Lane Camellia does not select the active Brookmint request")
	_check(not bool(recipe_knowledge.call("is_recipe_known", BROOKMINT_RECIPE)), "Brookmint Tea is permanently known before quest completion")

	notebook.call("open")
	await process_frame
	var open_quest_ids := _as_string_array(notebook.call("get_open_quest_ids"))
	_check(open_quest_ids.has(BROOKMINT_QUEST), "Notebook does not show active Brookmint request")
	_check(String(notebook.call("get_quest_row_text", BROOKMINT_QUEST)).contains("Brookmint Tea 0/1"), "Notebook does not show Brookmint Tea 0/1 progress")
	var visible_recipe_ids := _as_string_array(notebook.call("get_visible_recipe_ids"))
	_check(visible_recipe_ids.has(BROOKMINT_RECIPE), "Notebook does not show quest-active Brookmint Tea recipe")
	notebook.call("_select_recipe", BROOKMINT_RECIPE)
	await process_frame
	var detail := String(notebook.call("get_recipe_detail_text"))
	_check(detail.contains("Status: Missing ingredients"), "Brookmint Tea detail does not show missing status")
	_check(detail.contains("Brookmint 0/2"), "Brookmint Tea detail does not show Brookmint 0/2")
	_check(detail.contains("Forest Water 0/1"), "Brookmint Tea detail does not show Forest Water 0/1")

	inventory.call("add_item", "brookmint", 2)
	inventory.call("add_item", "forest_water", 1)
	await process_frame
	detail = String(notebook.call("get_recipe_detail_text"))
	_check(detail.contains("Status: Ready"), "Brookmint Tea detail does not update to Ready")
	_check(detail.contains("Brookmint 2/2"), "Brookmint Tea detail does not update Brookmint count")
	_check(detail.contains("Forest Water 1/1"), "Brookmint Tea detail does not update Forest Water count")
	_check(bool(crafting_system.call("craft_quantity", BROOKMINT_RECIPE, 1)), "Could not craft Brookmint Tea")
	await process_frame
	_check(int(inventory.call("get_quantity", "brookmint")) == 0, "Crafting did not consume Brookmint")
	_check(int(inventory.call("get_quantity", "forest_water")) == 0, "Crafting did not consume Forest Water")
	_check(int(inventory.call("get_quantity", BROOKMINT_RECIPE)) == 1, "Crafting did not add Brookmint Tea")
	_check(String(quest_system.call("get_quest_state", BROOKMINT_QUEST)) == "ready_to_turn_in", "Brookmint request did not become ready after crafting")
	_check(String(notebook.call("get_quest_row_text", BROOKMINT_QUEST)).contains("Brookmint Tea 1/1"), "Notebook does not show Brookmint Tea 1/1 progress")
	notebook.call("close")

	var starting_gold: int = int(inventory.call("get_gold"))
	camellia.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", BROOKMINT_QUEST)) == "completed", "Lane Camellia did not complete Brookmint request")
	_check(int(inventory.call("get_quantity", BROOKMINT_RECIPE)) == 0, "Brookmint request did not consume exactly one tea")
	_check(int(inventory.call("get_gold")) == starting_gold + 80, "Brookmint request did not award 80 gold")
	_check(bool(recipe_knowledge.call("is_recipe_known", BROOKMINT_RECIPE)), "Brookmint request did not unlock Brookmint Tea permanently")

	var quest_save_data: Dictionary = quest_system.call("get_save_data")
	var recipe_save_data: Array = recipe_knowledge.call("get_save_data")
	quest_system.call("load_from", {})
	recipe_knowledge.call("load_from", [])
	_check(String(quest_system.call("get_quest_state", BROOKMINT_QUEST)) == "not_started", "Brookmint quest reset check failed before save round trip")
	_check(not bool(recipe_knowledge.call("is_recipe_known", BROOKMINT_RECIPE)), "Brookmint recipe reset check failed before save round trip")
	quest_system.call("load_from", quest_save_data)
	recipe_knowledge.call("load_from", recipe_save_data)
	_check(String(quest_system.call("get_quest_state", BROOKMINT_QUEST)) == "completed", "Completed Brookmint quest did not survive quest save-data round trip")
	_check(bool(recipe_knowledge.call("is_recipe_known", BROOKMINT_RECIPE)), "Learned Brookmint Tea did not survive recipe save-data round trip")

func _finish_dialogue() -> void:
	var dialogue: Node = root.get_node("DialogueBox")
	for _index in range(16):
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

func _clear_transition_meta() -> void:
	for key in ["transition_from_scene", "target_player_position", "target_player_facing"]:
		if root.has_meta(key):
			root.remove_meta(key)

func _stop_audio_players() -> void:
	var audio_system: Node = root.get_node("AudioSystem")
	var players_value: Variant = audio_system.get("_players")
	if typeof(players_value) != TYPE_ARRAY:
		return
	for item in players_value:
		var player: AudioStreamPlayer = item as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
