extends SceneTree

const NOTEBOOK_SCENE := "res://scenes/ui/NotebookPanel.tscn"
const SHOP_SCENE := "res://scenes/world/ShopInterior.tscn"
const SAGE_QUEST := "sage_first_request"
const CAMELLIA_QUEST := "camellia_first_request"
const DELIVERY_QUEST := "camellia_cordial_delivery"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_scene_and_project_wiring()
	await _check_open_close()
	await _check_quest_notes()
	await _check_recipe_notes()
	await _check_player_modal_guard()
	if _failures.is_empty():
		print("Vertical Slice 1.1 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_scene_and_project_wiring() -> void:
	_check(ResourceLoader.exists(NOTEBOOK_SCENE), "NotebookPanel.tscn does not exist")
	var notebook_scene := load(NOTEBOOK_SCENE) as PackedScene
	_check(notebook_scene != null, "NotebookPanel.tscn does not load as a PackedScene")
	_check(root.has_node("NotebookPanel"), "NotebookPanel autoload is missing")
	_check(InputMap.has_action("toggle_notebook"), "toggle_notebook input action is missing")
	var has_j_binding := false
	for event in InputMap.action_get_events("toggle_notebook"):
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == KEY_J:
			has_j_binding = true
	_check(has_j_binding, "toggle_notebook is not bound to J")

func _check_open_close() -> void:
	var notebook := _notebook()
	notebook.call("close")
	await process_frame
	_check(not bool(notebook.call("is_active")), "Notebook reports active after close")
	notebook.call("open")
	await process_frame
	_check(bool(notebook.call("is_active")), "Notebook did not open")
	_check(String(notebook.call("get_current_tab")) == "quests", "Notebook does not default to the Quests tab")
	notebook.call("close")
	await process_frame
	_check(not bool(notebook.call("is_active")), "Notebook did not close")

func _check_quest_notes() -> void:
	var notebook := _notebook()
	var inventory := _inventory()
	var quest_system := _quest_system()
	var day_system := _day_system()
	var recipe_knowledge := _recipe_knowledge()

	inventory.call("load_from", {}, 0)
	quest_system.call("load_from", {})
	recipe_knowledge.call("load_from", [])
	day_system.call("apply_state", 1, {})
	notebook.call("open")
	await process_frame
	_check(_as_string_array(notebook.call("get_open_quest_ids")).is_empty(), "Notebook shows open quests before one starts")
	_check(_as_string_array(notebook.call("get_completed_quest_ids")).is_empty(), "Notebook shows completed quests before completion")

	quest_system.call("start_quest", SAGE_QUEST)
	await process_frame
	var open_ids := _as_string_array(notebook.call("get_open_quest_ids"))
	_check(open_ids.has(SAGE_QUEST), "Active Sage quest is not shown in open quests")
	_check(String(notebook.call("get_quest_row_text", SAGE_QUEST)).contains("Root-Wake Tonic 0/1"), "Active Sage quest does not show 0/1 tonic progress")

	inventory.call("add_item", "root_wake_tonic", 1)
	await process_frame
	_check(String(quest_system.call("get_quest_state", SAGE_QUEST)) == "ready_to_turn_in", "Sage quest did not become ready with tonic")
	_check(String(notebook.call("get_quest_row_text", SAGE_QUEST)).contains("Ready"), "Ready Sage quest row does not show Ready")
	_check(String(notebook.call("get_quest_row_text", SAGE_QUEST)).contains("Root-Wake Tonic 1/1"), "Ready Sage quest does not show 1/1 tonic progress")

	quest_system.call("complete_quest", SAGE_QUEST)
	await process_frame
	_check(_as_string_array(notebook.call("get_completed_quest_ids")).has(SAGE_QUEST), "Completed Sage quest is not shown in completed quests")

	inventory.call("load_from", {}, 0)
	quest_system.call("load_from", {
		SAGE_QUEST: "completed",
		CAMELLIA_QUEST: "completed",
	})
	recipe_knowledge.call("load_from", ["glowberry_cordial"])
	day_system.call("apply_state", 3, {})
	quest_system.call("start_quest", DELIVERY_QUEST)
	await process_frame
	_check(String(notebook.call("get_quest_row_text", DELIVERY_QUEST)).contains("Glowberry Cordial 0/2"), "Delivery quest does not show 0/2 cordial progress")
	inventory.call("add_item", "glowberry_cordial", 1)
	await process_frame
	_check(String(notebook.call("get_quest_row_text", DELIVERY_QUEST)).contains("Glowberry Cordial 1/2"), "Delivery quest does not update to 1/2 cordial progress")
	inventory.call("add_item", "glowberry_cordial", 1)
	await process_frame
	_check(String(notebook.call("get_quest_row_text", DELIVERY_QUEST)).contains("Glowberry Cordial 2/2"), "Delivery quest does not update to 2/2 cordial progress")
	_check(String(notebook.call("get_quest_row_text", DELIVERY_QUEST)).contains("Ready"), "Delivery quest row does not show Ready at 2/2")
	notebook.call("close")

func _check_recipe_notes() -> void:
	var notebook := _notebook()
	var inventory := _inventory()
	var quest_system := _quest_system()
	var recipe_knowledge := _recipe_knowledge()
	var day_system := _day_system()

	inventory.call("load_from", {}, 0)
	quest_system.call("load_from", {})
	recipe_knowledge.call("load_from", [])
	day_system.call("apply_state", 1, {})
	notebook.call("open")
	await process_frame
	var recipe_ids := _as_string_array(notebook.call("get_visible_recipe_ids"))
	_check(recipe_ids.has("calming_tea"), "Calming Tea is not shown as a default known recipe")
	_check(not recipe_ids.has("glowberry_cordial"), "Glowberry Cordial is shown before it is known or quest-active")

	quest_system.call("start_quest", SAGE_QUEST)
	await process_frame
	recipe_ids = _as_string_array(notebook.call("get_visible_recipe_ids"))
	_check(recipe_ids.has("root_wake_tonic"), "Quest-active Root-Wake Tonic recipe is not shown")

	quest_system.call("load_from", {SAGE_QUEST: "completed"})
	day_system.call("apply_state", 2, {})
	quest_system.call("start_quest", CAMELLIA_QUEST)
	await process_frame
	recipe_ids = _as_string_array(notebook.call("get_visible_recipe_ids"))
	_check(recipe_ids.has("glowberry_cordial"), "Quest-active Glowberry Cordial recipe is not shown")

	quest_system.call("load_from", {})
	recipe_knowledge.call("load_from", ["glowberry_cordial"])
	await process_frame
	recipe_ids = _as_string_array(notebook.call("get_visible_recipe_ids"))
	_check(recipe_ids.has("glowberry_cordial"), "Learned Glowberry Cordial recipe is not shown")

	notebook.call("_select_recipe", "glowberry_cordial")
	await process_frame
	var detail := String(notebook.call("get_recipe_detail_text"))
	_check(detail.contains("Status: Missing ingredients"), "Glowberry Cordial detail does not show missing status without ingredients")
	_check(detail.contains("Moonleaf 0/1"), "Glowberry Cordial detail does not show Moonleaf 0/1")
	_check(detail.contains("Glowberry 0/2"), "Glowberry Cordial detail does not show Glowberry 0/2")
	_check(detail.contains("Forest Water 0/1"), "Glowberry Cordial detail does not show Forest Water 0/1")

	inventory.call("add_item", "moonleaf", 1)
	inventory.call("add_item", "glowberry", 2)
	inventory.call("add_item", "forest_water", 1)
	await process_frame
	detail = String(notebook.call("get_recipe_detail_text"))
	_check(detail.contains("Status: Ready"), "Glowberry Cordial detail does not update to Ready")
	_check(detail.contains("Moonleaf 1/1"), "Glowberry Cordial detail does not update Moonleaf count")
	_check(detail.contains("Glowberry 2/2"), "Glowberry Cordial detail does not update Glowberry count")
	_check(detail.contains("Forest Water 1/1"), "Glowberry Cordial detail does not update Forest Water count")
	notebook.call("close")

func _check_player_modal_guard() -> void:
	var error := change_scene_to_file(SHOP_SCENE)
	_check(error == OK, "Could not load ShopInterior to check player modal guard")
	await process_frame
	await process_frame
	if current_scene == null or not current_scene.has_node("Player"):
		_failures.append("ShopInterior did not expose Player for modal guard check")
		return
	var player := current_scene.get_node("Player")
	var notebook := _notebook()
	notebook.call("close")
	await process_frame
	_check(not bool(player.call("_is_modal_ui_active")), "Player reports modal UI active while notebook is closed")
	notebook.call("open")
	await process_frame
	_check(bool(player.call("_is_modal_ui_active")), "Player does not treat open notebook as modal UI")
	notebook.call("close")

func _as_string_array(value: Variant) -> Array[String]:
	var ids: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return ids
	for item in value:
		ids.append(String(item))
	return ids

func _notebook() -> Node:
	return root.get_node("NotebookPanel")

func _inventory() -> Node:
	return root.get_node("Inventory")

func _quest_system() -> Node:
	return root.get_node("QuestSystem")

func _recipe_knowledge() -> Node:
	return root.get_node("RecipeKnowledgeSystem")

func _day_system() -> Node:
	return root.get_node("DaySystem")

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
