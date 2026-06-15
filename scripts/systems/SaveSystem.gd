extends Node

# Autoload singleton. Saves and loads the run to user://savegame.json.
# Stores only stable ids and state (day, inventory, gold, depleted gatherables).
# Auto-loads any existing save on startup. Must be the LAST autoload so the
# systems it writes into are already initialised.

const SAVE_PATH := "user://savegame.json"
const VERSION := "0.1.0"

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
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: could not open save file for writing")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("SaveSystem: saved (day %d, gold %d)" % [DaySystem.get_day(), Inventory.get_gold()])

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
	print("SaveSystem: loaded (day %d, gold %d)" % [DaySystem.get_day(), Inventory.get_gold()])
