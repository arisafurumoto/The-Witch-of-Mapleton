extends SceneTree

const SHOP_SCENE := "res://scenes/world/ShopInterior.tscn"
const EXTERIOR_SCENE := "res://scenes/world/ShopExterior.tscn"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_prepare_quiet_world_state()
	await _check_stackable_display()
	await _check_customer_queue()
	_check_front_door_wiring()
	await _wait_for_audio_idle()
	if _failures.is_empty():
		print("Vertical Slice 0.9 verification passed")
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
	day_system.call("apply_state", 3, {})
	inventory.call("load_from", {}, 0)
	recipe_knowledge.call("load_from", [])
	shop_state.call("clear")

func _check_stackable_display() -> void:
	var shop_state: Node = root.get_node("ShopState")
	var inventory: Node = root.get_node("Inventory")
	var recipe_knowledge: Node = root.get_node("RecipeKnowledgeSystem")
	shop_state.call("clear")
	shop_state.call("set_display_stock", "main_display", "calming_tea", 3)
	var saved_stock: Dictionary = shop_state.call("get_display_stock", "main_display")
	_check(int(saved_stock.get("quantity", 0)) == 3, "ShopState did not keep stacked display quantity")

	var shop := _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	var display := shop.get_node("ShopDisplay")
	var quantity_label := display.get_node("QuantityLabel") as Label
	_check(bool(display.call("has_stock")), "ShopDisplay did not restore stacked stock")
	_check(String(display.call("get_stock_item_id")) == "calming_tea", "ShopDisplay restored the wrong stock item")
	_check(int(display.call("get_stock_quantity")) == 3, "ShopDisplay restored the wrong stock quantity")
	_check(quantity_label != null, "ShopDisplay is missing QuantityLabel")
	if quantity_label != null:
		_check(quantity_label.visible, "QuantityLabel is hidden while the display is stocked")
		_check(quantity_label.text == "x3", "QuantityLabel did not show x3 for stacked stock")

	inventory.call("load_from", {"calming_tea": 1, "glowberry_cordial": 1}, 0)
	display.call("stock_item_from_inventory", "calming_tea")
	_check(int(display.call("get_stock_quantity")) == 4, "Adding matching stock did not increment the display")
	_check(int(inventory.call("get_quantity", "calming_tea")) == 0, "Adding matching stock did not remove inventory")
	saved_stock = shop_state.call("get_display_stock", "main_display")
	_check(int(saved_stock.get("quantity", 0)) == 4, "Stacked display quantity did not sync to ShopState")
	if quantity_label != null:
		_check(quantity_label.text == "x4", "QuantityLabel did not update after adding stock")

	display.call("stock_item_from_inventory", "glowberry_cordial")
	_check(String(display.call("get_stock_item_id")) == "calming_tea", "Different inventory item overwrote existing display stock")
	_check(int(display.call("get_stock_quantity")) == 4, "Different inventory item changed existing display quantity")
	_check(int(inventory.call("get_quantity", "glowberry_cordial")) == 1, "Different inventory item was removed while display held another item")

	display.call("load_from_save", {})
	if quantity_label != null:
		_check(not quantity_label.visible, "QuantityLabel stayed visible after display became empty")

	recipe_knowledge.call("unlock_recipe", "glowberry_cordial", false)
	inventory.call("load_from", {"glowberry_cordial": 1}, 0)
	display.call("stock_item_from_inventory", "glowberry_cordial")
	_check(String(display.call("get_stock_item_id")) == "glowberry_cordial", "Known Glowberry Cordial could not be stocked")
	_check(int(display.call("get_stock_quantity")) == 1, "Glowberry Cordial stock quantity was incorrect")

	shop.queue_free()
	await process_frame
	await process_frame
	shop_state.call("clear")
	inventory.call("load_from", {}, 0)
	recipe_knowledge.call("load_from", [])

