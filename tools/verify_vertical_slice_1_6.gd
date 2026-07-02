extends SceneTree

const SHOP_INTERIOR_SCENE := "res://scenes/world/ShopInterior.tscn"
const SHOP_EXTERIOR_SCENE := "res://scenes/world/ShopExterior.tscn"
const MAPLETON_LANE_SCENE := "res://scenes/world/MapletonLane.tscn"
const FOREST_CLEARING_SCENE := "res://scenes/world/ForestClearing.tscn"
const FOREST_PATH_SCENE := "res://scenes/world/ForestPath.tscn"
const SAGE_RESTOCK_QUEST := "sage_seedling_restock"

const NEW_ART_PATHS := [
	"res://art/props/shop_exterior/witch_shop_facade.png",
	"res://art/props/shop_exterior/front_step.png",
	"res://art/props/shop_exterior/crates.png",
	"res://art/props/shop_exterior/shrub_cluster.png",
	"res://art/props/shop_exterior/future_planter_marker.png",
	"res://art/props/shop_exterior/lantern_post.png",
	"res://art/props/shop_exterior/mailbox.png",
	"res://art/props/town/fence_long.png",
	"res://art/props/town/notice_board.png",
	"res://art/props/town/restaurant_stall.png",
	"res://art/props/town/plant_stall.png",
	"res://art/props/town/shrub_bank.png",
	"res://art/props/forest/brookmint_patch.png",
	"res://art/props/forest/thicket.png",
	"res://art/props/forest/forest_path_gate.png",
	"res://art/props/forest/brook_sparkles.png",
]

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check_scene_resources()
	_check_new_art_resources()
	_check_shop_exterior()
	_check_mapleton_lane()
	_check_forest_clearing()
	_check_forest_path()
	if _failures.is_empty():
		print("Vertical Slice 1.6 verification passed")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)

func _check_scene_resources() -> void:
	for path in [SHOP_EXTERIOR_SCENE, MAPLETON_LANE_SCENE, FOREST_CLEARING_SCENE, FOREST_PATH_SCENE]:
		_check(ResourceLoader.exists(String(path)), "Scene does not exist: " + String(path))

func _check_new_art_resources() -> void:
	for path in NEW_ART_PATHS:
		var art_path := String(path)
		_check(ResourceLoader.exists(art_path), "New art resource is not loadable: " + art_path)
		_check(FileAccess.file_exists(art_path + ".import"), "New art resource has not been imported: " + art_path)

func _check_shop_exterior() -> void:
	var exterior: Node = _instantiate_scene(SHOP_EXTERIOR_SCENE)
	if exterior == null:
		return
	_check_player_cat_and_camera(exterior, "ShopExterior", true)
	_check_boundaries(exterior, "Boundaries", "ShopExterior")
	_check_door(exterior, "ReturnDoor", SHOP_INTERIOR_SCENE, Vector2(360, 420), "north", "ShopExterior")
	_check_door(exterior, "LaneDoor", MAPLETON_LANE_SCENE, Vector2(360, 84), "south", "ShopExterior")
	_check_sprite(exterior, "ShopFacade/FacadeSprite", "ShopExterior")
	_check_sprite(exterior, "FrontStepSprite", "ShopExterior")
	_check_sprite(exterior, "Crates/CrateSprite", "ShopExterior")
	_check_sprite(exterior, "Shrubs/ShrubSprite", "ShopExterior")
	_check_sprite(exterior, "FuturePlanterMarker/PolishedVisual", "ShopExterior")
	_check_sprite(exterior, "FenceLeftSprite", "ShopExterior")
	_check_sprite(exterior, "FenceRightSprite", "ShopExterior")
	_check_sprite(exterior, "LanternPostSprite", "ShopExterior")
	_check_sprite(exterior, "MailboxSprite", "ShopExterior")
	_check(exterior.has_node("FuturePlanterMarker"), "ShopExterior is missing the future planter marker")
	if exterior.has_node("FuturePlanterMarker"):
		_check_visual_only_marker(exterior.get_node("FuturePlanterMarker"))
	exterior.free()

