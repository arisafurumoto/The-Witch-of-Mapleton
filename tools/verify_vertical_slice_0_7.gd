extends SceneTree

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_data()
	_check_quest_chaining()
	await _check_camellia_scene()
	if _failures.is_empty():
		print("Vertical Slice 0.7 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_data() -> void:
	var item_database := root.get_node("ItemDatabase")
	var recipe_database := root.get_node("RecipeDatabase")
	var quest_database := root.get_node("QuestDatabase")
	_check(bool(item_database.call("has_item", "glowberry_cordial")), "Glowberry Cordial item is missing")
	_check(int(item_database.call("get_sell_price", "glowberry_cordial")) == 24, "Glowberry Cordial sell price is not 24")
	var item: Dictionary = item_database.call("get_item", "glowberry_cordial")
	var icon_path := String(item.get("icon", ""))
	_check(icon_path == "res://art/items/glowberry_cordial.png", "Glowberry Cordial icon path is incorrect")
	_check(FileAccess.file_exists(icon_path), "Glowberry Cordial icon source does not exist")
	_check(FileAccess.file_exists(icon_path + ".import"), "Glowberry Cordial icon import metadata does not exist")

	var recipe: Dictionary = recipe_database.call("get_recipe", "glowberry_cordial")
	_check(not recipe.is_empty(), "Glowberry Cordial recipe is missing")
	_check(String(recipe.get("quest_id", "")) == "camellia_first_request", "Glowberry Cordial recipe is not gated by Camellia's quest")
	_check(not bool(recipe.get("known_by_default", true)), "Glowberry Cordial is known by default")
	var ingredients: Dictionary = recipe.get("ingredients", {})
	_check(int(ingredients.get("moonleaf", 0)) == 1, "Glowberry Cordial needs the wrong Moonleaf count")
	_check(int(ingredients.get("glowberry", 0)) == 2, "Glowberry Cordial needs the wrong Glowberry count")
	_check(int(ingredients.get("forest_water", 0)) == 1, "Glowberry Cordial needs the wrong Forest Water count")

	var quest: Dictionary = quest_database.call("get_quest", "camellia_first_request")
	_check(not quest.is_empty(), "Camellia's first quest is missing")
	_check(String(quest.get("title", "")) == "A Brighter Menu", "Camellia quest title is incorrect")
	_check(String(quest.get("turn_in_item_id", "")) == "glowberry_cordial", "Camellia quest turn-in item is incorrect")
	_check(int(quest.get("reward_gold", 0)) == 30, "Camellia quest gold reward is not 30")
	_check(quest_database.call("get_minimum_day", "camellia_first_request") == 2, "Camellia quest minimum day is not 2")
	var required_ids: Array = quest_database.call("get_required_quest_ids", "camellia_first_request")
	_check(required_ids.has("sage_first_request"), "Camellia quest does not require Sage's first quest")

func _check_quest_chaining() -> void:
	var day_system := root.get_node("DaySystem")
	var inventory := root.get_node("Inventory")
	var quest_system := root.get_node("QuestSystem")
	var recipe_database := root.get_node("RecipeDatabase")
	var recipe_knowledge := root.get_node("RecipeKnowledgeSystem")
	var crafting_system := root.get_node("CraftingSystem")
	var panel := root.get_node("CauldronCraftingPanel")
	var hud := root.get_node("HUD")

	inventory.call("load_from", {}, 0)
	recipe_knowledge.call("load_from", [])
	quest_system.call("load_from", {})
	day_system.call("apply_state", 1, {})
	_check(not bool(quest_system.call("is_quest_available", "camellia_first_request")), "Camellia quest is available before Sage is complete")

	quest_system.call("load_from", {"sage_first_request": "completed"})
	day_system.call("apply_state", 1, {})
	_check(not bool(quest_system.call("is_quest_available", "camellia_first_request")), "Camellia quest is available before Day 2")
	day_system.call("apply_state", 2, {})
	_check(bool(quest_system.call("is_quest_available", "camellia_first_request")), "Camellia quest is not available on Day 2 after Sage is complete")
	quest_system.call("start_quest", "camellia_first_request")
	_check(String(quest_system.call("get_quest_state", "camellia_first_request")) == "active", "Camellia quest did not start")
	_check(not bool(recipe_knowledge.call("is_recipe_known", "glowberry_cordial")), "Glowberry Cordial is permanently known before quest completion")

	var quest: Dictionary = root.get_node("QuestDatabase").call("get_quest", "camellia_first_request")
	var objective := String(hud.call("_quest_objective_text", quest, "active"))
	_check(objective.contains("Moonleaf"), "HUD objective does not include Moonleaf progress")
	_check(objective.contains("Glowberry"), "HUD objective does not include Glowberry progress")
	_check(objective.contains("Forest Water"), "HUD objective does not include Forest Water progress")

	inventory.call("add_item", "moonleaf", 2)
	inventory.call("add_item", "glowberry", 4)
	inventory.call("add_item", "forest_water", 2)
	var recipe: Dictionary = recipe_database.call("get_recipe", "glowberry_cordial")
	var max_active: int = int(panel.call("_max_brew_quantity", recipe))
	_check(max_active == 1, "Glowberry Cordial quest brew is not capped to one batch")
	_check(bool(crafting_system.call("craft_quantity", "glowberry_cordial", 1)), "Could not craft Glowberry Cordial")
	_check(String(quest_system.call("get_quest_state", "camellia_first_request")) == "ready_to_turn_in", "Camellia quest did not become ready after crafting")
	_check(bool(quest_system.call("complete_quest", "camellia_first_request")), "Camellia quest could not be completed")
	_check(int(inventory.call("get_gold")) == 30, "Camellia quest did not award 30 gold")
	_check(int(inventory.call("get_quantity", "glowberry_cordial")) == 0, "Camellia quest did not consume the cordial")
	_check(bool(recipe_knowledge.call("is_recipe_known", "glowberry_cordial")), "Camellia quest did not unlock Glowberry Cordial")
	var save_data: Array = recipe_knowledge.call("get_save_data")
	_check(save_data.has("glowberry_cordial"), "Glowberry Cordial learned recipe was not saved")

	inventory.call("add_item", "moonleaf", 1)
	inventory.call("add_item", "glowberry", 2)
	inventory.call("add_item", "forest_water", 1)
	var max_completed: int = int(panel.call("_max_brew_quantity", recipe))
	_check(max_completed == 2, "Glowberry Cordial stayed quest-capped after completion")

func _check_camellia_scene() -> void:
	var day_system := root.get_node("DaySystem")
	var quest_system := root.get_node("QuestSystem")
	var inventory := root.get_node("Inventory")
	var recipe_knowledge := root.get_node("RecipeKnowledgeSystem")
	inventory.call("load_from", {}, 0)
	recipe_knowledge.call("load_from", [])
	quest_system.call("load_from", {"sage_first_request": "completed"})
	day_system.call("apply_state", 2, {})

	var shop := _instantiate_scene("res://scenes/world/ShopInterior.tscn")
	if shop == null:
		return
	root.add_child(shop)
	var camellia := shop.get_node("Camellia") as Node2D
	_check(camellia.position == Vector2(360, 260), "Camellia is not centred in front of the counter")
	_check(String(camellia.get("home_facing")) == "north", "Camellia is not facing the counter")
	_check(String(camellia.get("entrance_path")) == "../VisitorEntrance", "Camellia entrance path is incorrect")
	_check(String(camellia.get("interior_waypoint_path")) == "../VisitorInteriorWaypoint", "Camellia waypoint path is incorrect")

	var customer := shop.get_node("Customer")
	customer.call("_set_present", true)
	await process_frame
	_check(not camellia.visible, "Camellia began entering during an active customer session")
	customer.call("_set_present", false)
	camellia.call("_refresh_presence")
	await process_frame
	_check(camellia.visible, "Camellia did not enter after prerequisites were met")
	_check(camellia.is_in_group("closed_shop_visitors"), "Camellia is not registered as a closed-shop visitor")
	await create_timer(2.6).timeout
	var sign := shop.get_node("Sign")
	_check(bool(sign.call("_has_closed_shop_visitor")), "Shop sign does not detect Camellia as a visitor")
	sign.call("show_prompt", true)
	_check(String(sign.get_node("PromptLabel").text) == "Visitor here", "Shop sign did not show visitor prompt for Camellia")
	var player := shop.get_node("Player") as Node2D
	player.position = camellia.position + Vector2(80, 0)
	camellia.call("_face_player")
	_check(String(camellia.get_node("Visual").animation) == "idle_east", "Camellia did not turn toward Marigold")

	shop.queue_free()
	await process_frame

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
