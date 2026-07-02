extends SceneTree

const SHOP_SCENE := "res://scenes/world/ShopInterior.tscn"
const MAIN_DISPLAY_ID := "main_display"
const SIDE_DISPLAY_ID := "side_display"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_prepare_quiet_world_state()
	_check_scene_has_two_displays()
	await _check_independent_display_restore()
	await _check_second_display_only_sale()
	await _check_mixed_display_queue()
	await _wait_for_audio_idle()
	if _failures.is_empty():
		print("Vertical Slice 1.8 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _prepare_quiet_world_state() -> void:
	var quest_system: Node = root.get_node("QuestSystem")
	var day_system: Node = root.get_node("DaySystem")
	var inventory: Node = root.get_node("Inventory")
	var recipe_knowledge: Node = root.get_node("RecipeKnowledgeSystem")
	var shop_state: Node = root.get_node("ShopState")
	quest_system.call("load_from", {
		"sage_first_request": "completed",
		"camellia_first_request": "completed",
	})
	day_system.call("apply_state", 5, {})
	inventory.call("load_from", {}, 0)
	recipe_knowledge.call("load_from", ["glowberry_cordial", "brookmint_tea"])
	shop_state.call("clear")

func _check_scene_has_two_displays() -> void:
	var shop: Node = _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	_check(shop.has_node("ShopDisplay"), "ShopInterior is missing the main display")
	_check(shop.has_node("SecondShopDisplay"), "ShopInterior is missing the second display")
	if shop.has_node("ShopDisplay") and shop.has_node("SecondShopDisplay"):
		var main_display: Node = shop.get_node("ShopDisplay")
		var side_display: Node = shop.get_node("SecondShopDisplay")
		_check(String(main_display.get("display_id")) == MAIN_DISPLAY_ID, "Main display id changed")
		_check(String(side_display.get("display_id")) == SIDE_DISPLAY_ID, "Second display id is not stable")
		_check(String(main_display.get("display_id")) != String(side_display.get("display_id")), "Displays share the same display id")
		_check(String(side_display.get("accepted_item_id")) == "glowberry_cordial", "Second display does not prefer Glowberry Cordial")
	_check(shop.has_node("Sign"), "ShopInterior is missing the shop open sign")
	_check(shop.has_node("Customer"), "ShopInterior is missing the customer")
	shop.free()

func _check_independent_display_restore() -> void:
	var shop_state: Node = root.get_node("ShopState")
	shop_state.call("clear")
	shop_state.call("set_display_stock", MAIN_DISPLAY_ID, "calming_tea", 1)
	shop_state.call("set_display_stock", SIDE_DISPLAY_ID, "glowberry_cordial", 2)

	var shop: Node = _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	var main_display: Node = shop.get_node("ShopDisplay")
	var side_display: Node = shop.get_node("SecondShopDisplay")
	_check(String(main_display.call("get_stock_item_id")) == "calming_tea", "Main display restored the wrong item")
	_check(int(main_display.call("get_stock_quantity")) == 1, "Main display restored the wrong quantity")
	_check(String(side_display.call("get_stock_item_id")) == "glowberry_cordial", "Second display restored the wrong item")
	_check(int(side_display.call("get_stock_quantity")) == 2, "Second display restored the wrong quantity")

	shop.queue_free()
	await process_frame
	await process_frame

func _check_second_display_only_sale() -> void:
	_prepare_quiet_world_state()
	var shop_state: Node = root.get_node("ShopState")
	shop_state.call("set_display_stock", SIDE_DISPLAY_ID, "glowberry_cordial", 1)

	var shop: Node = _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	_make_customer_route_fast(shop)
	var side_display: Node = shop.get_node("SecondShopDisplay")
	var sign: Node = shop.get_node("Sign")
	var customer: Node = shop.get_node("Customer")
	var inventory: Node = root.get_node("Inventory")
	var item_database: Node = root.get_node("ItemDatabase")
	var starting_gold := int(inventory.call("get_gold"))
	var cordial_price := int(item_database.call("get_sell_price", "glowberry_cordial"))

	sign.call("interact")
	var reached_counter := await _wait_for_customer_at_counter(customer, 4.0)
	_check(reached_counter, "Customer did not buy from the second display when it was the only stocked display")
	_check(int(side_display.call("get_available_stock_quantity")) == 0, "Second display did not reserve its only item")

	customer.call("_confirm_display_sale")
	await _finish_customer_dialogue()
	var queue_ended := await _wait_for_queue_inactive(customer, 5.0)
	_check(queue_ended, "Customer queue did not end after side-display sale")
	_check(not bool(side_display.call("has_stock")), "Second display was not emptied by the sale")
	_check(int(inventory.call("get_gold")) == starting_gold + cordial_price, "Side-display sale awarded the wrong gold")

	shop.queue_free()
	await process_frame
	await process_frame

func _check_mixed_display_queue() -> void:
	_prepare_quiet_world_state()
	var shop_state: Node = root.get_node("ShopState")
	shop_state.call("set_display_stock", MAIN_DISPLAY_ID, "calming_tea", 1)
	shop_state.call("set_display_stock", SIDE_DISPLAY_ID, "glowberry_cordial", 1)

	var shop: Node = _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	_make_customer_route_fast(shop)
	var main_display: Node = shop.get_node("ShopDisplay")
	var side_display: Node = shop.get_node("SecondShopDisplay")
	var sign: Node = shop.get_node("Sign")
	var customer: Node = shop.get_node("Customer")
	var inventory: Node = root.get_node("Inventory")
	var item_database: Node = root.get_node("ItemDatabase")
	var starting_gold := int(inventory.call("get_gold"))
	var expected_gold := int(item_database.call("get_sell_price", "calming_tea")) + int(item_database.call("get_sell_price", "glowberry_cordial"))

	sign.call("interact")
	var reached_counter := await _wait_for_customer_at_counter(customer, 4.0)
	_check(reached_counter, "First mixed-stock customer did not reach the counter")
	_check(int(customer.get("_queued_customers_remaining")) == 1, "Mixed stock did not plan a second customer")

	customer.call("_confirm_display_sale")
	await _finish_customer_dialogue()
	reached_counter = await _wait_for_customer_at_counter(customer, 5.0)
	_check(reached_counter, "Second mixed-stock customer did not reach the counter")
	_check(not bool(main_display.call("has_stock")), "Main display was not sold first by stable display choice")

	customer.call("_confirm_display_sale")
	await _finish_customer_dialogue()
	var queue_ended := await _wait_for_queue_inactive(customer, 5.0)
	_check(queue_ended, "Mixed display queue did not end")
	_check(not bool(side_display.call("has_stock")), "Second display was not sold during mixed queue")
	_check(int(inventory.call("get_gold")) == starting_gold + expected_gold, "Mixed display queue awarded the wrong total gold")

	shop.queue_free()
	await process_frame
	await process_frame

func _make_customer_route_fast(shop: Node) -> void:
	var route_position := Vector2(120, 120)
	(shop.get_node("VisitorEntrance") as Node2D).position = route_position
	(shop.get_node("VisitorInteriorWaypoint") as Node2D).position = route_position
	(shop.get_node("CustomerCounterAisle") as Node2D).position = route_position
	(shop.get_node("CustomerCounterApproach") as Node2D).position = route_position
	(shop.get_node("ShopDisplay") as Node2D).position = route_position
	(shop.get_node("SecondShopDisplay") as Node2D).position = route_position
	var customer: Node = shop.get_node("Customer")
	customer.set("counter_position", route_position)
	customer.set("browse_time", 0.01)

func _finish_customer_dialogue() -> void:
	var dialogue: Node = root.get_node("DialogueBox")
	for _index in range(8):
		await process_frame
		if not bool(dialogue.call("is_active")):
			return
		dialogue.call("_advance")
	_check(not bool(dialogue.call("is_active")), "Customer dialogue did not close during verification")

func _wait_for_customer_at_counter(customer: Node, timeout_seconds: float) -> bool:
	var elapsed := 0.0
	while elapsed < timeout_seconds:
		if String(customer.get("_state")) == "at_counter" and not bool(customer.get("_busy")):
			return true
		await create_timer(0.05).timeout
		elapsed += 0.05
	return false

func _wait_for_queue_inactive(customer: Node, timeout_seconds: float) -> bool:
	var elapsed := 0.0
	while elapsed < timeout_seconds:
		if not bool(customer.call("is_shop_session_active")):
			return true
		await create_timer(0.05).timeout
		elapsed += 0.05
	return false

func _wait_for_audio_idle() -> void:
	var audio_system: Node = root.get_node("AudioSystem")
	for _index in range(40):
		var is_playing := false
		var players: Array = audio_system.get("_players")
		for value in players:
			var player := value as AudioStreamPlayer
			if player != null and player.playing:
				is_playing = true
				break
		if not is_playing:
			return
		await create_timer(0.05).timeout

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
