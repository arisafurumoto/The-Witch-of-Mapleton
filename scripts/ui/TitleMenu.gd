extends Control

@onready var _continue_button: Button = $MenuPanel/Margin/VBox/ContinueButton
@onready var _new_game_button: Button = $MenuPanel/Margin/VBox/NewGameButton
@onready var _quit_button: Button = $MenuPanel/Margin/VBox/QuitButton
@onready var _status_label: Label = $MenuPanel/Margin/VBox/StatusLabel

func _ready() -> void:
	HUD.visible = false
	InventoryPanel.visible = false
	DisplayStockPanel.visible = false
	_continue_button.disabled = not SaveSystem.has_save()
	_continue_button.pressed.connect(_on_continue_pressed)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	if SaveSystem.has_save():
		_status_label.text = "Saved Day %d" % DaySystem.get_day()
	else:
		_status_label.text = "No save yet"

func _on_continue_pressed() -> void:
	HUD.visible = true
	SaveSystem.continue_game()

func _on_new_game_pressed() -> void:
	HUD.visible = true
	SaveSystem.start_new_game()

func _on_quit_pressed() -> void:
	get_tree().quit()