func _check_mapleton_lane() -> void:
	var lane: Node = _instantiate_scene(MAPLETON_LANE_SCENE)
	if lane == null:
		return
	_check_player_cat_and_camera(lane, "MapletonLane", true)
	_check_boundaries(lane, "Boundaries", "MapletonLane")
	_check_door(lane, "ReturnDoor", SHOP_EXTERIOR_SCENE, Vector2(360, 420), "north", "MapletonLane")
	_check(lane.has_node("NoticeBoard"), "MapletonLane is missing the notice board")
	_check(lane.has_node("Camellia"), "MapletonLane is missing Camellia")
	_check(lane.has_node("Sage"), "MapletonLane is missing Sage")
	_check(lane.has_node("RestaurantStall/CollisionShape2D"), "MapletonLane restaurant stall collision is missing")
	_check(lane.has_node("PlantStall/CollisionShape2D"), "MapletonLane plant stall collision is missing")
	_check_sprite(lane, "NoticeBoard/BoardSprite", "MapletonLane")
	_check_sprite(lane, "RestaurantStall/StallSprite", "MapletonLane")
	_check_sprite(lane, "PlantStall/StallSprite", "MapletonLane")
	_check_sprite(lane, "VillageEdgeShrubsLeftSprite", "MapletonLane")
	_check_sprite(lane, "VillageEdgeShrubsRightSprite", "MapletonLane")
	_check_sprite(lane, "FenceLeftSprite", "MapletonLane")
	_check_sprite(lane, "FenceRightSprite", "MapletonLane")
	lane.free()

func _check_forest_clearing() -> void:
	var clearing: Node = _instantiate_scene(FOREST_CLEARING_SCENE)
	if clearing == null:
		return
	_check_player_cat_and_camera(clearing, "ForestClearing", false)
	_check_boundaries(clearing, "Walls", "ForestClearing")
	_check_door(clearing, "Door", SHOP_INTERIOR_SCENE, Vector2(360, 100), "south", "ForestClearing")
	_check(clearing.has_node("ForestPathDoor"), "ForestClearing is missing ForestPathDoor")
	if clearing.has_node("ForestPathDoor"):
		var forest_path_door: Node = clearing.get_node("ForestPathDoor")
		_check(forest_path_door.has_method("is_unlocked"), "ForestPathDoor no longer uses quest-locked behavior")
		_check(String(forest_path_door.get("target_scene")) == FOREST_PATH_SCENE, "ForestPathDoor targets the wrong scene")
		_check(bool(forest_path_door.get("use_target_player_position")), "ForestPathDoor does not set explicit arrival metadata")
		var path_position: Vector2 = forest_path_door.get("target_player_position")
		_check(path_position == Vector2(88, 252), "ForestPathDoor arrival position changed")
		_check(String(forest_path_door.get("target_player_facing")) == "east", "ForestPathDoor arrival facing changed")
		_check(String(forest_path_door.get("required_completed_quest_id")) == SAGE_RESTOCK_QUEST, "ForestPathDoor uses the wrong unlock quest")
		_check_sprite(clearing, "ForestPathDoor/GateSprite", "ForestClearing")
	_check_gatherable(clearing, "MoonleafBush", "moonleaf", "moonleaf_bush_001", "ForestClearing")
	_check_gatherable(clearing, "ForestWaterSpring", "forest_water", "forest_water_spring_001", "ForestClearing")
	_check_gatherable(clearing, "DewcapMushrooms", "dewcap_mushroom", "dewcap_mushrooms_001", "ForestClearing")
	_check_gatherable(clearing, "GlowberryBush", "glowberry", "glowberry_bush_001", "ForestClearing")
	clearing.free()

