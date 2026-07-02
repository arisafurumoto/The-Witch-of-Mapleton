extends SceneTree

const SHOP_INTERIOR_SCENE := "res://scenes/world/ShopInterior.tscn"
const SHOP_EXTERIOR_SCENE := "res://scenes/world/ShopExterior.tscn"
const MAPLETON_LANE_SCENE := "res://scenes/world/MapletonLane.tscn"
const PLANTER_ID := "moonleaf_planter_001"
const SEED_ITEM_ID := "moonleaf_seed_packet"
const HARVEST_ITEM_ID := "moonleaf"
const HARVEST_QUANTITY := 2
const STATE_PLANTED := "planted"
const STAGE_EMPTY := "empty"
const STAGE_SPROUT := "sprout"
const STAGE_YOUNG := "young"
const STAGE_READY := "ready"
const STAGE_HARVESTED := "harvested"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_autoload()
	await _check_shop_exterior_planter()
	_check_planter_save_round_trip()
	if _failures.is_empty():
		print("Vertical Slice 1.7 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_autoload() -> void:
	_check(root.has_node("PlanterSystem"), "PlanterSystem autoload is missing")

func _check_shop_exterior_planter() -> void:
	_prepare_state()
	var exterior: Node = _instantiate_scene(SHOP_EXTERIOR_SCENE)
	if exterior == null:
		return
	root.add_child(exterior)
	await process_frame
	await process_frame

	_check(exterior.has_node("Player"), "ShopExterior is missing Player")
	_check(exterior.has_node("Cat"), "ShopExterior is missing Saffron")
	_check_door(exterior, "ReturnDoor", SHOP_INTERIOR_SCENE, Vector2(360, 420), "north", "ShopExterior")
	_check_door(exterior, "LaneDoor", MAPLETON_LANE_SCENE, Vector2(360, 84), "south", "ShopExterior")
	_check(exterior.has_node("FuturePlanterMarker"), "ShopExterior is missing FuturePlanterMarker")
	if exterior.has_node("FuturePlanterMarker"):
		_check_visual_only_marker(exterior.get_node("FuturePlanterMarker"))
	_check(exterior.has_node("MoonleafPlanter"), "ShopExterior is missing MoonleafPlanter")
	if not exterior.has_node("MoonleafPlanter"):
		exterior.queue_free()
		await process_frame
		return

	var planter: Node = exterior.get_node("MoonleafPlanter")
	_check(planter.has_method("interact"), "MoonleafPlanter is not interactable")
	var inventory: Node = root.get_node("Inventory")
	_check(_planter_stage() == STAGE_EMPTY, "Planter did not start empty")
	_check(int(inventory.call("get_quantity", SEED_ITEM_ID)) == 1, "Seed packet setup failed")

	planter.call("interact")
	await process_frame
	_check(int(inventory.call("get_quantity", SEED_ITEM_ID)) == 0, "Planting did not consume a Moonleaf Seed Packet")
	_check(_planter_stage() == STAGE_SPROUT, "Planter did not become a sprout after planting")

	root.get_node("DaySystem").call("advance_day")
	await process_frame
	_check(_planter_stage() == STAGE_YOUNG, "Planter did not advance to young after one sleep")

	root.get_node("DaySystem").call("advance_day")
	await process_frame
	_check(_planter_stage() == STAGE_READY, "Planter did not become ready after two sleeps")

	planter.call("interact")
	await process_frame
	_check(int(inventory.call("get_quantity", HARVEST_ITEM_ID)) == HARVEST_QUANTITY, "Harvesting did not add Moonleaf")
	_check(_planter_stage() == STAGE_HARVESTED, "Planter did not enter harvested stage")

	exterior.queue_free()
	await process_frame

func _check_planter_save_round_trip() -> void:
	var day_system: Node = root.get_node("DaySystem")
	var planter_system: Node = root.get_node("PlanterSystem")
	day_system.call("apply_state", 8, {})
	planter_system.call("load_from", {
		PLANTER_ID: {
			"state": STATE_PLANTED,
			"planted_day": 6,
		}
	})
	_check(_planter_stage() == STAGE_READY, "Loaded planted state did not compute ready stage")
	var save_data: Dictionary = planter_system.call("get_save_data")
	_check(save_data.has(PLANTER_ID), "Planter save data is missing the stable planter id")
	planter_system.call("clear")
	_check(_planter_stage() == STAGE_EMPTY, "Planter did not clear to empty")
	planter_system.call("load_from", save_data)
	_check(_planter_stage() == STAGE_READY, "Planter save data did not restore ready stage")

func _prepare_state() -> void:
	root.get_node("Inventory").call("load_from", {SEED_ITEM_ID: 1}, 0)
	root.get_node("DaySystem").call("apply_state", 5, {})
	root.get_node("PlanterSystem").call("clear")

func _planter_stage() -> String:
	return String(root.get_node("PlanterSystem").call("get_stage", PLANTER_ID))

func _check_door(scene: Node, node_path: String, target_scene: String, target_position: Vector2, target_facing: String, scene_name: String) -> void:
	_check(scene.has_node(node_path), scene_name + " is missing door: " + node_path)
	if not scene.has_node(node_path):
		return
	var door: Node = scene.get_node(node_path)
	_check(String(door.get("target_scene")) == target_scene, scene_name + " " + node_path + " targets the wrong scene")
	_check(bool(door.get("use_target_player_position")), scene_name + " " + node_path + " does not set explicit arrival metadata")
	var actual_position: Vector2 = door.get("target_player_position")
	_check(actual_position == target_position, scene_name + " " + node_path + " arrival position changed")
	_check(String(door.get("target_player_facing")) == target_facing, scene_name + " " + node_path + " arrival facing changed")

func _check_visual_only_marker(marker: Node) -> void:
	_check(marker is Node2D, "FuturePlanterMarker should remain a visual Node2D")
	_check(not (marker is Area2D), "FuturePlanterMarker must not become interactable")
	_check(marker.get_script() == null, "FuturePlanterMarker must not have behavior")
	var area_children: Array[Node] = marker.find_children("*", "Area2D", true, false)
	var collision_children: Array[Node] = marker.find_children("*", "CollisionShape2D", true, false)
	_check(area_children.is_empty(), "FuturePlanterMarker must not contain interaction areas")
	_check(collision_children.is_empty(), "FuturePlanterMarker must not contain collision")

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
