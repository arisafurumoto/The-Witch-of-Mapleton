extends CanvasLayer

# Autoload singleton. Minimal heads-up display. For now just shows the gold count,
# updated whenever the inventory's gold changes.

@onready var _gold_label: Label = $GoldLabel
@onready var _day_label: Label = $DayLabel

func _ready() -> void:
	layer = 50
	Inventory.gold_changed.connect(_update_gold)
	DaySystem.day_changed.connect(_update_day)
	_update_gold()
	_update_day(DaySystem.get_day())

func _update_gold() -> void:
	_gold_label.text = "Gold: %d" % Inventory.get_gold()

func _update_day(day: int) -> void:
	_day_label.text = "Day %d" % day
