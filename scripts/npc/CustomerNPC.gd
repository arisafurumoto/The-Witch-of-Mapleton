extends "res://scripts/core/Interactable.gd"

# A customer who walks up to the counter wanting one item. Talking to them runs
# the request dialogue, attempts the sale, then shows a success or failure line.

@export var request_id: String = "first_calming_tea_request"

var _fulfilled: bool = false
var _busy: bool = false

func interact() -> void:
	if _busy:
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
	else:
		await _say(customer_name, req.get("fail_lines", []))

	_busy = false

# Shows dialogue and waits for it to finish (no-op if there are no lines).
func _say(speaker_name: String, lines: Array) -> void:
	DialogueBox.show_dialogue(speaker_name, lines)
	if DialogueBox.is_active():
		await DialogueBox.dialogue_finished
