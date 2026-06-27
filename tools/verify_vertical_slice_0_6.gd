extends SceneTree

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_scene_layout()
	await _check_shop_state()
	_check_recipe_progression()
	if _failures.is_empty():
		print("Vertical Slice 0.6 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_scene_layout() -> void:
	var shop := _instantiate_scene("res://scenes/world/ShopInterior.tscn")
	var room := _instantiate_scene("res://scenes/world/MarigoldRoom.tscn")
	if shop == null or room == null:
		return
	_check(shop.has_node("ForestDoor"), "Shop is missing ForestDoor")
	_check(shop.has_node("FrontDoor"), "Shop is missing FrontDoor")
	_check(shop.has_node("RoomDoor"), "Shop is missing RoomDoor")
	_check(shop.has_node("DoorBarriers/FrontDoorBarrier"), "Front door is not blocked at the scene boundary")
	_check(not shop.has_node("Bed"), "Bed still exists in the shop")
	_check(room.has_node("Bed"), "Marigold's room is missing the bed")
	_check(room.has_node("ShopDoor"), "Marigold's room is missing its return door")
	_check(shop.get_node("Background").scale == Vector2(0.75, 0.75), "Shop footprint is not scaled to 720x480")
	_check(room.get_node("Background").scale == Vector2(0.5625, 0.5625), "Room footprint is not scaled to 540x360")
	_check(room.get_node("Player/Camera2D").zoom == Vector2.ONE, "Room camera zoom does not match the rest of the game")
	var sage := shop.get_node("Sage")
	_check(sage.position == Vector2(360, 260), "Sage is not centred in front of the counter")
	_check(String(sage.get("home_facing")) == "north", "Sage is not facing the counter")
	var customer := shop.get_node("Customer")
	_check(customer.get("counter_position") == Vector2(360, 260), "Customer is not centred in front of the counter")
	var counter_collision := shop.get_node("Counter/CollisionShape2D") as CollisionShape2D
	var counter_shape := counter_collision.shape as RectangleShape2D
	_check(counter_shape.size == Vector2(96, 32), "Counter collision is not half-height")
	_check(counter_collision.position == Vector2(0, -16), "Counter collision is not aligned to the counter base")
	var front_door := shop.get_node("FrontDoor")
	_check(String(front_door.get("target_scene")) == "res://scenes/world/ShopExterior.tscn", "Front door target is incorrect")
	var room_door := shop.get_node("RoomDoor")
	_check(String(room_door.get("target_scene")) == "res://scenes/world/MarigoldRoom.tscn", "Room door target is incorrect")
	shop.free()
	room.free()

func _check_shop_state() -> void:
	var shop_state := root.get_node("ShopState")
	root.get_node("DaySystem").call("apply_state", 1, {})
	# Keep Sage stationary while this check briefly loads and unloads the shop.
	root.get_node("QuestSystem").call("load_from", {"sage_first_request": "completed"})
	shop_state.call("clear")
	shop_state.call("set_display_stock", "main_display", "calming_tea", 1)
	root.set_meta("transition_from_scene", "res://scenes/world/ForestClearing.tscn")
	root.set_meta("target_player_position", Vector2(360, 100))
	root.set_meta("target_player_facing", "south")
	var shop := _instantiate_scene("res://scenes/world/ShopInterior.tscn")
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	var display := shop.get_node("ShopDisplay")
	_check(bool(display.call("has_stock")), "Display did not restore stock from ShopState")
	var cat_position: Vector2 = shop.get_node("Cat").position
	_check(cat_position.distance_to(Vector2(360, 52)) < 4.0, "Saffron did not enter behind Marigold through the forest door")
	var player := shop.get_node("Player") as Node2D
	var sage := shop.get_node("Sage")
	var sign := shop.get_node("Sign")
	sage.call("_set_present", true)
	_check(bool(sign.call("_has_closed_shop_visitor")), "Shop sign did not detect the closed-shop visitor")
	sign.call("show_prompt", true)
	_check(String(sign.get_node("PromptLabel").text) == "Visitor here", "Shop sign did not show its disabled visitor prompt")
	sage.call("_set_present", false)
	await process_frame
	_check(not bool(sign.call("_has_closed_shop_visitor")), "Shop sign stayed disabled after the visitor left")
	player.position = sage.position + Vector2(80, 0)
	sage.call("_face_player")
	_check(String(sage.get_node("Visual").animation) == "idle_east", "Sage did not turn toward Marigold")
	var customer := shop.get_node("Customer")
	player.position = customer.position + Vector2(80, 0)
	customer.call("_face_player")
	_check(String(customer.get_node("Visual").animation) == "idle_east", "Customer did not turn toward Marigold")
	shop.queue_free()
	await process_frame
	root.remove_meta("transition_from_scene")
	var stock: Dictionary = shop_state.call("get_display_stock", "main_display")
	_check(int(stock.get("quantity", 0)) == 1, "Shop stock was lost when the scene unloaded")
	shop_state.call("clear")

func _check_recipe_progression() -> void:
	var recipe_knowledge := root.get_node("RecipeKnowledgeSystem")
	var quest_system := root.get_node("QuestSystem")
	var inventory := root.get_node("Inventory")
	recipe_knowledge.call("load_from", [])
	quest_system.call("load_from", {})
	inventory.call("load_from", {}, 0)
	_check(bool(recipe_knowledge.call("is_recipe_known", "calming_tea")), "Calming Tea is not known by default")
	_check(not bool(recipe_knowledge.call("is_recipe_known", "root_wake_tonic")), "Root-Wake Tonic is known before Sage's quest")
	quest_system.call("start_quest", "sage_first_request")
	inventory.call("add_item", "root_wake_tonic", 1)
	_check(bool(quest_system.call("complete_quest", "sage_first_request")), "Sage's quest could not be completed")
	_check(bool(recipe_knowledge.call("is_recipe_known", "root_wake_tonic")), "Sage's quest did not unlock Root-Wake Tonic")
	var save_data: Array = recipe_knowledge.call("get_save_data")
	_check(save_data.has("root_wake_tonic"), "Unlocked recipe was not included in save data")
	recipe_knowledge.call("load_from", [])
	quest_system.call("load_from", {"sage_first_request": "completed"})
	root.get_node("SaveSystem").call("_unlock_completed_quest_recipes")
	_check(bool(recipe_knowledge.call("is_recipe_known", "root_wake_tonic")), "Completed 0.5 quest did not migrate its recipe reward")

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
