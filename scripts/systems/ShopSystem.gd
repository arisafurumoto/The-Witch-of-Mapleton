extends Node

# Autoload singleton. Handles selling an item from the inventory for gold.
# Validates first, so a failed sale never removes items or grants gold.

signal item_sold(item_id: String, quantity: int, gold: int)

func try_sell(item_id: String, quantity: int, gold: int) -> bool:
	if not Inventory.has_item(item_id, quantity):
		return false
	Inventory.remove_item(item_id, quantity)
	Inventory.add_gold(gold)
	AudioSystem.play_sale()
	item_sold.emit(item_id, quantity, gold)
	print("Sold %dx %s for %d gold (total gold: %d)" % [quantity, item_id, gold, Inventory.get_gold()])
	return true

func complete_display_sale(item_id: String, quantity: int, gold: int) -> bool:
	if item_id == "" or quantity <= 0 or gold < 0:
		return false
	Inventory.add_gold(gold)
	AudioSystem.play_sale()
	item_sold.emit(item_id, quantity, gold)
	print("Sold display item %dx %s for %d gold (total gold: %d)" % [quantity, item_id, gold, Inventory.get_gold()])
	return true
