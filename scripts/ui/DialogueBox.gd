extends CanvasLayer

# Autoload singleton UI. Shows a speaker name and a sequence of text lines at the
# bottom of the screen. Pressing the interact action advances to the next line;
# after the last line it closes and emits dialogue_finished.

signal dialogue_finished

@onready var _panel: Control = $Panel
@onready var _name_label: Label = $Panel/Margin/VBox/NameLabel
@onready var _line_label: Label = $Panel/Margin/VBox/LineLabel

var _lines: Array = []
var _index: int = 0
var _active: bool = false
var _just_opened: bool = false

func _ready() -> void:
	layer = 100
	_panel.visible = false

func is_active() -> bool:
	return _active

func show_dialogue(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_index = 0
	_active = true
	_just_opened = true
	_name_label.text = speaker
	_name_label.visible = speaker != ""
	_line_label.text = str(_lines[0])
	_panel.visible = true

func _process(_delta: float) -> void:
	# Clear the open-guard one frame after opening so the press that started the
	# dialogue doesn't also advance it.
	if _just_opened:
		_just_opened = false

func _unhandled_input(event: InputEvent) -> void:
	if not _active or _just_opened:
		return
	if event.is_action_pressed("interact"):
		_advance()
		get_viewport().set_input_as_handled()

func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
	else:
		_line_label.text = str(_lines[_index])

func _close() -> void:
	_active = false
	_panel.visible = false
	dialogue_finished.emit()
