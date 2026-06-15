extends Node

# Autoload singleton. Tracks the current day and which gatherables are depleted.
# Depletion is stored here (not in the scene) so it persists when the player
# leaves and re-enters an area within the same day, and resets when a new day
# begins (sleeping).

signal day_changed(day: int)

var day: int = 1
var _gatherable_depleted: Dictionary = {}

func get_day() -> int:
	return day

func is_gatherable_depleted(id: String) -> bool:
	return _gatherable_depleted.get(id, false)

func set_gatherable_depleted(id: String, value: bool) -> void:
	if value:
		_gatherable_depleted[id] = true
	else:
		_gatherable_depleted.erase(id)

func advance_day() -> void:
	day += 1
	_gatherable_depleted.clear()
	# Refill any gatherables currently in the loaded scene.
	get_tree().call_group("gatherables", "reset_for_new_day")
	day_changed.emit(day)

# --- save support ---

func get_depleted_dict() -> Dictionary:
	return _gatherable_depleted.duplicate()

func apply_state(loaded_day: int, depleted: Dictionary) -> void:
	day = maxi(1, loaded_day)
	_gatherable_depleted = depleted.duplicate()
	day_changed.emit(day)
