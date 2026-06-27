extends "res://scripts/core/Interactable.gd"

# A prototype shop customer. After the shop is opened, they browse the stocked
# display, bring the item to the counter, and wait for Marigold to confirm the sale.

@export var request_id: String = "first_calming_tea_request"
@export var entrance_path: NodePath
@export var interior_waypoint_path: NodePath
@export var counter_aisle_path: NodePath
@export var counter_approach_path: NodePath
@export var display_path: NodePath
@export var counter_position: Vector2 = Vector2(250, 200)
@export var browse_time: float = 0.8

const WALK_SPEED: float = 90.0

var _fulfilled: bool = false
var _busy: bool = false
var _waiting_position: Vector2 = Vector2.ZERO
var _present: bool = true
var _state: String = "hidden"
var _session_generation: int = 0

@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _sprite: AnimatedSprite2D = $Visual

func _ready() -> void:
	super._ready()
	add_to_group("shop_customers")
	_waiting_position = position
	_sprite.play("idle_south")
	_set_present(false)
	DaySystem.day_changed.connect(_on_day_changed)

func interact() -> void:
	if _busy or not _present:
		return
	interacted.emit()
	_face_player()
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
	_session_generation += 1
	var session_generation: int = _session_generation
	_state = "entering"
	position = _entrance_position()
	_set_present(true)
	_set_collision_enabled(false)
	await _walk_to(_interior_waypoint_position())
	if session_generation != _session_generation:
		return
	await _walk_to(display.position + Vector2(0, 18))
	if session_generation != _session_generation:
		return
	_state = "browsing"
	await get_tree().create_timer(browse_time).timeout
	if session_generation != _session_generation:
		return
	if not bool(display.call("has_stock")):
		await _leave_shop()
		return
	var chosen_item_id := String(display.call("get_stock_item_id"))
	if not display.has_method("reserve_stock") or not bool(display.call("reserve_stock")):
		await _leave_shop()
		return
	HUD.show_toast("Customer chose %s" % ItemDatabase.get_item_name(chosen_item_id))
	await _walk_to(_counter_aisle_position())
	if session_generation != _session_generation:
		return
	await _walk_to(_counter_approach_position())
	if session_generation != _session_generation:
		return
	await _walk_to(counter_position)
	if session_generation != _session_generation:
		return
	_state = "at_counter"
	prompt = "Attend customer"
	_sprite.play("idle_north")
	_busy = false
	_set_collision_enabled(true)

func is_shop_session_active() -> bool:
	return _present or _busy or _state != "hidden"

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
	_session_generation += 1
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
	_set_collision_enabled(false)
	if _state == "at_counter":
		await _walk_to(_counter_approach_position())
		await _walk_to(_counter_aisle_position())
	await _walk_to(_interior_waypoint_position())
	await _walk_to(_entrance_position())
	_set_present(false)
	position = _waiting_position
	_state = "hidden"
	_busy = false

func _set_present(value: bool) -> void:
	_present = value
	visible = value
	monitorable = value
	_set_collision_enabled(value and not _busy)
	if not value:
		super.show_prompt(false)

func _set_collision_enabled(value: bool) -> void:
	if _collision_shape:
		_collision_shape.disabled = not value

func _walk_to(target_position: Vector2) -> void:
	var movement: Vector2 = target_position - position
	var direction: String = _direction_for(movement)
	var duration: float = movement.length() / WALK_SPEED
	_sprite.play("walk_" + direction)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_position, duration)
	await tween.finished
	_sprite.play("idle_" + direction)

func _direction_for(delta_position: Vector2) -> String:
	if absf(delta_position.x) > absf(delta_position.y):
		return "east" if delta_position.x >= 0.0 else "west"
	return "south" if delta_position.y >= 0.0 else "north"

func _face_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var direction := _direction_for(player.global_position - global_position)
	_sprite.play("idle_" + direction)

func _entrance_position() -> Vector2:
	var entrance := get_node_or_null(entrance_path) as Node2D
	if entrance != null:
		return entrance.position
	return _waiting_position

func _interior_waypoint_position() -> Vector2:
	var waypoint := get_node_or_null(interior_waypoint_path) as Node2D
	if waypoint != null:
		return waypoint.position
	return _entrance_position()

func _counter_aisle_position() -> Vector2:
	var waypoint := get_node_or_null(counter_aisle_path) as Node2D
	if waypoint != null:
		return waypoint.position
	return counter_position

func _counter_approach_position() -> Vector2:
	var waypoint := get_node_or_null(counter_approach_path) as Node2D
	if waypoint != null:
		return waypoint.position
	return counter_position

func _display() -> Node2D:
	return get_node_or_null(display_path) as Node2D