func _check_forest_path() -> void:
	var path: Node = _instantiate_scene(FOREST_PATH_SCENE)
	if path == null:
		return
	_check_player_cat_and_camera(path, "ForestPath", true)
	_check_boundaries(path, "Boundaries", "ForestPath")
	_check_door(path, "ReturnDoor", FOREST_CLEARING_SCENE, Vector2(780, 300), "west", "ForestPath")
	_check(path.has_node("Path"), "ForestPath is missing the compact walking path")
	_check(path.has_node("Brook"), "ForestPath is missing the brook visual")
	_check_sprite(path, "BrookSparklesTop", "ForestPath")
	_check_sprite(path, "BrookSparklesBottom", "ForestPath")
	_check(path.has_node("UpperThicket/CollisionShape2D"), "ForestPath upper thicket collision is missing")
	_check(path.has_node("LowerThicket/CollisionShape2D"), "ForestPath lower thicket collision is missing")
	_check_sprite(path, "UpperThicket/ThicketSprite", "ForestPath")
	_check_sprite(path, "LowerThicket/ThicketSprite", "ForestPath")
	_check_gatherable(path, "BrookmintPatchA", "brookmint", "brookmint_patch_001", "ForestPath")
	_check_gatherable(path, "BrookmintPatchB", "brookmint", "brookmint_patch_002", "ForestPath")
	_check_sprite(path, "BrookmintPatchA/Visual", "ForestPath")
	_check_sprite(path, "BrookmintPatchB/Visual", "ForestPath")
	path.free()

func _check_player_cat_and_camera(scene: Node, scene_name: String, require_camera_limits: bool) -> void:
	_check(scene.has_node("Player"), scene_name + " is missing Player")
	_check(scene.has_node("Cat"), scene_name + " is missing Saffron")
	_check(scene.has_node("Player/Camera2D"), scene_name + " is missing the player camera")
	if scene.has_node("Player/Camera2D") and require_camera_limits:
		var camera := scene.get_node("Player/Camera2D") as Camera2D
		_check(camera.limit_right > 0, scene_name + " camera right limit is not explicit")
		_check(camera.limit_bottom > 0, scene_name + " camera bottom limit is not explicit")

func _check_boundaries(scene: Node, body_name: String, scene_name: String) -> void:
	for collision_name in ["CollTop", "CollBottom", "CollLeft", "CollRight"]:
		var collision_path := body_name + "/" + String(collision_name)
		_check(scene.has_node(collision_path), scene_name + " is missing boundary collision: " + collision_path)

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

func _check_gatherable(scene: Node, node_name: String, item_id: String, gatherable_id: String, scene_name: String) -> void:
	_check(scene.has_node(node_name), scene_name + " is missing gatherable: " + node_name)
	if not scene.has_node(node_name):
		return
	var gatherable: Node = scene.get_node(node_name)
	_check(String(gatherable.get("item_id")) == item_id, scene_name + " " + node_name + " gives the wrong item")
	_check(String(gatherable.get("gatherable_id")) == gatherable_id, scene_name + " " + node_name + " gatherable id changed")

func _check_sprite(scene: Node, node_path: String, scene_name: String) -> void:
	_check(scene.has_node(node_path), scene_name + " is missing art sprite: " + node_path)
	if not scene.has_node(node_path):
		return
	var sprite := scene.get_node(node_path) as Sprite2D
	_check(sprite != null, scene_name + " art node is not a Sprite2D: " + node_path)
	if sprite == null:
		return
	_check(sprite.texture != null, scene_name + " art sprite has no texture: " + node_path)

func _check_visual_only_marker(marker: Node) -> void:
	_check(marker is Node2D, "FuturePlanterMarker should be a visual Node2D")
	_check(not (marker is Area2D), "FuturePlanterMarker must not be interactable")
	_check(marker.get_script() == null, "FuturePlanterMarker must not have behavior")
	_check(marker.has_node("SoilBed"), "FuturePlanterMarker is missing the soil bed visual")
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
