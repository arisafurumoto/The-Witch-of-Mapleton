extends SceneTree

const EXTERIOR_SCENE := "res://scenes/world/ShopExterior.tscn"
const SHOP_SCENE := "res://scenes/world/ShopInterior.tscn"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_scene_wiring()
	await _check_transition_cat_placement()
	await _check_save_scene_compatibility()
	if _failures.is_empty():
		print("Vertical Slice 0.8 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_scene_wiring() -> void:
	_check(ResourceLoader.exists(EXTERIOR_SCENE), "ShopExterior.tscn does not exist")
	var shop := _instantiate_scene(SHOP_SCENE)
	var exterior := _instantiate_scene(EXTERIOR_SCENE)
	if shop == null or exterior == null:
		return

	var front_door := shop.get_node("FrontDoor")
	_check(String(front_door.get("target_scene")) == EXTERIOR_SCENE, "Shop FrontDoor does not target the exterior")
	_check(bool(front_door.get("use_target_player_position")), "Shop FrontDoor does not use an explicit exterior arrival position")
	_check(front_door.get("target_player_position") == Vector2(360, 230), "Shop FrontDoor exterior arrival position is incorrect")
	_check(String(front_door.get("target_player_facing")) == "south", "Shop FrontDoor exterior arrival facing is incorrect")
	_check(shop.has_node("VisitorEntrance"), "Shop visitor entrance marker is missing")
	_check(shop.has_node("VisitorInteriorWaypoint"), "Shop visitor interior waypoint is missing")
	_check(shop.get_node("VisitorEntrance").position == Vector2(360, 465), "Visitor entrance marker moved unexpectedly")
	_check(shop.get_node("VisitorInteriorWaypoint").position == Vector2(360, 405), "Visitor interior waypoint moved unexpectedly")

	var customer := shop.get_node("Customer")
	var sage := shop.get_node("Sage")
	var camellia := shop.get_node("Camellia")
	_check(String(customer.get("entrance_path")) == "../VisitorEntrance", "Customer entrance path no longer uses VisitorEntrance")
	_check(String(sage.get("entrance_path")) == "../VisitorEntrance", "Sage entrance path no longer uses VisitorEntrance")
	_check(String(camellia.get("entrance_path")) == "../VisitorEntrance", "Camellia entrance path no longer uses VisitorEntrance")
	_check(String(customer.get("interior_waypoint_path")) == "../VisitorInteriorWaypoint", "Customer waypoint path no longer uses VisitorInteriorWaypoint")
	_check(String(sage.get("interior_waypoint_path")) == "../VisitorInteriorWaypoint", "Sage waypoint path no longer uses VisitorInteriorWaypoint")
	_check(String(camellia.get("interior_waypoint_path")) == "../VisitorInteriorWaypoint", "Camellia waypoint path no longer uses VisitorInteriorWaypoint")

	_check(exterior.has_node("Player"), "Exterior is missing Player")
	_check(exterior.has_node("Player/Camera2D"), "Exterior is missing the player camera")
	_check(exterior.has_node("Cat"), "Exterior is missing Saffron")
	_check(exterior.has_node("Boundaries/CollTop"), "Exterior is missing top boundary collision")
	_check(exterior.has_node("Boundaries/CollBottom"), "Exterior is missing bottom boundary collision")
	_check(exterior.has_node("Boundaries/CollLeft"), "Exterior is missing left boundary collision")
	_check(exterior.has_node("Boundaries/CollRight"), "Exterior is missing right boundary collision")
	_check(exterior.has_node("ShopFacade/CollisionShape2D"), "Exterior shop facade has no collision")

	var camera := exterior.get_node("Player/Camera2D") as Camera2D
	_check(camera.limit_right == 720, "Exterior camera right limit is incorrect")
	_check(camera.limit_bottom == 480, "Exterior camera bottom limit is incorrect")

	var return_door := exterior.get_node("ReturnDoor")
	_check(String(return_door.get("target_scene")) == SHOP_SCENE, "Exterior ReturnDoor does not target the shop")
	_check(bool(return_door.get("use_target_player_position")), "Exterior ReturnDoor does not use an explicit shop arrival position")
	_check(return_door.get("target_player_position") == Vector2(360, 420), "Exterior ReturnDoor shop arrival position is incorrect")
	_check(String(return_door.get("target_player_facing")) == "north", "Exterior ReturnDoor shop arrival facing is incorrect")

	shop.free()
	exterior.free()

func _check_transition_cat_placement() -> void:
	root.set_meta("transition_from_scene", SHOP_SCENE)
	root.set_meta("target_player_position", Vector2(360, 230))
	root.set_meta("target_player_facing", "south")
	var exterior := _instantiate_scene(EXTERIOR_SCENE)
	if exterior == null:
		_clear_transition_meta()
		return
	root.add_child(exterior)
	await process_frame
	var exterior_cat := exterior.get_node("Cat") as Node2D
	_check(exterior_cat.global_position.distance_to(Vector2(360, 182)) < 4.0, "Saffron does not arrive behind Marigold outside")
	exterior.queue_free()
	await process_frame
	_clear_transition_meta()

	root.set_meta("transition_from_scene", EXTERIOR_SCENE)
	root.set_meta("target_player_position", Vector2(360, 420))
	root.set_meta("target_player_facing", "north")
	var shop := _instantiate_scene(SHOP_SCENE)
	if shop == null:
		_clear_transition_meta()
		return
	root.add_child(shop)
	await process_frame
	var shop_cat := shop.get_node("Cat") as Node2D
	_check(shop_cat.global_position.distance_to(Vector2(360, 468)) < 4.0, "Saffron does not arrive behind Marigold inside the front door")
	shop.queue_free()
	await process_frame
	_clear_transition_meta()

func _check_save_scene_compatibility() -> void:
	var error := change_scene_to_file(EXTERIOR_SCENE)
	_check(error == OK, "Could not change to ShopExterior through SceneTree")
	await process_frame
	await process_frame
	if current_scene == null:
		_failures.append("ShopExterior did not become the current scene")
		return
	_check(current_scene.scene_file_path == EXTERIOR_SCENE, "Current scene path is not the exterior")
	var player := current_scene.get_node("Player") as Node2D
	player.global_position = Vector2(390, 250)
	var save_system := root.get_node("SaveSystem")
	_check(String(save_system.call("_get_current_scene_path")) == EXTERIOR_SCENE, "SaveSystem does not report the exterior scene path")
	var player_position: Dictionary = save_system.call("_get_player_position_data")
	_check(absf(float(player_position.get("x", 0.0)) - 390.0) < 0.01, "SaveSystem does not capture exterior player x position")
	_check(absf(float(player_position.get("y", 0.0)) - 250.0) < 0.01, "SaveSystem does not capture exterior player y position")

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
