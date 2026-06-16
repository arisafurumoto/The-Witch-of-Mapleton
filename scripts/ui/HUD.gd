extends CanvasLayer

# Autoload singleton. Minimal heads-up display. For now just shows the gold count,
# updated whenever the inventory's gold changes.

@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel
@onready var _day_label: Label = $Panel/Margin/VBox/DayLabel
@onready var _toast_label: Label = $ToastLabel

var _toast_tween: Tween

func _ready() -> void:
	layer = 50
	Inventory.gold_changed.connect(_update_gold)
	DaySystem.day_changed.connect(_update_day)
	SaveSystem.game_saved.connect(_on_game_saved)
	SaveSystem.game_loaded.connect(_on_game_loaded)
	_update_gold()
	_update_day(DaySystem.get_day())
	_toast_label.visible = false

func _update_gold() -> void:
	_gold_label.text = "Gold: %d" % Inventory.get_gold()

func _update_day(day: int) -> void:
	_day_label.text = "Day %d" % day

func _on_game_saved(_day: int, _gold: int) -> void:
	_show_toast("Game saved")

func _on_game_loaded(day: int, _gold: int) -> void:
	_show_toast("Loaded Day %d" % day)

func _show_toast(message: String) -> void:
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_label.text = message
	_toast_label.visible = true
	_toast_label.modulate = Color.WHITE
	_toast_tween = create_tween()
	_toast_tween.tween_interval(1.4)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(_hide_toast)

func _hide_toast() -> void:
	_toast_label.visible = false
