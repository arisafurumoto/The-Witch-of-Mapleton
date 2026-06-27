extends SceneTree

const SHOP_EXTERIOR_SCENE := "res://scenes/world/ShopExterior.tscn"
const MAPLETON_LANE_SCENE := "res://scenes/world/MapletonLane.tscn"
const QUEST_ID := "camellia_cordial_delivery"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_quest_data()
	_check_scene_wiring()
	await _check_transition_cat_placement()
	await _check_save_scene_compatibility()
	await _check_delivery_flow()
	if _failures.is_empty():
		print("Vertical Slice 1.0 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_quest_data() -> void:
	var quest_database: Node = root.get_node("QuestDatabase")
	var quest: Dictionary = quest_database.call("get_quest", QUEST_ID)
	_check(not quest.is_empty(), "Camellia delivery quest is missing")
	_check(String(quest.get("title", "")) == "A Cordial Delivery", "Delivery quest title is incorrect")
	_check(String(quest.get("turn_in_item_id", "")) == "glowberry_cordial", "Delivery quest turn-in item is incorrect")
	_check(int(quest.get("turn_in_quantity", 0)) == 2, "Delivery quest turn-in quantity is not 2")
	_check(int(quest.get("reward_gold", 0)) == 60, "Delivery quest reward gold is not 60")
	_check(quest_database.call("get_minimum_day", QUEST_ID) == 3, "Delivery quest minimum day is not 3")
	var required_ids: Array = quest_database.call("get_required_quest_ids", QUEST_ID)
	_check(required_ids.has("camellia_first_request"), "Delivery quest does not require Camellia's first request")

func _check_scene_wiring() -> void:
	_check(ResourceLoader.exists(MAPLETON_LANE_SCENE), "MapletonLane.tscn does not exist")
	var exterior := _instantiate_scene(SHOP_EXTERIOR_SCENE)
	var lane := _instantiate_scene(MAPLETON_LANE_SCENE)
	if exterior == null or lane == null:
		return

	_check(exterior.has_node("LaneDoor"), "ShopExterior is missing LaneDoor")
	var lane_door := exterior.get_node("LaneDoor")
	_check(String(lane_door.get("target_scene")) == MAPLETON_LANE_SCENE, "LaneDoor does not target Mapleton Lane")
	_check(bool(lane_door.get("use_target_player_position")), "LaneDoor does not use an explicit lane arrival position")
	_check(lane_door.get("target_player_position") == Vector2(360, 84), "LaneDoor lane arrival position is incorrect")
	_check(String(lane_door.get("target_player_facing")) == "south", "LaneDoor lane arrival facing is incorrect")

	_check(lane.has_node("Player"), "Mapleton Lane is missing Player")
	_check(lane.has_node("Player/Camera2D"), "Mapleton Lane is missing the player camera")
	_check(lane.has_node("Cat"), "Mapleton Lane is missing Saffron")
	_check(lane.has_node("Boundaries/CollTop"), "Mapleton Lane is missing top boundary collision")
	_check(lane.has_node("Boundaries/CollBottom"), "Mapleton Lane is missing bottom boundary collision")
	_check(lane.has_node("Boundaries/CollLeft"), "Mapleton Lane is missing left boundary collision")
	_check(lane.has_node("Boundaries/CollRight"), "Mapleton Lane is missing right boundary collision")
	_check(lane.has_node("NoticeBoard"), "Mapleton Lane is missing the notice board")
	_check(lane.has_node("Camellia"), "Mapleton Lane is missing Camellia")
	_check(lane.has_node("RestaurantStall/CollisionShape2D"), "Mapleton Lane restaurant stall has no collision")
	_check(String(lane.get_node("NoticeBoard").get("quest_id")) == QUEST_ID, "Notice board is not wired to the delivery quest")
	_check(String(lane.get_node("Camellia").get("quest_id")) == QUEST_ID, "Lane Camellia is not wired to the delivery quest")

	var camera := lane.get_node("Player/Camera2D") as Camera2D
	_check(camera.limit_right == 720, "Mapleton Lane camera right limit is incorrect")
	_check(camera.limit_bottom == 480, "Mapleton Lane camera bottom limit is incorrect")

	_check(lane.has_node("ReturnDoor"), "Mapleton Lane is missing ReturnDoor")
	var return_door := lane.get_node("ReturnDoor")
	_check(String(return_door.get("target_scene")) == SHOP_EXTERIOR_SCENE, "Mapleton Lane ReturnDoor does not target the shop exterior")
	_check(bool(return_door.get("use_target_player_position")), "Mapleton Lane ReturnDoor does not use an explicit exterior arrival position")
	_check(return_door.get("target_player_position") == Vector2(360, 420), "Mapleton Lane ReturnDoor exterior arrival position is incorrect")
	_check(String(return_door.get("target_player_facing")) == "north", "Mapleton Lane ReturnDoor exterior arrival facing is incorrect")

	exterior.free()
	lane.free()

func _check_transition_cat_placement() -> void:
	root.set_meta("transition_from_scene", SHOP_EXTERIOR_SCENE)
	root.set_meta("target_player_position", Vector2(360, 84))
	root.set_meta("target_player_facing", "south")
	var lane := _instantiate_scene(MAPLETON_LANE_SCENE)
	if lane == null:
		_clear_transition_meta()
		return
	root.add_child(lane)
	await process_frame
	var lane_cat := lane.get_node("Cat") as Node2D
	_check(lane_cat.global_position.distance_to(Vector2(360, 36)) < 4.0, "Saffron does not arrive behind Marigold in Mapleton Lane")
	lane.queue_free()
	await process_frame
	_clear_transition_meta()

	root.set_meta("transition_from_scene", MAPLETON_LANE_SCENE)
	root.set_meta("target_player_position", Vector2(360, 420))
	root.set_meta("target_player_facing", "north")
	var exterior := _instantiate_scene(SHOP_EXTERIOR_SCENE)
	if exterior == null:
		_clear_transition_meta()
		return
	root.add_child(exterior)
	await process_frame
	var exterior_cat := exterior.get_node("Cat") as Node2D
	_check(exterior_cat.global_position.distance_to(Vector2(360, 468)) < 4.0, "Saffron does not arrive behind Marigold when returning to the shop exterior")
	exterior.queue_free()
	await process_frame
	_clear_transition_meta()

func _check_save_scene_compatibility() -> void:
	var error := change_scene_to_file(MAPLETON_LANE_SCENE)
	_check(error == OK, "Could not change to MapletonLane through SceneTree")
	await process_frame
	await process_frame
	if current_scene == null:
		_failures.append("MapletonLane did not become the current scene")
		return
	_check(current_scene.scene_file_path == MAPLETON_LANE_SCENE, "Current scene path is not Mapleton Lane")
	var player := current_scene.get_node("Player") as Node2D
	player.global_position = Vector2(390, 250)
	var save_system: Node = root.get_node("SaveSystem")
	_check(String(save_system.call("_get_current_scene_path")) == MAPLETON_LANE_SCENE, "SaveSystem does not report the Mapleton Lane scene path")
	var player_position: Dictionary = save_system.call("_get_player_position_data")
	_check(absf(float(player_position.get("x", 0.0)) - 390.0) < 0.01, "SaveSystem does not capture lane player x position")
	_check(absf(float(player_position.get("y", 0.0)) - 250.0) < 0.01, "SaveSystem does not capture lane player y position")

func _check_delivery_flow() -> void:
	var day_system: Node = root.get_node("DaySystem")
	var inventory: Node = root.get_node("Inventory")
	var quest_system: Node = root.get_node("QuestSystem")

	if current_scene == null or current_scene.scene_file_path != MAPLETON_LANE_SCENE:
		var error := change_scene_to_file(MAPLETON_LANE_SCENE)
		_check(error == OK, "Could not load Mapleton Lane for delivery flow")
		await process_frame
		await process_frame
	if current_scene == null:
		return

	var board := current_scene.get_node("NoticeBoard")
	var camellia := current_scene.get_node("Camellia")
	inventory.call("load_from", {}, 0)
	quest_system.call("load_from", {})
	day_system.call("apply_state", 3, {})
	_check(not bool(quest_system.call("is_quest_available", QUEST_ID)), "Delivery quest is available before Camellia's first request is complete")

	quest_system.call("load_from", {
		"sage_first_request": "completed",
		"camellia_first_request": "completed",
	})
	day_system.call("apply_state", 2, {})
	_check(not bool(quest_system.call("is_quest_available", QUEST_ID)), "Delivery quest is available before Day 3")

	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", QUEST_ID)) == "not_started", "Notice board started the delivery quest before Day 3")

	day_system.call("apply_state", 3, {})
	_check(bool(quest_system.call("is_quest_available", QUEST_ID)), "Delivery quest is not available on Day 3 after Camellia's first request")
	board.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", QUEST_ID)) == "active", "Notice board did not start the delivery quest")

	inventory.call("add_item", "glowberry_cordial", 2)
	_check(String(quest_system.call("get_quest_state", QUEST_ID)) == "ready_to_turn_in", "Delivery quest did not become ready with two cordials")
	var starting_gold: int = int(inventory.call("get_gold"))
	camellia.call("interact")
	await _finish_dialogue()
	_check(String(quest_system.call("get_quest_state", QUEST_ID)) == "completed", "Lane Camellia did not complete the delivery quest")
	_check(int(inventory.call("get_quantity", "glowberry_cordial")) == 0, "Delivery quest did not consume exactly two cordials")
	_check(int(inventory.call("get_gold")) == starting_gold + 60, "Delivery quest did not award 60 gold")

	var save_data: Dictionary = quest_system.call("get_save_data")
	quest_system.call("load_from", {})
	_check(String(quest_system.call("get_quest_state", QUEST_ID)) == "not_started", "Quest reset check failed before save/load verification")
	quest_system.call("load_from", save_data)
	_check(String(quest_system.call("get_quest_state", QUEST_ID)) == "completed", "Completed delivery quest state did not survive save data round trip")

func _finish_dialogue() -> void:
	var dialogue: Node = root.get_node("DialogueBox")
	for _index in range(10):
		await process_frame
		if not bool(dialogue.call("is_active")):
			await process_frame
			return
		dialogue.call("_advance")
	_check(not bool(dialogue.call("is_active")), "Dialogue did not close during verification")

func _clear_transition_meta() -> void:
	for key in ["transition_from_scene", "target_player_position", "target_player_facing"]:
		if root.has_meta(key):
			root.remove_meta(key)

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