func _check_customer_queue() -> void:
	var shop_state: Node = root.get_node("ShopState")
	var inventory: Node = root.get_node("Inventory")
	shop_state.call("clear")
	shop_state.call("set_display_stock", "main_display", "calming_tea", 3)
	inventory.call("load_from", {}, 0)

	var shop := _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	_make_customer_route_fast(shop)
	var display := shop.get_node("ShopDisplay")
	var sign := shop.get_node("Sign")
	var customer := shop.get_node("Customer")
	var item_database: Node = root.get_node("ItemDatabase")
	var calming_tea_price := int(item_database.call("get_sell_price", "calming_tea"))
	var starting_gold := int(inventory.call("get_gold"))
	sign.call("interact")
	_check(bool(customer.call("is_shop_session_active")), "Opening the shop did not start a customer queue")
	_check(int(customer.get("_queued_customers_remaining")) == 2, "Opening with 3 stock did not plan two follow-up customers")
	_check(_active_customer_count() <= 1, "More than one customer became active at once")

	var reached_counter := await _wait_for_customer_at_counter(customer, 4.0)
	_check(reached_counter, "First customer did not reach the counter")
	_check(int(display.call("get_available_stock_quantity")) == 2, "Reserved customer item did not leave two visible stock")
	_check(_active_customer_count() <= 1, "More than one customer was active while first customer waited")

	customer.call("_confirm_display_sale")
	await _finish_customer_dialogue()
	reached_counter = await _wait_for_customer_at_counter(customer, 5.0)
	_check(reached_counter, "Second customer did not begin after the first customer left")
	_check(int(display.call("get_stock_quantity")) == 2, "First sale did not decrement display stock by one")
	_check(int(inventory.call("get_gold")) == starting_gold + calming_tea_price, "First sale did not award one item sell price")
	_check(int(customer.get("_queued_customers_remaining")) == 1, "Second customer did not consume one queued slot")
	_check(_active_customer_count() <= 1, "More than one customer was active while second customer waited")

	customer.call("_confirm_display_sale")
	await _finish_customer_dialogue()
	reached_counter = await _wait_for_customer_at_counter(customer, 5.0)
	_check(reached_counter, "Third customer did not begin after the second customer left")
	_check(int(display.call("get_stock_quantity")) == 1, "Second sale did not decrement display stock by one")
	_check(int(inventory.call("get_gold")) == starting_gold + calming_tea_price * 2, "Second sale did not award one item sell price")

	customer.call("_confirm_display_sale")
	await _finish_customer_dialogue()
	var queue_ended := await _wait_for_queue_inactive(customer, 5.0)
	_check(queue_ended, "Customer queue did not end after the planned customers were served")
	_check(not bool(display.call("has_stock")), "Display was not empty after three one-item sales")
	_check(int(inventory.call("get_gold")) == starting_gold + calming_tea_price * 3, "Final gold did not match three one-item sales")
	var saved_stock: Dictionary = shop_state.call("get_display_stock", "main_display")
	_check(saved_stock.is_empty(), "ShopState did not clear display stock after the final sale")
	_check(_active_customer_count() <= 1, "More than one customer was active after the queue ended")
	await process_frame

	shop.queue_free()
	await process_frame
	await process_frame
	shop_state.call("clear")
	inventory.call("load_from", {}, starting_gold)

func _check_front_door_wiring() -> void:
	_check(ResourceLoader.exists(EXTERIOR_SCENE), "ShopExterior.tscn does not exist")
	var shop := _instantiate_scene(SHOP_SCENE)
	var exterior := _instantiate_scene(EXTERIOR_SCENE)
	if shop == null or exterior == null:
		return
	var front_door := shop.get_node("FrontDoor")
	_check(String(front_door.get("target_scene")) == EXTERIOR_SCENE, "Shop front door no longer targets the exterior")
	_check(shop.has_node("VisitorEntrance"), "Shop visitor entrance marker is missing")
	_check(shop.has_node("VisitorInteriorWaypoint"), "Shop visitor interior waypoint is missing")
	_check(exterior.has_node("ReturnDoor"), "Shop exterior return door is missing")
	var return_door := exterior.get_node("ReturnDoor")
	_check(String(return_door.get("target_scene")) == SHOP_SCENE, "Exterior return door no longer targets the shop")
	shop.free()
	exterior.free()

func _make_customer_route_fast(shop: Node) -> void:
	var route_position := Vector2(120, 120)
	(shop.get_node("VisitorEntrance") as Node2D).position = route_position
	(shop.get_node("VisitorInteriorWaypoint") as Node2D).position = route_position
	(shop.get_node("CustomerCounterAisle") as Node2D).position = route_position
	(shop.get_node("CustomerCounterApproach") as Node2D).position = route_position
	(shop.get_node("ShopDisplay") as Node2D).position = route_position
	var customer := shop.get_node("Customer")
	customer.set("counter_position", route_position)
	customer.set("browse_time", 0.01)

func _finish_customer_dialogue() -> void:
	var dialogue := root.get_node("DialogueBox")
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

func _active_customer_count() -> int:
	var count := 0
	for customer in get_nodes_in_group("shop_customers"):
		if bool(customer.call("is_shop_session_active")):
			count += 1
	return count

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
