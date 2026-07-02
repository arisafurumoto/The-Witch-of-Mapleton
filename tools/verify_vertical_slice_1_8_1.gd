extends SceneTree

const SHOP_SCENE := "res://scenes/world/ShopInterior.tscn"
const SHOP_EXTERIOR_SCENE := "res://scenes/world/ShopExterior.tscn"
const FOREST_PATH_SCENE := "res://scenes/world/ForestPath.tscn"
const MATURE_MOONLEAF_TEXTURE := "res://art/props/forest/moonleaf_bush.png"
const BROOK_WATER_ID := "forest_path_brook_water_001"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _check_display_picker_and_retrieve()
	await _check_root_wake_tonic_is_sellable_display_stock()
	await _check_mature_moonleaf_uses_existing_art()
	await _check_forest_path_water_source()
	if _failures.is_empty():
		print("Vertical Slice 1.8.1 feedback verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_display_picker_and_retrieve() -> void:
	_prepare_shop_state()
	var shop: Node = _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	var display_panel: Node = root.get_node("DisplayStockPanel")
	var display: Node = shop.get_node("ShopDisplay")
	display.call("interact")
	await process_frame
	_check(bool(display_panel.call("is_active")), "Display interaction did not open DisplayStockPanel")

	display_panel.call("_on_stock_pressed", "glowberry_cordial")
	await process_frame
	_check(String(display.call("get_stock_item_id")) == "glowberry_cordial", "Picker did not stock the chosen item")
	_check(int(display.call("get_stock_quantity")) == 1, "Picker stocked the wrong quantity")
	var inventory: Node = root.get_node("Inventory")
	_check(int(inventory.call("get_quantity", "glowberry_cordial")) == 0, "Picker did not remove the chosen item from inventory")

	display_panel.call("_on_retrieve_pressed")
	await process_frame
	_check(not bool(display.call("has_stock")), "Take back did not clear display stock")
	_check(int(inventory.call("get_quantity", "glowberry_cordial")) == 1, "Take back did not return display stock to inventory")
	display_panel.call("close")

	shop.queue_free()
	await process_frame
	await process_frame

func _check_root_wake_tonic_is_sellable_display_stock() -> void:
	var inventory: Node = root.get_node("Inventory")
	var recipe_knowledge: Node = root.get_node("RecipeKnowledgeSystem")
	var quest_system: Node = root.get_node("QuestSystem")
	var shop_state: Node = root.get_node("ShopState")
	var day_system: Node = root.get_node("DaySystem")
	inventory.call("load_from", {"root_wake_tonic": 1}, 0)
	recipe_knowledge.call("load_from", [])
	shop_state.call("clear")
	day_system.call("apply_state", 1, {})
	quest_system.call("load_from", {"sage_first_request": "active"})

	var item_database: Node = root.get_node("ItemDatabase")
	_check(int(item_database.call("get_sell_price", "root_wake_tonic")) == 22, "Root-Wake Tonic sell price is not 22")

	var shop: Node = _instantiate_scene(SHOP_SCENE)
	if shop == null:
		return
	root.add_child(shop)
	await process_frame
	await process_frame

	var display_panel: Node = root.get_node("DisplayStockPanel")
	var display: Node = shop.get_node("ShopDisplay")
	display.call("interact")
	await process_frame
	display_panel.call("_on_stock_pressed", "root_wake_tonic")
	await process_frame
	_check(String(display.call("get_stock_item_id")) == "root_wake_tonic", "Display picker did not stock quest-active Root-Wake Tonic")
	_check(int(display.call("get_stock_quantity")) == 1, "Root-Wake Tonic display stock quantity is incorrect")
	_check(int(inventory.call("get_quantity", "root_wake_tonic")) == 0, "Root-Wake Tonic was not removed from inventory when stocked")
	display_panel.call("close")

	shop.queue_free()
	await process_frame
	await process_frame

func _check_mature_moonleaf_uses_existing_art() -> void:
	root.get_node("Inventory").call("load_from", {}, 0)
	root.get_node("DaySystem").call("apply_state", 8, {})
	root.get_node("PlanterSystem").call("load_from", {
		"moonleaf_planter_001": {
			"state": "planted",
			"planted_day": 6,
		}
	})
	var exterior: Node = _instantiate_scene(SHOP_EXTERIOR_SCENE)
	if exterior == null:
		return
	root.add_child(exterior)
	await process_frame
	await process_frame

	_check(exterior.has_node("MoonleafPlanter/GrowthVisual"), "MoonleafPlanter is missing GrowthVisual")
	if exterior.has_node("MoonleafPlanter/GrowthVisual"):
		var growth_visual := exterior.get_node("MoonleafPlanter/GrowthVisual") as Sprite2D
		_check(growth_visual.texture != null, "Ready Moonleaf planter has no texture")
		if growth_visual.texture != null:
			_check(growth_visual.texture.resource_path == MATURE_MOONLEAF_TEXTURE, "Ready Moonleaf planter is not using the existing Moonleaf bush art")

	exterior.queue_free()
	await process_frame
	await process_frame

func _check_forest_path_water_source() -> void:
	var inventory: Node = root.get_node("Inventory")
	var day_system: Node = root.get_node("DaySystem")
	inventory.call("load_from", {}, 0)
	day_system.call("apply_state", 5, {})
	var forest_path: Node = _instantiate_scene(FOREST_PATH_SCENE)
	if forest_path == null:
		return
	root.add_child(forest_path)
	await process_frame
	await process_frame

	_check(forest_path.has_node("BrookWaterGathering"), "ForestPath is missing BrookWaterGathering")
	if forest_path.has_node("BrookWaterGathering"):
		var water: Node = forest_path.get_node("BrookWaterGathering")
		_check(String(water.get("gatherable_id")) == BROOK_WATER_ID, "Brook water source has the wrong stable gatherable id")
		_check(String(water.get("item_id")) == "forest_water", "Brook water source does not give Forest Water")
		water.call("interact")
		await process_frame
		_stop_audio_players()
		await process_frame
		_check(int(inventory.call("get_quantity", "forest_water")) == 1, "Brook water source did not add Forest Water")
		_check(bool(day_system.call("is_gatherable_depleted", BROOK_WATER_ID)), "Brook water source depletion was not stored in DaySystem")

	forest_path.queue_free()
	await process_frame
	await process_frame

func _prepare_shop_state() -> void:
	root.get_node("Inventory").call("load_from", {"calming_tea": 1, "glowberry_cordial": 1}, 0)
	root.get_node("RecipeKnowledgeSystem").call("load_from", ["glowberry_cordial"])
	root.get_node("ShopState").call("clear")
	root.get_node("DaySystem").call("apply_state", 5, {})

func _instantiate_scene(path: String) -> Node:
	var resource := load(path) as PackedScene
	if resource == null:
		_failures.append("Could not load scene: " + path)
		return null
	return resource.instantiate()

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

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
