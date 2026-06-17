extends "res://scripts/core/Interactable.gd"

# A prototype shop customer. After the shop is opened, they browse the stocked
# display, bring the item to the counter, and wait for Marigold to confirm the sale.

@export var request_id: String = "first_calming_tea_request"
@export var entry_offset: Vector2 = Vector2(0, -48)
@export var display_path: NodePath
@export var counter_position: Vector2 = Vector2(250, 200)
@export var browse_time: float = 0.8

var _fulfilled: bool = false
var _busy: bool = false
var _waiting_position: Vector2 = Vector2.ZERO
var _present: bool = true
var _state: String = "hidden"

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super._ready()
	add_to_group("shop_customers")
	_waiting_position = position
	_set_present(false)
	DaySystem.day_changed.connect(_on_day_changed)

func interact() -> void:
	if _busy or not _present:
		return
	interacted.emit()
	if _fulfilled:
		_say("Customer", ["Thank you again, witch."])
		return
	if _state == "at_counter":
		_confirm_display_sale()

func start_shop_session() -> void:
	if _busy or _present or _fulfilled:
		return
	var display := _display()
	if display == null or not display.has_method("has_stock") or not bool(display.call("has_stock")):
		HUD.show_toast("Stock the display first")
		return
	_busy = true
	_state = "entering"
	_set_present(true)
	position = _waiting_position + entry_offset
	modulate = Color(1, 1, 1, 0)
	await _walk_to(display.global_position + Vector2(0, 18), 0.55, true)
	_state = "browsing"
	await get_tree().create_timer(browse_time).timeout
	if not bool(display.call("has_stock")):
		await _leave_shop()
		return
	var chosen_item_id := String(display.call("get_stock_item_id"))
	HUD.show_toast("Customer chose %s" % ItemDatabase.get_item_name(chosen_item_id))
	await _walk_to(counter_position, 0.55, false)
	_state = "at_counter"
	prompt = "Sell item"
	_busy = false

func show_prompt(value: bool) -> void:
	if _label:
		_label.text = prompt
	super.show_prompt(value and _present and not _busy and _state == "at_counter")

# Shows dialogue and waits for it to finish (no-op if there are no lines).
func _say(speaker_name: String, lines: Array) -> void:
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished

func _on_day_changed(_day: int) -> void:
	_fulfilled = false
	_busy = false
	_state = "hidden"
	_set_present(false)

func _confirm_display_sale() -> void:
	var display := _display()
	if display == null or not display.has_method("consume_stock"):
		return
	_busy = true
	var req := ShopRequestDatabase.get_request(request_id)
	var customer_name := String(req.get("customer_name", "Customer"))
	var stock: Dictionary = display.call("consume_stock")
	if stock.is_empty():
		await _say(customer_name, ["Oh, it looks like the display is empty now."])
		_busy = false
		return
	var item_id := String(stock.get("item_id", ""))
	var quantity := int(stock.get("quantity", 1))
	var gold := int(stock.get("gold", 0))
	if ShopSystem.complete_display_sale(item_id, quantity, gold):
		_fulfilled = true
		await _say(customer_name, [
			"I will take the %s, please." % ItemDatabase.get_item_name(item_id),
			"Here is your %d gold." % gold,
		])
	await _leave_shop()

func _leave_shop() -> void:
	_busy = true
	super.show_prompt(false)
	await _walk_to(_waiting_position + entry_offset, 0.45, false)
	_set_present(false)
	position = _waiting_position
	modulate = Color.WHITE
	_state = "hidden"
	_busy = false

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	if _collision_shape:
		_collision_shape.disabled = not value
	if not value:
		super.show_prompt(false)

func _walk_to(target_position: Vector2, duration: float, fade_in: bool) -> void:
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, duration)
	if fade_in:
		tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.25)
	else:
		tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.1)
	await tween.finished

func _display() -> Node2D:
	return get_node_or_null(display_path) as Node2D
