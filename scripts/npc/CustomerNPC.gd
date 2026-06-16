extends "res://scripts/core/Interactable.gd"

# A customer who walks up to the counter wanting one item. Talking to them runs
# the request dialogue, attempts the sale, then shows a success or failure line.

@export var request_id: String = "first_calming_tea_request"
@export var entry_offset: Vector2 = Vector2(0, -48)

var _fulfilled: bool = false
var _busy: bool = false
var _waiting_position: Vector2 = Vector2.ZERO
var _present: bool = true

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()
	_waiting_position = position
	_set_present(false)
	CraftingSystem.crafting_completed.connect(_on_crafting_completed)
	DaySystem.day_changed.connect(_on_day_changed)
	_maybe_enter_if_request_ready(false)

func interact() -> void:
	if _busy or not _present:
		return
	interacted.emit()
	if _fulfilled:
		_say("Customer", ["Thank you again, witch."])
		return
	_busy = true
	_run_sale()

func _run_sale() -> void:
	var req := ShopRequestDatabase.get_request(request_id)
	if req.is_empty():
		_busy = false
		return
	var customer_name := String(req.get("customer_name", "Customer"))

	await _say(customer_name, req.get("request_lines", []))

	var item_id := String(req.get("requested_item_id", ""))
	var quantity := int(req.get("quantity", 1))
	var gold := int(req.get("offered_gold", 0))

	if ShopSystem.try_sell(item_id, quantity, gold):
		_fulfilled = true
		await _say(customer_name, req.get("success_lines", []))
		await _leave_shop()
	else:
		await _say(customer_name, req.get("fail_lines", []))

	_busy = false

func show_prompt(value: bool) -> void:
	super.show_prompt(value and _present and not _busy)

# Shows dialogue and waits for it to finish (no-op if there are no lines).
func _say(speaker_name: String, lines: Array) -> void:
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished

func _on_crafting_completed(item_id: String, _quantity: int) -> void:
	if _fulfilled or _present:
		return
	var req := ShopRequestDatabase.get_request(request_id)
	if req.is_empty():
		return
	if item_id == String(req.get("requested_item_id", "")):
		_enter_shop()

func _on_day_changed(_day: int) -> void:
	_fulfilled = false
	_busy = false
	_set_present(false)
	_maybe_enter_if_request_ready(false)

func _maybe_enter_if_request_ready(animated: bool) -> void:
	if _fulfilled or _present:
		return
	var req := ShopRequestDatabase.get_request(request_id)
	if req.is_empty():
		return
	var item_id := String(req.get("requested_item_id", ""))
	var quantity := int(req.get("quantity", 1))
	if Inventory.has_item(item_id, quantity):
		if animated:
			_enter_shop()
		else:
			_set_present(true)

func _enter_shop() -> void:
	_set_present(true)
	position = _waiting_position + entry_offset
	modulate = Color(1, 1, 1, 0)
	var tween := create_tween()
	tween.tween_property(self, "position", _waiting_position, 0.45)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.25)

func _leave_shop() -> void:
	_busy = true
	super.show_prompt(false)
	var tween := create_tween()
	tween.tween_property(self, "position", _waiting_position + entry_offset, 0.45)
	tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	await tween.finished
	_set_present(false)
	position = _waiting_position
	modulate = Color.WHITE
	_busy = false

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	if _collision_shape:
		_collision_shape.disabled = not value
	if not value:
		super.show_prompt(false)
