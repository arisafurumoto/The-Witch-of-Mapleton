extends Node

# Autoload singleton. Saves and loads the run to user://savegame.json.
# Stores only stable ids and state (day, inventory, gold, depleted gatherables,
# current scene, and player position).
# Auto-loads any existing save on startup. Must be the LAST autoload so the
# systems it writes into are already initialised.

signal game_saved(day: int, gold: int)
signal game_loaded(day: int, gold: int)

const SAVE_PATH := "user://savegame.json"
const VERSION := "0.1.0"

var _pending_scene_path: String = ""
var _pending_player_position: Vector2 = Vector2.ZERO
var _has_pending_player_position: bool = false

func _ready() -> void:
	if has_save():
		load_game()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var data := {
		"version": VERSION,
		"day": DaySystem.get_day(),
		"inventory": Inventory.get_all(),
		"gold": Inventory.get_gold(),
		"gatherables_depleted": DaySystem.get_depleted_dict(),
		"current_scene": _get_current_scene_path(),
		"player_position": _get_player_position_data(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: could not open save file for writing")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("SaveSystem: saved (day %d, gold %d)" % [DaySystem.get_day(), Inventory.get_gold()])
	game_saved.emit(DaySystem.get_day(), Inventory.get_gold())

func load_game() -> void:
	if not has_save():
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveSystem: save file is not valid JSON")
		return
	var data: Dictionary = parsed
	Inventory.load_from(data.get("inventory", {}), int(data.get("gold", 0)))
	DaySystem.apply_state(int(data.get("day", 1)), data.get("gatherables_depleted", {}))
	_pending_scene_path = String(data.get("current_scene", ""))
	_has_pending_player_position = _read_player_position(data.get("player_position", {}))
	if _pending_scene_path != "":
		call_deferred("_restore_saved_scene")
	print("SaveSystem: loaded (day %d, gold %d)" % [DaySystem.get_day(), Inventory.get_gold()])
	game_loaded.emit(DaySystem.get_day(), Inventory.get_gold())

func apply_pending_player_position(player: Node2D) -> void:
	if not _has_pending_player_position:
		return
	if _pending_scene_path != "" and _pending_scene_path != _get_current_scene_path():
		return
	player.global_position = _pending_player_position
	_has_pending_player_position = false

func _restore_saved_scene() -> void:
	var current_scene_path := _get_current_scene_path()
	if current_scene_path == "":
		call_deferred("_restore_saved_scene")
		return
	if _pending_scene_path == current_scene_path:
		return
	if not ResourceLoader.exists(_pending_scene_path):
		push_warning("SaveSystem: saved scene does not exist: " + _pending_scene_path)
		return
	get_tree().change_scene_to_file(_pending_scene_path)

func _get_current_scene_path() -> String:
	var scene := get_tree().current_scene
	if scene == null:
		return ""
	return scene.scene_file_path

func _get_player_position_data() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return {}
	return {
		"x": player.global_position.x,
		"y": player.global_position.y,
	}

func _read_player_position(value: Variant) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		return false
	var position_data: Dictionary = value
	if not position_data.has("x") or not position_data.has("y"):
		return false
	_pending_player_position = Vector2(float(position_data["x"]), float(position_data["y"]))
	return true
