extends Node

# Autoload singleton for the one tiny Moonleaf planter introduced in slice 1.7.
# This is intentionally not a generic farming framework.

signal planter_changed(planter_id: String)

const DEFAULT_PLANTER_ID := "moonleaf_planter_001"
const STATE_EMPTY := "empty"
const STATE_PLANTED := "planted"
const STATE_HARVESTED := "harvested"
const STAGE_EMPTY := "empty"
const STAGE_SPROUT := "sprout"
const STAGE_YOUNG := "young"
const STAGE_READY := "ready"
const STAGE_HARVESTED := "harvested"
const SEED_ITEM_ID := "moonleaf_seed_packet"
const HARVEST_ITEM_ID := "moonleaf"
const HARVEST_QUANTITY := 2
const GROWTH_DAYS := 2

var _planters: Dictionary = {}

func get_stage(planter_id: String = DEFAULT_PLANTER_ID) -> String:
	var state := get_state(planter_id)
	if state == STATE_EMPTY:
		return STAGE_EMPTY
	if state == STATE_HARVESTED:
		return STAGE_HARVESTED
	if is_ready(planter_id):
		return STAGE_READY
	var age := get_age(planter_id)
	return STAGE_SPROUT if age <= 0 else STAGE_YOUNG

func get_state(planter_id: String = DEFAULT_PLANTER_ID) -> String:
	var data := _get_planter_data(planter_id)
	return String(data.get("state", STATE_EMPTY))

func get_age(planter_id: String = DEFAULT_PLANTER_ID) -> int:
	var data := _get_planter_data(planter_id)
	if String(data.get("state", STATE_EMPTY)) != STATE_PLANTED:
		return 0
	var planted_day := int(data.get("planted_day", DaySystem.get_day()))
	return maxi(0, DaySystem.get_day() - planted_day)

func is_ready(planter_id: String = DEFAULT_PLANTER_ID) -> bool:
	return get_state(planter_id) == STATE_PLANTED and get_age(planter_id) >= GROWTH_DAYS

func can_plant(planter_id: String = DEFAULT_PLANTER_ID) -> bool:
	var state := get_state(planter_id)
	return state == STATE_EMPTY or state == STATE_HARVESTED

func plant(planter_id: String = DEFAULT_PLANTER_ID) -> bool:
	if not can_plant(planter_id):
		return false
	if not Inventory.remove_item(SEED_ITEM_ID, 1):
		return false
	_planters[planter_id] = {
		"state": STATE_PLANTED,
		"planted_day": DaySystem.get_day(),
	}
	planter_changed.emit(planter_id)
	return true

func harvest(planter_id: String = DEFAULT_PLANTER_ID) -> bool:
	if not is_ready(planter_id):
		return false
	Inventory.add_item(HARVEST_ITEM_ID, HARVEST_QUANTITY)
	_planters[planter_id] = {
		"state": STATE_HARVESTED,
		"planted_day": DaySystem.get_day(),
	}
	planter_changed.emit(planter_id)
	return true

func clear() -> void:
	_planters.clear()
	planter_changed.emit(DEFAULT_PLANTER_ID)

func get_save_data() -> Dictionary:
	return _planters.duplicate(true)

func load_from(data: Variant) -> void:
	_planters.clear()
	if typeof(data) != TYPE_DICTIONARY:
		planter_changed.emit(DEFAULT_PLANTER_ID)
		return
	var source: Dictionary = data
	for id in source:
		var planter_id := String(id)
		var value: Variant = source[id]
		if planter_id == "" or typeof(value) != TYPE_DICTIONARY:
			continue
		var planter_data: Dictionary = value
		var state := String(planter_data.get("state", STATE_EMPTY))
		if state != STATE_EMPTY and state != STATE_PLANTED and state != STATE_HARVESTED:
			continue
		if state == STATE_EMPTY:
			continue
		_planters[planter_id] = {
			"state": state,
			"planted_day": maxi(1, int(planter_data.get("planted_day", DaySystem.get_day()))),
		}
	planter_changed.emit(DEFAULT_PLANTER_ID)

func _get_planter_data(planter_id: String) -> Dictionary:
	var value: Variant = _planters.get(planter_id, {})
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate()
